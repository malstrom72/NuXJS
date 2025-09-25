# Faster Outer-Closure Variable Binding in the NuXJS VM

## Motivation
Sampling profiles of the interpreter show that resolving named variables remains a visible cost: `FunctionScope::readVar` alone accounts for 1.7–2.5 % of sampled time across the standard benchmark runs, and `READ_NAMED_OP` is one of the most frequently executed opcodes.【F:docs/nuxjs_vm_perf_profile.md†L12-L107】 This time is spent even when the identifier ultimately resides in an outer function’s stack slot, because the VM still walks the scope chain and hashes the name on every access.

## How outer bindings are resolved today

### Bytecode emission
The parser/builder only binds identifiers to local slots when it can prove statically that the name lives in the current function and no `with` scopes interfere. Whenever those checks fail, the compiler emits the generic `READ_NAMED_OP` / `WRITE_NAMED_OP` pair backed by a constant pool string.【F:src/NuXJS.cpp†L3842-L3859】【F:src/NuXJS.cpp†L3893-L3917】 Nested function bodies are compiled by spawning a brand-new `Compiler` instance that has no knowledge of the parent’s locals, so captured variables in inner closures necessarily go through the slow path.【F:src/NuXJS.cpp†L3737-L3748】 Function code objects record argument/variable names in `Code::nameIndexes`, but that map is local to each function instance.【F:src/NuXJS.cpp†L4562-L4593】【F:src/NuXJS.cpp†L1604-L1610】

### Runtime scope chain
At runtime every frame exposes a `Scope`. The generic `Scope` implementation simply delegates lookups to its parent, while `FunctionScope` owns the contiguous array that stores both vars and arguments for that activation.【F:src/NuXJS.cpp†L1964-L2042】 When a nested function is created (`GEN_FUNC_OP`) the current scope is frozen into the `JSFunction` object so that future invocations start from that closure chain.【F:src/NuXJS.cpp†L2661-L2666】 During interpretation `READ_NAMED_OP` pulls the identifier from the constant pool and asks the active scope to resolve it; each `FunctionScope` in the chain computes a bloom-filter test and a hash-table lookup before either returning the slot value or recursing further outward.【F:src/NuXJS.cpp†L2473-L2503】【F:src/NuXJS.cpp†L2020-L2067】 If the name was introduced dynamically (for example via `eval`), it lives inside the lazily-created `dynamicVars` object and the lookup falls back to normal property access.【F:src/NuXJS.cpp†L2010-L2104】

### Why the slow path is unavoidable today
Because nested functions are compiled in isolation, the bytecode for the inner function never records which ancestor scope holds a captured name. Every access therefore replays the string-based search above. Constructs that mutate the environment at runtime (`with`, direct `eval`, dynamically declared vars) already disable even the current-function fast path by bumping `withScopeCounter` or installing an `EvalScope`, which highlights the safety constraints any new optimization must obey.【F:src/NuXJS.cpp†L2249-L2254】【F:src/NuXJS.cpp†L4048-L4055】

## Optimization directions

The remainder of this document preserves the alternative strategies we evaluated while `Code::capturedBindings` still existed.
Those sections remain valuable for historical context, but the current implementation (milestone 2) no longer serialises
`CapturedBinding` tables onto the `Code` object—the interpreter now derives fallback metadata entirely from closure operands and
`Code::getLocalName`. Where the legacy text still mentions maintaining or invalidating the vector, read those statements as
describing prior behaviour rather than to-do work for the modern system.

### 1. Compile-time upvalue slots

#### Overview
The present compiler launches a fresh `Compiler` instance for every nested function, which severs access to the parent’s lexical tables; as a result, captured identifiers are emitted as generic `NAMED` references that defer binding to runtime scope hashing.【F:src/NuXJS.cpp†L2876-L2891】【F:src/NuXJS.cpp†L3737-L3748】 A compile-time upvalue scheme must therefore propagate symbol metadata from the outer compiler so that inner emissions can encode concrete `(depth, slot)` coordinates.

#### Front-end data structures and symbol plumbing
`Compiler` today only remembers the current function’s `Code::nameIndexes`, populating it via `declareIdentifier` when new variables are declared or parameters parsed.【F:src/NuXJS.h†L825-L848】【F:src/NuXJS.cpp†L3893-L3933】【F:src/NuXJS.cpp†L4562-L4594】 A second pass over the sources shows we can seed closure metadata with fewer moving parts than originally outlined:

* Rather than inventing a parallel descriptor stack, extend `SemanticScope` with optional lexical data (a pointer to the owning `Code`, a view of the parent’s `nameIndexes`, and a single “safe for lexical capture” flag). The struct is already allocated for every syntactic scope and threaded through `statementList`, so we can attach a `CapturedLexical*` payload without altering traversal sites.【F:src/NuXJS.cpp†L2893-L2955】【F:src/NuXJS.cpp†L4459-L4543】
* Share existing binding tables. When `functionDefinition` spawns a child compiler, pass a lightweight `CapturedLexical` struct that references the parent `Code` and exposes `lookupNameIndex` directly, instead of copying symbol data into ad-hoc vectors.【F:src/NuXJS.cpp†L3737-L3795】【F:src/NuXJS.h†L825-L836】 Because `lookupNameIndex` already distinguishes arguments (>= 0) from vars (< 0) and `varNames` is stored in reverse to line up with `localsPointer`, the compiler only needs to cache the signed index along with the inherited `bool allowClosureSlots` flag.【F:src/NuXJS.h†L825-L848】【F:src/NuXJS.cpp†L1997-L2047】
* Reuse `declareIdentifier` as the single place that pushes locals into the fast-path table. The helper already refuses to return a local index when `withScopeCounter` is non-zero or the target is the synthetic catch parameter (`CATCH_PARAMETER`).【F:src/NuXJS.cpp†L3893-L3917】【F:src/NuXJS.cpp†L3737-L3755】 Propagating the same boolean to descendants keeps the new closure metadata aligned with the existing fast-path rules for `with` and catch bindings.【F:src/NuXJS.cpp†L4048-L4055】【F:src/NuXJS.cpp†L3751-L3754】
* Thread a minimal `(depth, slot)` payload through `ExpressionResult`. The parser currently sets `ExpressionResult::LOCAL` when an identifier matches the current frame; we only need an extra variant that carries the depth and reuses the existing signed-slot convention. Touchpoints are limited to `identifier`, `optionalExpression`, and the assignment helpers that already switch on `ExpressionResult::Type`.【F:src/NuXJS.cpp†L2876-L2939】【F:src/NuXJS.cpp†L3244-L3274】

Once `functionDefinition` copies the collected captures into the nested `Code` (mirroring how it already finalizes `argumentNames` and `varNames`), the VM no longer needs to serialize a side table of capture metadata. Each closure operand carries the `(depth, slot)` tuple directly, and runtime fallbacks recover identifier names from the existing lexical metadata on demand.【F:src/NuXJS.cpp†L3889-L3906】【F:src/NuXJS.cpp†L2550-L2596】【F:src/NuXJS.cpp†L2776-L2785】

#### CapturedBinding record layout
`CapturedBinding` now acts purely as a lightweight decoder for closure operands. Each entry stores:

* `UInt16 depth` – how many `FunctionScope` hops to walk before dereferencing the slot.
* `Int16 slot` – the signed index returned by `Code::lookupNameIndex`, where negative values address `var` slots via `~slot` and non-negative values index the argument tail that starts at `localsPointer`.【F:src/NuXJS.h†L817-L835】【F:src/NuXJS.cpp†L1997-L2052】

No extra flags are necessary on the descriptor itself. Catch parameters already poison their entry in `nameIndexes` with `CATCH_PARAMETER`, so lookups simply fail while that sentinel is active.【F:src/NuXJS.cpp†L3893-L3917】【F:src/NuXJS.cpp†L3751-L3754】【F:src/NuXJS.cpp†L4304-L4336】 `arguments` is excluded by the same fast-path check, which prevents emitting closure records for bindings that flow through `dynamicVars` instead.【F:src/NuXJS.cpp†L3850-L3858】【F:src/NuXJS.cpp†L2010-L2104】 This keeps the runtime representation identical to the layout that `FunctionScope` already expects.

#### Recovering identifier names when fast paths fail
Because the compiler no longer preserves a separate vector of captured bindings, runtime fallbacks recover identifier strings directly from lexical metadata. Every activation retains its `JSFunction`, whose `code` exposes the `varNames`/`argumentNames` tables through `Code::getLocalName`, and the closure chain keeps the correct `FunctionScope` for each lexical ancestor.【F:src/NuXJS.h†L969-L990】【F:src/NuXJS.cpp†L2552-L2609】【F:src/NuXJS.cpp†L2783-L2834】 Successful fast-path resolutions are cached per activation in `Processor::Frame::resolvedClosureSlots`, so repeated reads and writes reuse the computed pointer without rewalking the ancestor chain.【F:src/NuXJS.h†L1680-L1708】【F:src/NuXJS.cpp†L2532-L2603】 When `Scope::resolveClosureOperand` declines the fast slot, the interpreter walks `binding.depth` frames, queries the ancestor `Code::getLocalName(binding.slot)`, and reuses the generic `Scope::readVar`/`writeVar` helpers. This preserves ReferenceError reporting and dynamic-scope semantics without storing duplicate name pointers on the `Code` object.【F:src/NuXJS.cpp†L2599-L2633】【F:src/NuXJS.cpp†L2835-L2853】

#### Instrumentation and validation

To keep guard behaviour observable, the runtime now records closure-resolution counters on `Runtime::ClosureResolutionStats`, tracking fast-path hits, cache misses, and slow-path fallbacks for every opcode execution.【F:src/NuXJS.h†L1176-L1252】【F:src/NuXJS.cpp†L2556-L2607】 The interpreter increments these counters in each closure opcode, and the REPL exposes `__resetClosureStats` / `__closureStats` helpers so tests can reset and inspect the totals without native tooling.【F:src/NuXJS.cpp†L2556-L2607】【F:tools/NuXJSREPL.cpp†L195-L233】 Regression `closureInstrumentationCounters20250211.io` exercises the helpers to confirm fast-path accesses increment the hit counters while dynamic-scope-guarded closures fall back to named resolution and leave the counters unchanged.【F:tests/regression/closureInstrumentationCounters20250211.io†L1-L36】

#### Identifier analysis workflow
With the contextual chain in place, the lookup steps become:

1. Perform today’s local lookup through `code->nameIndexes` to preserve the fast path for the current frame.【F:src/NuXJS.cpp†L3848-L3917】
2. If no local slot matches, walk the linked `CapturedLexical` contexts (one per ancestor function). Each node calls `lookupNameIndex` on its `Code` and, on success, packages `(depth, slot)` into the expression tree.
3. If a context’s `allowClosureSlots` flag is false, stop the walk and fall back to a `NAMED` expression so runtime hashing preserves spec semantics. Today the flag is cleared only when the ancestor was parsed under an active `with`, because that construct injects object properties ahead of lexical slots in the scope chain.【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4240-L4249】【F:docs/specs/ECMA-262 3.md†L3296-L3327】 Catch sentinels and `arguments` filtering continue to block unsafe captures implicitly, and direct eval shares the fast path because new bindings land in `dynamicVars` rather than the indexed slot array.【F:src/NuXJS.cpp†L3893-L3925】【F:src/NuXJS.cpp†L2019-L2059】【F:docs/specs/ECMA-262 3.md†L1768-L1834】

The compiler now records every guard failure in a lightweight `Vector<ClosureOperandDiagnostic>` stored on the owning `Code`. Each entry captures the identifier name, the depth/slot pair when available, and the reason the fast path was rejected so tooling can inspect downgraded captures without rerunning the compiler.【F:src/NuXJS.h†L817-L856】【F:src/NuXJS.cpp†L1610-L1614】【F:src/NuXJS.cpp†L3892-L3954】 This diagnostic trail complements the guard walk above: the moment a capture is blocked—by `with`, catch sentinels, slot overflow, or operand packing limits—the compiler records the reason and emits the legacy named opcode.

Because the contexts piggy-back on `functionStatement`’s hoisting and `declareIdentifier`’s bookkeeping, hoisted functions automatically surface to nested compilers without extra plumbing.【F:src/NuXJS.cpp†L4007-L4049】

##### Dynamic-scope guard visibility

The guard described above only reflects constructs the parser has already encountered. `functionDefinition` instantiates the nested `Compiler` the moment the `function` token is reached, so the child body finishes compiling before the parent resumes scanning subsequent statements.【F:src/NuXJS.cpp†L3876-L3891】 If the outer function contains a `with` statement or a syntactic direct `eval` *after* that point, the parent flips `withScopeCounter` or `allowClosureSlots` only when it eventually parses those later nodes.【F:src/NuXJS.cpp†L3805-L3814】【F:src/NuXJS.cpp†L4240-L4249】 By then every descendant compiled earlier has already recorded concrete `(depth, slot)` pairs, and there is no mechanism today to invalidate them.

To keep the compile-time scheme sound we therefore need an upfront signal that the body will execute under dynamic scopes. A fresh audit of the parser uncovered four implementation strategies worth considering:

| Solution | Guard timing approach | Extra compiler work | Drops binding table? |
| --- | --- | --- | --- |
| 1. Statement-list pre-pass | Peek ahead in the remaining statement list before spawning child compilers so late `with` / direct `eval` constructs are known up front. | Lightweight lexer peek plus a guard summary threaded through `functionDefinition`. | **Yes.** Guard finalised before emission lets `(depth, slot)` be written straight into operands. |
| 2. Deferred nested compilation | Queue nested bodies and compile them after the enclosing statement list finishes scanning. | Pending-body list, replay hooks, and hoist handling adjustments. | **Yes.** Deferred compile sees the final guard state and complete `nameIndexes`, so operands can embed coordinates with no side table. |
| 3. Retroactive capture invalidation | Emit closure opcodes speculatively and rewrite them if hazards surface later. | Opcode patch list plus a scrubber that reinstates named lookups. | **No.** Needs `CapturedBinding` entries (with names) to restore the fallback form. |
| 4. Runtime guard handshake | Let the VM detect dynamic scopes at execution time and fall back on demand. | Minor interpreter tweaks to probe guard scopes. | **No.** Runtime fallbacks require identifier strings, so the binding list and names must stay. |
| 5. Token-buffer guard pass | Lex the function body into a temporary buffer, compute guard bits, then run the real compilation. | Token buffering, guard scan, and clean-up logic. | **Yes.** Once the pre-scan settles the guard, operands can carry all capture data. |
| 6. Pending-closure finalisation barrier | Queue provisional closure emissions and decide their final opcode before sealing the function. | Placeholder opcodes, relocation tables, and a commit sweep. | **Yes.** Final pass resolves hazards before materialising bytecode, enabling operand-only captures. |
| 7. Dual-path emission with late selection | Emit both closure and named variants, then prune the unused path once guard state is known. | Dual emission tracking plus a pruning stage. | **Yes, after pruning.** Surviving closure opcodes can store full coordinates and drop auxiliary tables. |
| 8. Guard-triggered recompilation handshake | Re-run `compileFunction` after the enclosing body observes every guard-flipping construct. | Metadata to describe the body span, captured names, and recompilation triggers. | **Yes.** The second pass emits final operands and discards the captured-binding list entirely. |
| 9. Post-compilation closure sweep | Emit only named opcodes initially, then rewrite safe captures once the whole body’s guard state is known. | Late pass that walks nested `Code` objects, resolves identifiers, and patches opcodes/constants. | **Yes,** when every rewritten site encodes `(depth, slot)` directly and prunes the now-unused name constants. |
| 10. Ancestor-name runtime fallback | Encode `(depth, slot)` directly in the operand and recover the identifier on demand by walking the lexical chain to `Code::getLocalName`. | Interpreter helper to unpack operands, climb the `FunctionScope` chain, and fetch names when `resolveClosureOperand` fails. | **Yes.** Names are reconstructed lazily from lexical metadata so no binding vector or stored strings are required. |

1. **Statement-list pre-pass.** Before `functionDefinition` instantiates a child compiler, run a lightweight scan over the remaining tokens in the current statement list and flip `allowClosureSlots` to `false` if a `with` statement or syntactic direct `eval` is present.【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4032-L4048】【F:src/NuXJS.cpp†L4240-L4249】 The scan can reuse `statementList`’s existing loop (which already walks the upcoming statements without mutating state) and only needs to detect tokens that eventually increment `withScopeCounter` or emit `CALL_EVAL_OP`. This keeps the emitted bytecode unchanged and ensures every nested compiler inherits the most conservative guard before any capture analysis runs. The trade-off is the extra parsing work: the pass must either duplicate tokenization logic or create a peeking helper that can recognise `with`/`eval` without consuming the input stream, otherwise the parser state would need to be rewound carefully.

2. **Deferred nested compilation.** Instead of compiling nested functions immediately, record their parse locations and postpone the actual `functionDefinition` call until the surrounding statement (or even the entire body) has been processed.【F:src/NuXJS.cpp†L3965-L4049】【F:src/NuXJS.cpp†L4200-L4238】 By the time deferred compilation occurs, any `with` or direct-eval constructs encountered later in the outer body will already have dropped `allowClosureSlots`, so the child compilers inherit the correct guard automatically. This approach aligns with traditional two-pass hoisting strategies but requires significant refactoring: `functionStatement` currently emits `GEN_FUNC_OP` and updates the hoist table immediately, so deferral would need bookkeeping to store pending function ASTs and to replay their compilation after the guard state stabilises.

3. **Retroactive capture invalidation.** Keep the eager compilation flow but maintain a list of nested `Code` objects created so far; when the parser later encounters a `with` or direct-eval that would have disabled fast bindings, walk that list and scrub their captured-binding tables (for example by clearing `code->capturedBindings` and rewriting any closure opcodes back to `READ_NAMED_OP`).【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4043-L4050】【F:src/NuXJS.cpp†L4750-L4752】 Because each `Code` object keeps its `Vector<CapturedBinding>` mutable until compilation finishes, the compiler could still patch the instruction stream before handing the function to the runtime. The difficulty lies in tracking every opcode location that referenced a captured binding and ensuring the rewrite covers deletes, reads, and writes in all code sections; missing a site would leave stale fast-path instructions that violate spec semantics once the late `with` executes.

4. **Runtime guard handshake.** Allow compile-time captures to proceed optimistically but teach `FunctionScope::resolveClosureOperand` (and the closure opcodes that call it) to validate that the activation chain contains only other `FunctionScope` frames before honouring the cached `(depth, slot)` coordinates.【F:src/NuXJS.cpp†L2020-L2156】【F:src/NuXJS.cpp†L2800-L2807】 When a `WITH_SCOPE_OP` or `EvalScope` frame is pushed at runtime, the guard would force `resolveClosureOperand` to fail, causing the interpreter to fall back to the existing `readVar`/`writeVar` helpers that honour dynamic scope semantics.【F:src/NuXJS.cpp†L2820-L2833】【F:src/NuXJS.cpp†L2304-L2436】 This hybrid design guarantees correctness even if the parser missed a late guard, but it shifts work to the hot path: every closure access must check for dynamic frames and may still pay the slow lookup cost if a `with` or `eval` executed. It also requires storing enough metadata on each `Scope` to distinguish lexical frames from dynamic ones so the validation can run without extra hashing.

5. **Token-buffer guard pass.** Instead of scanning only the remaining statements in place, capture the entire function body into a temporary token buffer the moment the opening `{` is consumed, compute a guard summary up front, and then replay the buffered tokens to run the real compilation.【F:src/NuXJS.cpp†L4714-L4736】【F:src/NuXJS.cpp†L4758-L4789】 Because the `Compiler` already tracks raw pointers `b`/`p` into the source, we can add a helper that lexes from `p` to the matching `}` while recording whether `with`, direct `eval`, or `catch` clauses appear. Nested `functionDefinition` calls would only be allowed to start once that summary is known, so every child compiler inherits a definitive `allowClosureSlots` flag before it ever resolves captures. With the guard decided upfront we no longer need a `Vector<CapturedBinding>`: each closure opcode can embed an `ancestorDistance` (a clearer name than “level”) together with the signed slot offset directly in the 24-bit operand, and there is no reason to keep per-binding name pointers around.

6. **Pending-closure finalisation barrier.** Keep the single-pass parser but stop short of emitting final bytecode for nested functions until the surrounding body finishes parsing. `functionDefinition` can stash each child compiler, the list of candidate captures, and the raw token span in a `PendingClosure` list while continuing to emit placeholder opcodes in the parent stream.【F:src/NuXJS.cpp†L3876-L3899】【F:src/NuXJS.cpp†L4758-L4789】 Once `statementList` reaches the closing `}` it has seen every dynamic-scope construct, so it can flip a per-closure flag indicating whether the fast path is safe. Safe closures are then materialised by encoding `(ancestorDistance, slotOffset)` straight into the operand; unsafe ones are re-emitted as `READ_NAMED_OP`/`WRITE_NAMED_OP` before the code object is frozen. Because the slow-path rewrite happens prior to serialising `code->codeWords`, the runtime never observes provisional opcodes and the compiler can drop both the captured-binding array and the name field from `CapturedBinding` entirely.【F:src/NuXJS.cpp†L4722-L4744】【F:src/NuXJS.cpp†L4768-L4779】

7. **Dual-path emission with late selection.** Another approach is to have the emitter generate both fast and slow encodings for every captured identifier and defer the choice until guard resolution completes. When `recordCapturedBinding` succeeds it can reserve two instruction slots: one packs `(ancestorDistance, slotOffset)` into a dedicated closure opcode, the other stores the constant-pool index for the identifier just as today’s named opcodes do.【F:src/NuXJS.cpp†L3893-L3931】【F:src/NuXJS.cpp†L3313-L3368】 After the body has been fully scanned, a final pass walks those paired placeholders and commits to either the closure operand (dropping the spare instruction entirely) or the named operand. Because the commitment happens before `Code::codeWords` is sealed, we can elide the global captured-binding table and remove the `const String* name` field—only the surviving opcode reaches the VM, and it already contains the data it needs.

8. **Guard-triggered recompilation handshake.** Leverage the fact that `compileFunction` already knows the exact character range of each nested body to re-run compilation under the correct guard once the outer scope has finished discovering hazards.【F:src/NuXJS.cpp†L3876-L3888】【F:src/NuXJS.cpp†L4758-L4789】 When a nested function is first encountered, capture its `[begin, end)` pointers and compile it speculatively with `allowClosureSlots = true`, but also store the span and the list of identifiers it tried to capture. If a later `with` or direct `eval` flips the guard, enqueue the span for recompilation with `allowClosureSlots = false` before the parent `Code` finalises. The second pass overwrites the earlier bytecode, emitting only named accesses so there is no lingering dependency on the discarded closure operands. Because the final artefact is rebuilt with the definitive guard, closures that remain eligible can encode `(ancestorDistance, slotOffset)` inline, eliminating the need for auxiliary binding tables or stored names.

###### Evaluation of the guard strategies

**Solution 1 – Statement-list pre-pass**

*Pros*
- Integrates with the existing `statementList` loop, so a guard scan can walk the remaining tokens before any nested `functionDefinition` instantiates a child compiler and copies the parent guard bit.【F:src/NuXJS.cpp†L4714-L4719】【F:src/NuXJS.cpp†L3876-L3889】
- Keeps runtime costs unchanged because guard decisions are still made entirely at compile time; no additional checks land in the interpreter’s closure opcodes.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Requires a new peeking lexer that recognises `with` statements and direct `eval` calls without advancing `p`, otherwise the real parser would see partially consumed tokens on the second pass.【F:src/NuXJS.cpp†L4714-L4719】【F:src/NuXJS.cpp†L3805-L3814】
- Does not improve look-ahead captures: inner functions still compile before later `var` declarations populate `code->nameIndexes`, so late locals continue to fall back to named lookups.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4085-L4125】

*Implementation notes*
- Extend `Compiler::statementList` with a non-consuming guard pre-scan so it lexes the remaining body before entering the main loop; the resulting summary is threaded into `functionDefinition` so nested compilers inherit the final guard bit rather than the state observed when the `function` token was first seen.【F:src/NuXJS.cpp†L4651-L4720】【F:src/NuXJS.cpp†L3876-L3889】
- Build the pre-scan around a peek helper shared with `Compiler::statement` so it can recognise `with` statements and bare `eval` identifiers (which currently toggle `allowClosureSlots` inside the call emission) without consuming tokens, then copy that summary onto the `CapturedLexicalContext` handed to the child compiler.【F:src/NuXJS.cpp†L4651-L4707】【F:src/NuXJS.cpp†L3805-L3814】
- Keep the scan aligned with existing slot allocation by running it before `declareIdentifier` mutates `code->nameIndexes`, preserving today’s visibility rules for already-hoisted locals.【F:src/NuXJS.cpp†L4085-L4115】

**Solution 2 – Deferred nested compilation**

*Pros*
- Postponing `functionDefinition` until the outer statement list completes ensures every guard flip (e.g. `with` pushing `withScopeCounter`) is observed before nested compilers are created.【F:src/NuXJS.cpp†L4231-L4249】【F:src/NuXJS.cpp†L3876-L3889】
- Because the parent finishes running `declareIdentifier` for the whole body before the deferred compilation occurs, inner functions finally see `nameIndexes` populated with later `var` declarations, enabling more fast bindings beyond hoisted declarations.【F:src/NuXJS.cpp†L4085-L4125】

*Cons*
- Needs bookkeeping for pending function bodies (source spans, hoist targets, captured-name lists) so the compiler can replay them after the body finishes without violating hoist semantics.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4755-L4787】
- Forces larger structural changes to the parser because `functionStatement` currently emits bytecode immediately and assumes the child `Code` exists for hoist initialisation.【F:src/NuXJS.cpp†L4231-L4237】

*Implementation notes*
- Swap the eager call inside `functionStatement` for a queue of `PendingFunction` records (span, name, hoist target) and drain that queue once `statementList` has finished walking the body so deferred compiles run after every guard flip has been observed.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4714-L4752】
- Teach `functionDefinition` to consume the queued metadata, replay `compileFunction`, and then emit the hoist stub through `setupSection` so hoisted declarations still materialise before runtime code executes.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4744-L4752】
- Because the replay happens after the parent has finished `declareIdentifier`, the nested compiler finally sees later locals through `code->nameIndexes`; record which nested bodies actually attempted captures so functions without upvalues can skip the deferred pass entirely.【F:src/NuXJS.cpp†L4085-L4115】【F:src/NuXJS.cpp†L3893-L3925】

**Solution 3 – Retroactive capture invalidation**

*Pros*
- Reuses the existing `capturedBindings` table and instruction stream so early compiles proceed unchanged; only guard violations trigger rewrites before `code->codeWords` is sealed.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L4744-L4752】
- Avoids recompiling whole functions—unsafe captures are simply rewritten back to `READ_NAMED_OP`/`WRITE_NAMED_OP` using the original identifier.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Must track every opcode location that referenced a captured binding so the scrubber can restore the named operand reliably; missing a site leaves incorrect fast-path bytecode behind.【F:src/NuXJS.cpp†L3893-L3929】【F:src/NuXJS.cpp†L2550-L2609】
- (Historical) Kept the `CapturedBinding` vector and `name` pointer alive even after invalidation because the interpreter needed those strings for the fallback helpers. The modern operand-only system avoids this duplication by querying `Code::getLocalName` on demand.【F:src/NuXJS.cpp†L2550-L2609】

*Implementation notes*
- Extend `recordCapturedBinding` to stash `(codeOffset, constantIndex)` pairs in a scrub list whenever it emits a closure operand so the compiler can later revert those instructions without searching the bytecode blindly.【F:src/NuXJS.cpp†L3893-L3925】【F:src/NuXJS.cpp†L3098-L3134】
- Trigger the scrubber from the same sites that flip the guard—direct eval detection and the `withScopeCounter` maintained by `withStatement`—ensuring the rewrite runs before `compile` copies the sections into the final `codeWords`.【F:src/NuXJS.cpp†L3805-L3814】【F:src/NuXJS.cpp†L4240-L4249】【F:src/NuXJS.cpp†L4744-L4752】
- When invalidating a capture, rewrite the opcode back to its `*_NAMED_OP` form and restore the identifier operand via `emitWithConstant`, leaving the binding vector and `name` pointer intact for runtime fallbacks.【F:src/NuXJS.cpp†L3211-L3213】【F:src/NuXJS.cpp†L2550-L2609】

**Solution 4 – Runtime guard handshake**

*Pros*
- Minimal compiler churn: rely on `FunctionScope::resolveClosureOperand` to refuse resolutions whenever a dynamic scope intervenes, reusing today’s runtime guard surface.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2304-L2363】
- Guarantees correctness even if the parser misses a hazard, because the interpreter falls back to `readVar`/`writeVar` when the guard fails.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Adds runtime overhead to every closure access—the interpreter must probe `resolveClosureOperand` and often rerun the full named lookup when a `WithScope` or `EvalScope` is active.【F:src/NuXJS.cpp†L2550-L2609】【F:src/NuXJS.cpp†L2304-L2363】
- (Historical) Could not drop `CapturedBinding::name` because the fallback path still needed the identifier string for error messages and dynamic lookups. Operand decoding plus `Code::getLocalName` now covers that need.【F:src/NuXJS.cpp†L2550-L2609】

*Implementation notes*
- Keep the compiler untouched and update `Processor::innerRun` so the closure opcodes invoke `Scope::resolveClosureOperand` before falling back to the named helpers, reusing the runtime guard overrides already supplied by `EvalScope` and `WithScope`.【F:src/NuXJS.cpp†L2550-L2609】【F:src/NuXJS.cpp†L1998-L2065】【F:src/NuXJS.cpp†L2300-L2364】
- Ensure the interpreter honours the compiler’s direct-eval toggle by checking the existing `allowClosureSlots` flag when `CALL_EVAL_OP` is emitted, so runtime and compile-time guard decisions stay aligned.【F:src/NuXJS.cpp†L3805-L3814】

**Solution 5 – Token-buffer guard pass**

*Pros*
- `compileFunction` already captures raw pointers to the body, making it feasible to lex the full span into a temporary buffer and compute guard metadata before any nested compilation runs.【F:src/NuXJS.cpp†L4755-L4787】
- With the guard settled up front, child compilers can safely emit closure operands and drop auxiliary binding tables for eligible captures.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L3893-L3901】

*Cons*
- Doubles lexing work for large functions and demands extra memory to stash the buffered tokens during the real parse.【F:src/NuXJS.cpp†L4755-L4787】
- Still leaves late `var` hoisting unsolved unless the buffer is also analysed for declarations, which increases the complexity of the pre-pass substantially.【F:src/NuXJS.cpp†L4085-L4125】

*Implementation notes*
- Leverage the `[b, e)` span captured by `compileFunction` to run a temporary lexing pass that records guard metadata before instantiating the child compiler, storing the buffered tokens alongside the span until the real parse begins.【F:src/NuXJS.cpp†L4755-L4787】
- Feed the resulting summary into `functionDefinition` so it seeds the `CapturedLexicalContext` with the final guard bit before constructing the nested `Compiler`, and release the buffer once compilation succeeds to avoid retaining duplicate source copies.【F:src/NuXJS.cpp†L3876-L3889】
- If the scan later tracks hoisted declarations, reuse the same insertion rules as `declareIdentifier` so buffered discoveries match the slot indices created during the actual parse.【F:src/NuXJS.cpp†L4085-L4115】

**Solution 6 – Pending-closure finalisation barrier**

*Pros*
- Keeps the single-pass parser intact while delaying opcode commitment: nested `functionDefinition` calls queue their binding metadata, and a final sweep decides whether to emit closure or named opcodes before `code->codeWords` is frozen.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4744-L4752】
- Allows dropping the per-function binding array once operands are rewritten, because only the chosen opcode reaches the VM.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Needs placeholder opcodes and relocation tables so the late pass can patch both reads and writes without disturbing stack accounting in `CodeSection::emit`.【F:src/NuXJS.cpp†L3098-L3115】
- Hoist bookkeeping becomes trickier because the compiler must ensure queued closures are materialised before any code that depends on them is emitted.【F:src/NuXJS.cpp†L4231-L4237】

*Implementation notes*
- When `functionDefinition` records a captured binding, enqueue a `PendingClosure` entry (code offset, binding index, guard state) so the compiler can delay committing the opcode until the outer body’s guard state is final.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L3893-L3925】
- Run the commit phase immediately before `compile` copies `setupSection` and `mainSection` into `code->codeWords`, rewriting placeholders through `CodeSection::emit` / `Processor::packInstruction` so stack accounting remains correct.【F:src/NuXJS.cpp†L3098-L3134】【F:src/NuXJS.cpp†L4744-L4752】
- Populate `Code::capturedBindings` only after the commit decides which opcodes stay on the closure path, keeping GC and tooling focused on final descriptors rather than provisional metadata.【F:src/NuXJS.h†L833-L856】【F:src/NuXJS.cpp†L2550-L2609】

**Solution 7 – Dual-path emission with late selection**

*Pros*
- Emits both closure and named variants up front so the final selection is a simple pruning step once the guard state is known, eliminating recomputation cost.【F:src/NuXJS.cpp†L3893-L3929】【F:src/NuXJS.cpp†L3313-L3368】
- Guarantees a valid fallback is always available, reducing the risk of spec violations when hazards appear late.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Temporarily doubles instruction and constant-pool usage until the pruning pass runs, increasing compilation time and memory pressure for large scripts.【F:src/NuXJS.cpp†L3098-L3115】
- Still requires a late commit pass to delete the unused opcode, so it inherits part of the complexity of solution 6 without shedding the extra emission cost.【F:src/NuXJS.cpp†L4744-L4752】

*Implementation notes*
- Teach identifier emission sites (`makeRValue`, `makeAssignment`, and friends) to reserve back-to-back instruction slots: one packs the captured-binding index, the other stores today’s named constant so the final pass can keep whichever form survives guard resolution.【F:src/NuXJS.cpp†L3376-L3454】【F:src/NuXJS.cpp†L3211-L3213】
- Track each pair’s offsets in a vector so the pruning pass can delete the unused opcode before `CodeSection::insertSection` merges setup and main sections, keeping jump distances stable.【F:src/NuXJS.cpp†L3137-L3138】【F:src/NuXJS.cpp†L4744-L4752】
- Update the disassembler and related tooling to either hide or annotate the placeholder opcode so debugging output continues to reflect the final instruction stream users will execute.【F:tools/NuXJSREPL.cpp†L250-L313】

**Solution 8 – Guard-triggered recompilation handshake**

*Pros*
- Builds on existing span knowledge: `functionDefinition` already captures the nested body’s `[begin, end)` pointers, so the compiler can re-run `compileFunction` with the definitive guard once the outer body finishes scanning hazards such as `with` or direct `eval` calls.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L3805-L3814】【F:src/NuXJS.cpp†L4240-L4249】
- Guard flips are rare, so most functions compile only once; when a recompile is needed, the second pass can inline `(ancestorDistance, slotOffset)` operands and omit the captured-binding table entirely, leaving the final bytecode as compact as the pure fast-path design.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L2559-L2609】
- When a late `with` or direct `eval` forces recompilation, the second pass runs after the enclosing statement list has completed, so any hoisted declarations that were already visible on the first pass remain available and the regenerated bytecode can still emit final `(ancestorDistance, slotOffset)` operands.【F:src/NuXJS.cpp†L4085-L4125】【F:src/NuXJS.cpp†L4714-L4719】 (Capturing locals declared *later* in the body would still require an additional hoisting step or always-on deferral, because the recompilation only triggers when the guard actually flips.)

*Cons*
- Requires storing per-closure metadata (source span, captured-name attempts, hoist target) so the second pass can rebuild the `Code` safely and reinstall the hoisted function reference before finalising `code->codeWords` and constant tables.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4744-L4752】
- Needs careful integration with GC and error recovery because the speculative `Code` object must be replaced or reset without leaking allocations if the second pass throws an exception mid-compilation.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4755-L4787】

*Implementation notes*
- Capture the nested body’s source span, hoist target, and attempted captures the first time `functionDefinition` runs, storing them alongside the speculative `Code*` generated by `compileFunction` so the data can be reused if the guard later flips.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4755-L4787】
- When a later `withStatement` increments `withScopeCounter` or a direct eval toggles `allowClosureSlots`, schedule the recorded span for recompilation just before `compile` finalises the parent; rerun `compileFunction` with the guard forced off and swap the regenerated `Code` back into the constant pool slot inserted by `GEN_FUNC_OP`.【F:src/NuXJS.cpp†L3805-L3814】【F:src/NuXJS.cpp†L4240-L4249】【F:src/NuXJS.cpp†L3211-L3213】【F:src/NuXJS.cpp†L4744-L4752】
- After replacing the child code, update `capturedBindings` and notify the tooling surfaces that dump capture metadata so diagnostics reflect the final opcode layout while the discarded `Code` is released to the GC.【F:src/NuXJS.cpp†L4750-L4752】【F:tools/NuXJSREPL.cpp†L300-L313】

**Solution 9 – Post-compilation closure sweep**

*Pros*
- Preserves today’s single-pass parser and emission logic by initially generating only the existing named opcodes, so no speculative fast bindings can violate dynamic-scope semantics during the first compile.【F:src/NuXJS.cpp†L3383-L3435】
- The sweep runs after the entire body has been scanned, at which point `allowClosureSlots` and `withScopeCounter` reflect every direct-eval call and `with` statement, ensuring the pass knows exactly which functions must remain on the slow path.【F:src/NuXJS.cpp†L3808-L3814】【F:src/NuXJS.cpp†L4244-L4247】
- Successful rewrites can replace the name-index operand with `(depth, slot)` data and drop the now-unused identifier constants, letting eligible closures ship without a binding table or extra strings in the constant pool.【F:src/NuXJS.h†L845-L868】【F:src/NuXJS.cpp†L3211-L3213】

*Cons*
- Requires a thorough post-pass that walks every nested `Code::codeWords`, recognises `*_NAMED_OP` patterns, and patches them in place without disturbing stack accounting or jump offsets.【F:src/NuXJS.h†L845-L868】【F:src/NuXJS.cpp†L3383-L3435】
- The pass must reconstruct the same ancestor walk that `recordCapturedBinding` performs so it can bail out when catch sentinels, slot-width limits, or dynamic scopes make a capture unsafe, which duplicates fragile compiler logic outside its current home.【F:src/NuXJS.cpp†L3903-L3925】【F:src/NuXJS.cpp†L2300-L2363】
- Constant-pool compaction is delicate because every opcode encodes its constant index; pruning name strings means retargeting the remaining indices and updating any metadata that references them.【F:src/NuXJS.h†L845-L868】【F:src/NuXJS.cpp†L3211-L3213】

*Implementation notes*
- Traverse each nested `Code` by following the `GEN_FUNC_OP` constants once the parent compile finishes, collecting offsets of `*_NAMED_OP` instructions that may be rewritten to closure operands.【F:src/NuXJS.cpp†L3211-L3213】【F:src/NuXJS.cpp†L4744-L4752】
- For every candidate, consult `Code::lookupNameIndex` (the same helper used by `recordCapturedBinding`) to recover the `(depth, slot)` pair; successful probes can then rewrite the opcode via `Processor::packInstruction` and push the descriptor into `capturedBindings` so the operand becomes a compact index.【F:src/NuXJS.cpp†L3893-L3925】【F:src/NuXJS.cpp†L2399-L2408】【F:src/NuXJS.h†L833-L856】
- After rewriting, rebuild the constant pool to drop any unused identifier strings and walk the bytecode to adjust surviving constant indices before publishing the final `codeWords`, keeping the stream consistent for tooling and GC.【F:src/NuXJS.cpp†L3211-L3213】【F:src/NuXJS.cpp†L3098-L3134】

**Solution 10 – Ancestor-name runtime fallback**

*Pros*
- Lets closure opcodes carry only `(depth, slot)` data while preserving spec-compliant fallbacks because the interpreter can reconstruct the identifier string directly from the ancestor `FunctionScope` when dynamic scopes intervene.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2565-L2603】【F:src/NuXJS.h†L844-L848】
- Reuses the existing runtime guards: `EvalScope` and `WithScope` already force `resolveClosureOperand` to fail, so the slow path triggers automatically without adding new parser checks or metadata tables.【F:src/NuXJS.cpp†L1998-L2004】【F:src/NuXJS.cpp†L2298-L2364】
- Keeps `Code`’s `argumentNames`/`varNames` arrays authoritative for error messages and `delete` semantics, avoiding duplicate storage even after the binding vector is removed.【F:src/NuXJS.cpp†L1599-L1606】【F:src/NuXJS.cpp†L4088-L4106】【F:src/NuXJS.h†L969-L990】

*Cons*
- Requires extra work on each fallback: the interpreter must climb the captured lexical depth, fetch the owning `Code`, and look up the name before it can call the generic `Scope::readVar`/`writeVar`, so repeated failures reintroduce scope-walk overhead.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2565-L2603】
- Still depends on the activation retaining its `JSFunction` and lexical tables, so tooling that strips debug metadata or prunes unused names would need to keep those structures alive to avoid breaking late fallbacks.【F:src/NuXJS.h†L969-L990】【F:src/NuXJS.cpp†L4722-L4752】

*Implementation notes*
- Teach the closure opcodes’ slow path to unpack the operand into `(depth, slot)` directly, walk `parentFunctionScope` that many hops, and query the ancestor `JSFunction->getScriptCode()->getLocalName(slot)` whenever `resolveClosureOperand` declines the fast path.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2565-L2603】【F:src/NuXJS.h†L844-L848】【F:src/NuXJS.h†L969-L990】
- Ensure every scope that can break lexical resolution (`EvalScope`, `WithScope`, and future dynamic frames) continues to override `resolveClosureOperand` with `false` so the fallback fires reliably without inspecting operand flags.【F:src/NuXJS.cpp†L1998-L2004】【F:src/NuXJS.cpp†L2298-L2364】
- Keep `Code::argumentNames` and `varNames` populated even after trimming other metadata, because the runtime fallback now depends on them to materialise the correct identifier for ReferenceErrors and property updates.【F:src/NuXJS.cpp†L1599-L1606】【F:src/NuXJS.cpp†L4088-L4106】【F:src/NuXJS.h†L844-L848】 NuXJS already honours this contract today—the constructor keeps both vectors alive, `declareIdentifier` records locals in source order, and the header exposes `getLocalName` so the interpreter can recover strings for slow-path lookups—so the work item here is to avoid regressing that behaviour when we slim other metadata tables.【F:src/NuXJS.cpp†L1596-L1604】【F:src/NuXJS.cpp†L4085-L4108】【F:src/NuXJS.h†L840-L855】

Without one of these adjustments, closures created before the guard flips could still execute while a `WithScope` or `EvalScope` sits between them and the target frame, violating the spec’s lookup order. Although the runtime will fall back when such scopes are present—`EvalScope` and `WithScope` explicitly refuse captured-slot resolution, and the `CATCH_PARAMETER` sentinel blocks catch bindings from ever entering the fast table【F:src/NuXJS.cpp†L2300-L2337】【F:src/NuXJS.cpp†L2357-L2379】【F:src/NuXJS.cpp†L3891-L3925】【F:src/NuXJS.cpp†L4516-L4533】【F:src/NuXJS.cpp†L2565-L2603】—the bytecode emitted ahead of time would still be incorrect. Guarding the compilation phase prevents those invalid opcodes from ever materializing.

###### Final plan – Adopt solution 10

After walking the trade-offs, we will pursue **solution 10 (Ancestor-name runtime fallback)** as the production path for deleting the captured-binding array. The compiler can continue emitting the compact `(ancestorDistance, slotOffset)` operands that the existing fast path already understands, while the interpreter grows a slow-path shim that climbs the recorded lexical depth, asks the ancestor `Code` for the identifier string, and hands control to the established `Scope::readVar`/`writeVar` helpers whenever `resolveClosureOperand` declines the fast slot.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2565-L2603】【F:src/NuXJS.h†L844-L848】【F:src/NuXJS.h†L969-L990】 Because NuXJS already preserves `argumentNames`/`varNames` through `declareIdentifier` and `Code` construction, the fallback has authoritative names to surface ReferenceErrors, deletes, and property writes even after we drop the per-binding `const String*` pointer.【F:src/NuXJS.cpp†L1599-L1606】【F:src/NuXJS.cpp†L4088-L4106】【F:src/NuXJS.cpp†L4722-L4752】

This plan keeps the compiler steady—no token buffering, no deferred compilation queues, and no speculative rewrites—so the closure-slot plumbing described above remains valid. The only additional work items are: (1) teach every dynamic scope (`EvalScope`, `WithScope`, and any future variants) to continue rejecting captured-slot resolution so the slow path is triggered reliably, and (2) update the closure opcodes’ runtime helpers to synthesise identifier strings on demand before delegating to the generic named lookup. Those hooks already exist today, so the change primarily removes storage rather than inventing new metadata. We accept the minor runtime cost when fallbacks occur, trading the rare slow-path walk for a simpler compiler and a slimmer `Code` object.

###### Why `with` and `catch` still block pure slot operands

`with` temporarily installs an object environment ahead of the lexical frames that closures normally traverse.【F:docs/specs/ECMA-262 3.md†L3300-L3327】 However, that dynamic environment only influences code executed in the same execution context. When a nested function that was created *before* the `with` executes, the scope chain for the call is rebuilt from the function object’s stored `[[Scope]]` list: the inner activation sits in front of the outer function’s activation record and then flows straight out to the global scope.【F:docs/specs/ECMA-262 3.md†L1818-L1852】 Because the `with` object never appears in that saved chain, the closure keeps reading the lexical slot value:

```javascript
function outer(box) {
var x = 1;
function inner() { return x; }
with (box) {
return inner();
}
}
outer({ x: 42 }); // returns 1 per ES3/Node.js
```

The example from the previous draft claimed this should evaluate to `42`, but both the ES3 rules and real engines (Node.js, SpiderMonkey) observe `1` because the closure’s captured lexical environment does not include the transient `with` object.

The guard we still need arises when a closure is created *while* a `with` is active. In that case the current scope chain—object environment first, outer activation second—is copied into the function object’s `[[Scope]]`, so every future call must consult the dynamic object before falling back to lexical slots. For instance:

```javascript
function factory(box) {
with (box) {
return function inner() { return x; };
}
}
factory({ x: 42 })(); // returns 42
```

Here the closure would read the wrong value if we bypassed the object environment. A hypothetical fast-path that ignored `with` would still address the outer slot `x = 1`, so `factory({ x: 42 })()` would incorrectly produce `1` instead of the spec-mandated `42`. NuXJS prevents that by incrementing `withScopeCounter` during parsing so any identifier captured inside the block sticks to the named path, and by making `WithScope::resolveClosureOperand` bail out when the interpreter encounters a precomputed slot under an active `with` guard.【F:src/NuXJS.cpp†L4240-L4249】【F:src/NuXJS.cpp†L2361-L2364】【F:src/NuXJS.cpp†L4032-L4040】 Those checks ensure `(depth, slot)` operands are never emitted for closures that actually need the dynamic lookup.

`catch` introduces a similar obstacle. The clause synthesizes an object, binds the exception name as a property, and pushes that object onto the front of the scope chain for the duration of the handler.【F:docs/specs/ECMA-262 3.md†L3436-L3483】 A closure compiled before the `try` statement runs still reads the lexical slot:

```javascript
function outer() {
var x = 1;
function inner() { return x; }
try {
throw 2;
} catch (x) {
return inner();
}
}
outer(); // returns 1 per ES3/Node.js
```

But a function created inside the handler copies the transient object into its captured chain and must honour the shadowing binding:

```javascript
function makeInner() {
try {
throw 2;
} catch (x) {
return function inner() { return x; };
}
}
makeInner()(); // returns 2
```

NuXJS mirrors this behaviour by storing a `CATCH_PARAMETER` sentinel in `nameIndexes` so the identifier never upgrades to a slot binding, then restoring the original entry once the block ends.【F:src/NuXJS.cpp†L4505-L4533】 The sentinel only suppresses slot emission for the handler parameter itself—other locals defined in the surrounding function keep their `(depth, slot)` coordinates because the catch object sits outside the function-scope frame layout and `CatchScope::resolveClosureOperand` simply forwards fast-path probes to its parent function scope.【F:src/NuXJS.cpp†L3891-L3925】【F:src/NuXJS.cpp†L2322-L2337】 Without that guard, a closure created inside the handler would cache the outer slot for `x` and return `1`, violating the ES3 rule that the handler-local binding shadows any same-named outer variable.【F:docs/specs/ECMA-262 3.md†L3436-L3483】 These corrected examples demonstrate that the fast path is safe for closures compiled before the dynamic scope appears, while closures created inside `with` or `catch` blocks must retain name-based resolution for the handler variable.

```javascript
function demo() {
var outer = 7;
try {
throw 0;
} catch (err) {
return function probe() { return outer; }();
}
}
demo(); // still returns 7 via the fast slot path
```

The handler-local `err` stays on the named route, but the closure continues to fast-bind `outer` because the catch scope delegates captured-slot resolution to the surrounding function frame.

#### Bytecode emission updates
Once resolution yields a concrete upvalue descriptor, the emitter needs dedicated opcodes (e.g. `READ_CLOSURE_OP`, `WRITE_CLOSURE_OP`, `DELETE_CLOSURE_OP`) whose operands encode the ancestor depth and slot. Adding these opcodes touches the VM enumeration and opcode metadata tables, the interpreter dispatch, and the disassembler that prints human-readable operands.【F:src/NuXJS.h†L1536-L1590】【F:src/NuXJS.cpp†L2164-L2184】【F:src/NuXJS.cpp†L2507-L2548】【F:tools/NuXJSREPL.cpp†L262-L289】 Emission sites such as `makeRValue`, assignment helpers, and delete handling must choose the closure variants when `ExpressionResult::CLOSURE` is present instead of routing through constant-pool strings.【F:src/NuXJS.cpp†L3313-L3368】【F:src/NuXJS.cpp†L3582-L3589】【F:src/NuXJS.cpp†L3975-L3980】

To minimize bytecode size we can reuse the existing signed-index convention: negative values denote `var` slots, non-negative values denote parameters. The depth operand can be a small unsigned integer since closures rarely nest deeply; the compiler should validate it against the maximum supported depth and fall back to `NAMED` if an overflow occurs.

Because nested functions are compiled into standalone `Code` objects, the emitted opcodes also need a per-function relocation table that maps operand indices back to the canonical parent frame. One approach is to reserve a `Vector<CapturedBinding>` inside each `Code` and write `(depth, slot)` tuples into that array; the bytecode operand would then be a short index into the captured table rather than storing both numbers inline. Interpreter helpers can dereference the table via `frame->code->capturedBindings[index]` to recover the coordinates.

#### Interpreter execution path
`Processor::innerRun` handles `READ_LOCAL_OP` by indexing the active frame’s `localsPointer`, while `READ_NAMED_OP` still delegates to scope-chain hashing when a binding remains dynamic.【F:src/NuXJS.cpp†L2502-L2549】【F:src/NuXJS.cpp†L1997-L2042】 With closure metadata available, the interpreter first asks the current `Scope` to `resolveClosureOperand`; when the guard policy deems the capture safe, that helper walks cached `FunctionScope` parents, computes the `(depth, slot)` address, and copies or updates the value directly so no hash probes occur on the fast path.【F:src/NuXJS.cpp†L2507-L2548】【F:src/NuXJS.cpp†L1964-L2104】 If any scope in the chain reports failure—because a `with`, `catch`, or `eval` frame intervened—the opcode falls back to `Scope::readVar` / `writeVar` / `deleteVar` using the stored identifier name, preserving the observable semantics while still leveraging named-resolution error handling.【F:src/NuXJS.cpp†L2507-L2548】【F:src/NuXJS.cpp†L2732-L2739】

To keep the dynamic scopes honest at runtime, both `Processor::EvalScope` and `Processor::WithScope` now reject captured-slot resolution outright so the interpreter always reverts to the generic name walk whenever one of those frames is active.【F:src/NuXJS.cpp†L2322-L2333】【F:src/NuXJS.cpp†L2336-L2361】 Fresh regression coverage exercises `with`, `catch`, and direct `eval` combinations to confirm the guard path observes updates introduced through dynamic scope objects or eval-introduced bindings.【F:tests/regression/closureDynamicScopeGuards20250209.io†L1-L24】

We also need to thread the captured-binding table through activation setup: when `GEN_FUNC_OP` creates a `JSFunction`, it already snapshots the current `Scope` chain via `scope->makeClosure()` and stores the pointer on the new function.【F:src/NuXJS.cpp†L2628-L2669】 With closure opcodes in play, `JSFunction` needs to retain the compiled binding descriptors so that `FunctionScope` can materialize a random-access view of parent slots during `FunctionScope` construction. Extending `FunctionScope` with a helper like `Value* FunctionScope::resolveCapturedSlot(const CapturedBinding&)` keeps all pointer arithmetic localized next to the existing bloom-filter fast paths.【F:src/NuXJS.cpp†L1997-L2067】

#### Interactions with dynamic scope constructs
Only constructs that actually reshape the scope chain at runtime need to suppress compile-time captures, and the ES3 spec limits those to `with` statements and `catch` clauses.【F:docs/specs/ECMA-262 3.md†L1768-L1780】【F:docs/specs/ECMA-262 3.md†L3296-L3327】【F:docs/specs/ECMA-262 3.md†L3475-L3483】 The resulting policy is:

* **`with` blocks.** Because `WithScope` injects object properties ahead of lexical slots, any function defined while `withScopeCounter` is non-zero must inherit `allowClosureSlots = false` so the compiler emits `READ_NAMED_OP` and lets runtime hashing honour the augmented scope chain.【F:src/NuXJS.cpp†L2301-L2324】【F:src/NuXJS.cpp†L4048-L4055】 Closures created outside the `with` automatically regain the fast path once the counter drops back to zero.
* **`catch` clauses.** The catch parameter lives in a dedicated `CatchScope`, and the compiler already tags the active identifier with `CATCH_PARAMETER` so locals (and therefore captures) refuse fast binding while it is in scope.【F:src/NuXJS.cpp†L2263-L2288】【F:src/NuXJS.cpp†L3737-L3755】【F:src/NuXJS.cpp†L3893-L3917】 No new guard bits are required: once the catch block ends, the sentinel is cleared and outer locals become eligible again.
* **Direct `eval`.** Direct eval reuses the caller’s scope chain but routes new bindings through `EvalScope::declareVar`, which in turn lands them inside the parent’s `dynamicVars` table.【F:src/NuXJS.cpp†L2245-L2254】【F:src/NuXJS.cpp†L2010-L2104】 Since compile-time captures only target slots that already exist in `nameIndexes`, they never bypass `dynamicVars`, so no extra guard is needed. This keeps behaviour aligned with the spec’s rule that eval shares (but does not extend) the lexical environment of its caller.【F:docs/specs/ECMA-262 3.md†L1768-L1834】【F:docs/specs/ECMA-262 3.md†L3750-L3761】

#### Source touchpoints summary
Implementing compile-time upvalue slots would require coordinated edits in:

* `Compiler` symbol tracking and emission helpers for new `ExpressionResult` types and environment descriptors.【F:src/NuXJS.cpp†L2876-L2939】【F:src/NuXJS.cpp†L3893-L3933】
* `Code` metadata to persist captured-slot tables per function (likely next to `varNames`/`argumentNames`) so closures can serialize depth/slot descriptors alongside bytecode.【F:src/NuXJS.h†L825-L848】 This includes updating serialization helpers, GC tracing, and any tooling that inspects `Code::nameIndexes`.
* `Processor::Opcode` definitions, opcode metadata, and interpreter dispatch for the new closure opcodes.【F:src/NuXJS.h†L1521-L1573】【F:src/NuXJS.cpp†L2628-L2704】 Additional helpers in `Processor::FunctionFrame` may be needed to cache ancestor `FunctionScope` pointers when walking the closure depth repeatedly inside hot loops.
* Scope classes to expose safe slot accessors, including validation that captured slots live in `FunctionScope` instances and that dynamic scopes remain observable to debugging/profiling tooling.【F:src/NuXJS.h†L825-L843】【F:src/NuXJS.cpp†L1997-L2068】 `EvalScope`, `CatchScope`, and `WithScope` already forward to their parent scopes; the closure helpers just need to keep using those objects whenever `allowClosureSlots` is false.

#### Minimal implementation pass (post-review)
Re-reading the VM and compiler surfaces a smaller critical path for the first iteration:

1. **Augment `Code`.** Add `Vector<CapturedBinding> capturedBindings` plus helper accessors. Each entry mirrors the existing signed-slot layout—no guard bits required—so the interpreter can index into `localsPointer` exactly as `FunctionScope::readVar` already does.【F:src/NuXJS.h†L825-L843】【F:src/NuXJS.cpp†L1997-L2052】 While doing so, update `Code::gcMarkReferences` to trace each captured binding’s `name` pointer so the GC retains the interned identifiers needed for named fallbacks and diagnostics.【F:src/NuXJS.h†L842-L874】
2. **Extend `Compiler`.**
   * Pass a `CapturedLexicalContext` pointer when constructing nested compilers so they inherit the parent’s `Code` handle and the `allowClosureSlots` flag derived from `withScopeCounter`.【F:src/NuXJS.cpp†L3737-L3795】【F:src/NuXJS.cpp†L4048-L4055】
   * Update `identifier` to probe ancestor contexts via `Code::lookupNameIndex` and emit `ExpressionResult::CLOSURE(depth, slot)` whenever the inherited flag is true, falling back to `NAMED` otherwise.【F:src/NuXJS.cpp†L2876-L2939】【F:src/NuXJS.cpp†L3848-L3926】 Catch sentinels and `arguments` continue to steer lookups away from closure slots automatically.【F:src/NuXJS.cpp†L3850-L3858】【F:src/NuXJS.cpp†L3893-L3917】
   * When finalizing a child function, serialize its collected captures into `code->capturedBindings` in the same order they were referenced so bytecode operands can be compact indices.【F:src/NuXJS.cpp†L4562-L4594】
3. **Add closure opcodes.** Introduce `READ_CLOSURE_OP`, `WRITE_CLOSURE_OP`, and `WRITE_CLOSURE_POP_OP` that accept a captured-binding index. The opcode table, assembler, and interpreter dispatch already centralize operand decoding, so the new handlers simply load the descriptor and index into the appropriate ancestor frame.【F:src/NuXJS.h†L1521-L1573】【F:src/NuXJS.cpp†L2628-L2704】
4. **Teach `FunctionScope` about captures.** Store parent `FunctionScope*` pointers during `enterFunctionCode` and expose a `resolveCapturedSlot` helper that walks `depth` links before applying the signed slot offset against `localsPointer`. The helper can assert that the slot lives in a function frame because catch/with guards have already been applied.【F:src/NuXJS.cpp†L1997-L2104】【F:src/NuXJS.cpp†L2628-L2669】
5. **Guard dynamic scopes.** Only `with` needs explicit suppression: propagate `allowClosureSlots = false` while `withScopeCounter` is non-zero so captures compiled under those constructs automatically fall back to `READ_NAMED_OP`. Catch parameters and eval-introduced bindings are already covered by existing tables and `dynamicVars` plumbing.【F:src/NuXJS.cpp†L3850-L3858】【F:src/NuXJS.cpp†L4048-L4055】【F:src/NuXJS.cpp†L2010-L2104】

This pared-down sequence keeps the first milestone focused on plumbing concrete slot indices end-to-end. Follow-up steps (like caching ancestor frame pointers) remain optional optimizations once correctness and spec guards are validated.

##### Parent-scope caching follow-up

`Processor::Frame::resolvedClosureSlots` now caches the first successful resolution of each closure operand within an activation, so the interpreter only walks the `parentFunctionScope` chain once before reusing the computed pointer.【F:src/NuXJS.h†L1680-L1708】【F:src/NuXJS.cpp†L2532-L2603】 The cache stores both the owning `FunctionScope` and the concrete slot address, and `Frame::gcMarkReferences` marks each cached scope so garbage collection retains the captured activation.【F:src/NuXJS.h†L1680-L1708】 Later reads, writes, and deletes therefore bypass the depth loop entirely while remaining guarded by the same dynamic-scope checks. A potential follow-up could promote this cache to the `JSFunction` instance so repeated invocations share resolved slots across activations, but that would require proving the cached `FunctionScope` survives for the closure’s lifetime and remains safe under recursion or re-entrancy.【F:src/NuXJS.cpp†L2628-L2669】

Addressing these areas together would let the compiler emit closure-aware bytecode while falling back gracefully in the presence of dynamic scope features that could invalidate compile-time assumptions.

#### Feasibility and uncertainty analysis
Although the control points above map the mechanical edits, the amount of refactoring they imply is significant and carries several risks:

* **Compiler state sharing requires invasive surgery.** Nested functions today spin up fresh `Compiler` instances with isolated symbol tables, so no infrastructure exists for reusing parent lexical metadata or even referencing the outer compiler once construction finishes.【F:src/NuXJS.cpp†L3737-L3748】【F:src/NuXJS.cpp†L4527-L4573】 Building the descriptor stack therefore demands redesigning how scopes are plumbed through parsing, revalidating every site that assumes the `Compiler` is self-contained, and ensuring that error recovery/rollback logic still works. The churn is high because identifier lookup code is scattered across expression parsing helpers and hoist handling.【F:src/NuXJS.cpp†L2876-L2939】【F:src/NuXJS.cpp†L3893-L4049】
* **Dynamic-scope guards are easy to misapply.** The only explicit guard we need is the `withScopeCounter` handoff, but it still has to align with every parser path that can nest a `with`. Missing a decrement or forgetting to propagate the flag to a child compiler would let closure opcodes bypass the `WithScope`, producing observable misbindings.【F:src/NuXJS.cpp†L2249-L2334】【F:src/NuXJS.cpp†L4048-L4055】 The catch sentinel and eval plumbing are already in place, yet they should be revalidated once closure metadata flows through the compiler.
* **Bytecode/VM changes ripple across tooling.** Adding closure opcodes requires touching the opcode enum, assembler, disassembler, debugger, and serialization logic; every consumer assumes the current contiguous ranges and operand encodings.【F:src/NuXJS.h†L1521-L1573】【F:src/NuXJS.cpp†L2628-L2704】 The uncertainty lies in validating all downstream tools (pretty-printers, tests, inspector UIs) because failures often surface only at runtime.
* **Activation lifetime and GC interactions must be audited.** `GEN_FUNC_OP` snapshots the scope chain, and `FunctionScope::makeClosure` / `writeVar` already cooperate with garbage collection and `arguments` aliasing.【F:src/NuXJS.cpp†L1997-L2067】【F:src/NuXJS.cpp†L2628-L2669】 Introducing captured-slot tables and cross-frame pointers risks leaking stale references or bypassing the dynamic-object writes that keep `arguments` in sync. Proving correctness requires stress tests around eval-induced rebindings, catch scopes, and nested `with` blocks.

Overall the endeavour is feasible but difficult: it spans parser plumbing, bytecode formats, interpreter execution, and runtime semantics that are currently only loosely coupled. Expect a multi-phase implementation with heavy validation to ensure spec-visible behaviour remains intact under every combination of dynamic scope features.

#### ES3 conformance checkpoints
The ES3 spec defines lexical resolution strictly in terms of scope-chain walks and explicitly calls out the constructs that may extend that chain (`with`, `catch`, and direct `eval`).【F:docs/specs/ECMA-262 3.md†L1768-L1780】【F:docs/specs/ECMA-262 3.md†L3296-L3327】【F:docs/specs/ECMA-262 3.md†L3475-L3483】【F:docs/specs/ECMA-262 3.md†L3750-L3761】 The revised plan mirrors those rules: `with` scopes flip `allowClosureSlots` off, catch parameters keep using the existing sentinel, and eval-induced bindings remain observable through `dynamicVars`. Because arguments properties share storage with activation slots, we continue to route updates through the same memory locations, preserving the aliasing described in the spec.【F:docs/specs/ECMA-262 3.md†L1810-L1813】【F:src/NuXJS.cpp†L1997-L2067】 Together these checks keep the optimization compliant while still unlocking faster closure access.

### 2. Runtime binding caches
A less invasive alternative is to keep emitting `READ_NAMED_OP` yet cache the resolution the first time each opcode executes within a given closure.

* Augment `Code` with an auxiliary vector keyed by constant index that stores an optional `(depth, slot, flags)` tuple once it has been discovered at runtime. The interpreter can check the cache before falling back to `scope->readVar`.
* On a miss, perform today’s lookup, and if the winning scope is a `FunctionScope` slot (as opposed to `dynamicVars` or `with`/global objects) record the descriptor so later executions jump directly to the right parent and index.【F:src/NuXJS.cpp†L2020-L2039】【F:src/NuXJS.cpp†L2473-L2503】
* Writes and deletes can share the cache: once the tuple is known, `WRITE_NAMED_OP` can skip the hash-table probe and update the slot directly, while deletions that target lexical slots still return `false` immediately.
* Guard the cache with invalidation checks for dynamic features. For instance, if `withScopeCounter` or a direct `eval` occurs in the frame, skip caching; similarly, if resolution fell through to `dynamicVars` or the global object, keep using the generic path.【F:src/NuXJS.cpp†L2010-L2104】【F:src/NuXJS.cpp†L4048-L4055】

This strategy keeps the compiler untouched and confines the work to the VM plus some metadata plumbing. The first access still pays the current cost, but all subsequent accesses while the closure lives become slot lookups without hashing.

### 3. Precomputed scope-slot tables per activation
Another pragmatic option is to build (once per activation) a small array of parent slot pointers that mirrors the lexical chain. When `FunctionScope` is constructed, it can walk its `parentScope` links, collecting pointers to each ancestor’s `localsPointer` and maybe the bloom filters for quick rejects.【F:src/NuXJS.cpp†L1997-L2067】 `READ_NAMED_OP` would still hash the identifier in the first scope, but once it knows the ancestor index, it can index directly into the cached pointer array on future hits. This keeps bytecode unchanged yet amortizes the parent traversal cost. The trade-off is higher per-call memory and the need to refresh the tables whenever intermediate scopes such as `CatchScope` or `WithScope` are pushed/popped.【F:src/NuXJS.cpp†L2249-L2287】【F:src/NuXJS.cpp†L2305-L2327】

## Tooling visibility updates
* The REPL disassembler now prints the number of captured bindings for each function and dumps the `(depth, slot)` table with friendly names so captured-slot opcodes are easy to interpret when debugging bytecode.【F:tools/NuXJSREPL.cpp†L296-L313】
* Legacy console tooling mirrors the same summary, including per-entry names, so script developers can inspect closure metadata without attaching the full debugger.【F:tools/work/LegacyReplTests.cpp†L332-L380】

## Regression coverage
* Added `closureCapturedSlotsBasics20250210.io` to lock in direct, aliased, and multi-level closure behaviour across the new opcodes, keeping the fast path under test when nested functions mutate parameters or capture grandparent slots.【F:tests/regression/closureCapturedSlotsBasics20250210.io†L1-L51】

## Performance sampling
* Running the release interpreter on a microbenchmark that repeatedly increments a captured variable shows the closure-slot path finishing a 20 000-iteration harness in about 2 s, whereas the same workload forced through a named lookup takes roughly 7 s, demonstrating the win from bypassing hash-based scope resolution.【0106d6†L1】【204917†L1-L2】

## Considerations and open questions
* **Dynamic scope semantics.** Any solution must respect `with`, direct `eval`, and dynamically declared vars. The compiler already tracks `withScopeCounter`, and the runtime routes eval-created bindings into `dynamicVars`; both signals can be reused to disable caching where correctness would otherwise break.【F:src/NuXJS.cpp†L2010-L2104】【F:src/NuXJS.cpp†L4048-L4055】
* **Arguments aliasing.** Parameters share storage with the `arguments` object until it is detached. Fast paths must keep writing through the canonical slot so that aliasing semantics are preserved.【F:src/NuXJS.cpp†L1997-L2059】
* **Opcode and constant encoding.** Introducing new opcodes requires updating the assembler/disassembler tables and potentially regenerating tests; caching schemes need space in `Code` (or per-frame structures) without inflating the constant pool’s GC pressure.【F:src/NuXJS.cpp†L2156-L2676】
* **Debug tooling.** Features such as the REPL or debugger depend on the ability to materialize scopes dynamically. Any metadata produced for fast binding should be exposed (or at least understood) by those tools so that inspecting closures remains accurate.

## Recommended next steps
1. Prototype the runtime cache because it touches fewer subsystems: instrument the interpreter to record cache hit/miss rates and confirm that typical closures resolve to lexical slots rather than dynamic objects.
2. If the win is material, formalize the cache data structure and port `WRITE_NAMED_OP` / `DELETE_NAMED_OP` to use it.
3. In parallel, sketch the compiler changes needed for true upvalue opcodes so that we can compare complexity versus speedup. The runtime cache can coexist as a stepping stone toward the more ambitious compile-time solution.
