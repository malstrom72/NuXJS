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

### 1. Compile-time upvalue slots

#### Overview
The present compiler launches a fresh `Compiler` instance for every nested function, which severs access to the parent’s lexical tables; as a result, captured identifiers are emitted as generic `NAMED` references that defer binding to runtime scope hashing.【F:src/NuXJS.cpp†L2876-L2891】【F:src/NuXJS.cpp†L3737-L3748】 A compile-time upvalue scheme must therefore propagate symbol metadata from the outer compiler so that inner emissions can encode concrete `(depth, slot)` coordinates.

#### Front-end data structures and symbol plumbing
`Compiler` today only remembers the current function’s `Code::nameIndexes`, populating it via `declareIdentifier` when new variables are declared or parameters parsed.【F:src/NuXJS.h†L825-L848】【F:src/NuXJS.cpp†L3893-L3933】【F:src/NuXJS.cpp†L4562-L4594】 A second pass over the sources shows we can seed closure metadata with fewer moving parts than originally outlined:

* Rather than inventing a parallel descriptor stack, extend `SemanticScope` with optional lexical data (a pointer to the owning `Code`, a view of the parent’s `nameIndexes`, and a single “safe for lexical capture” flag). The struct is already allocated for every syntactic scope and threaded through `statementList`, so we can attach a `CapturedLexical*` payload without altering traversal sites.【F:src/NuXJS.cpp†L2893-L2955】【F:src/NuXJS.cpp†L4459-L4543】
* Share existing binding tables. When `functionDefinition` spawns a child compiler, pass a lightweight `CapturedLexical` struct that references the parent `Code` and exposes `lookupNameIndex` directly, instead of copying symbol data into ad-hoc vectors.【F:src/NuXJS.cpp†L3737-L3795】【F:src/NuXJS.h†L825-L836】 Because `lookupNameIndex` already distinguishes arguments (>= 0) from vars (< 0) and `varNames` is stored in reverse to line up with `localsPointer`, the compiler only needs to cache the signed index along with the inherited `bool allowClosureSlots` flag.【F:src/NuXJS.h†L825-L848】【F:src/NuXJS.cpp†L1997-L2047】
* Reuse `declareIdentifier` as the single place that pushes locals into the fast-path table. The helper already refuses to return a local index when `withScopeCounter` is non-zero or the target is the synthetic catch parameter (`CATCH_PARAMETER`).【F:src/NuXJS.cpp†L3893-L3917】【F:src/NuXJS.cpp†L3737-L3755】 Propagating the same boolean to descendants keeps the new closure metadata aligned with the existing fast-path rules for `with` and catch bindings.【F:src/NuXJS.cpp†L4048-L4055】【F:src/NuXJS.cpp†L3751-L3754】
* Thread a minimal `(depth, slot)` payload through `ExpressionResult`. The parser currently sets `ExpressionResult::LOCAL` when an identifier matches the current frame; we only need an extra variant that carries the depth and reuses the existing signed-slot convention. Touchpoints are limited to `identifier`, `optionalExpression`, and the assignment helpers that already switch on `ExpressionResult::Type`.【F:src/NuXJS.cpp†L2876-L2939】【F:src/NuXJS.cpp†L3244-L3274】

Once `functionDefinition` copies the collected captures into the nested `Code` (mirroring how it already finalizes `argumentNames` and `varNames`), the VM can serialize the metadata next to bytecode words without reshaping the compiler pipeline.【F:src/NuXJS.cpp†L3737-L3795】【F:src/NuXJS.cpp†L4562-L4594】 A `Vector<CapturedBinding>` on `Code` is still required, but it only needs to retain `(depth, slot)` pairs sourced directly from existing tables.

#### CapturedBinding record layout
`CapturedBinding` should stay as small as possible so indexing into the table mirrors today’s local-slot arithmetic. Each entry can store:

* `UInt16 depth` – how many `FunctionScope` hops to walk before dereferencing the slot.
* `Int16 slot` – the signed index returned by `Code::lookupNameIndex`, where negative values address `var` slots via `~slot` and non-negative values index the argument tail that starts at `localsPointer`.【F:src/NuXJS.h†L825-L843】【F:src/NuXJS.cpp†L1997-L2052】

No extra flags are necessary on the descriptor itself. Catch parameters already poison their entry in `nameIndexes` with `CATCH_PARAMETER`, so lookups simply fail while that sentinel is active.【F:src/NuXJS.cpp†L3893-L3917】【F:src/NuXJS.cpp†L3751-L3754】【F:src/NuXJS.cpp†L4304-L4336】 `arguments` is excluded by the same fast-path check, which prevents emitting closure records for bindings that flow through `dynamicVars` instead.【F:src/NuXJS.cpp†L3850-L3858】【F:src/NuXJS.cpp†L2010-L2104】 This keeps the runtime representation identical to the layout that `FunctionScope` already expects.

#### Identifier analysis workflow
With the contextual chain in place, the lookup steps become:

1. Perform today’s local lookup through `code->nameIndexes` to preserve the fast path for the current frame.【F:src/NuXJS.cpp†L3848-L3917】
2. If no local slot matches, walk the linked `CapturedLexical` contexts (one per ancestor function). Each node calls `lookupNameIndex` on its `Code` and, on success, packages `(depth, slot)` into the expression tree.
3. If a context’s `allowClosureSlots` flag is false, stop the walk and fall back to a `NAMED` expression so runtime hashing preserves spec semantics. Today the flag is cleared only when the ancestor was parsed under an active `with`, because that construct injects object properties ahead of lexical slots in the scope chain.【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4240-L4249】【F:docs/specs/ECMA-262 3.md†L3296-L3327】 Catch sentinels and `arguments` filtering continue to block unsafe captures implicitly, and direct eval shares the fast path because new bindings land in `dynamicVars` rather than the indexed slot array.【F:src/NuXJS.cpp†L3893-L3925】【F:src/NuXJS.cpp†L2019-L2059】【F:docs/specs/ECMA-262 3.md†L1768-L1834】

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

1. **Statement-list pre-pass.** Before `functionDefinition` instantiates a child compiler, run a lightweight scan over the remaining tokens in the current statement list and flip `allowClosureSlots` to `false` if a `with` statement or syntactic direct `eval` is present.【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4032-L4048】【F:src/NuXJS.cpp†L4240-L4249】 The scan can reuse `statementList`’s existing loop (which already walks the upcoming statements without mutating state) and only needs to detect tokens that eventually increment `withScopeCounter` or emit `CALL_EVAL_OP`. This keeps the emitted bytecode unchanged and ensures every nested compiler inherits the most conservative guard before any capture analysis runs. The trade-off is the extra parsing work: the pass must either duplicate tokenization logic or create a peeking helper that can recognise `with`/`eval` without consuming the input stream, otherwise the parser state would need to be rewound carefully.

2. **Deferred nested compilation.** Instead of compiling nested functions immediately, record their parse locations and postpone the actual `functionDefinition` call until the surrounding statement (or even the entire body) has been processed.【F:src/NuXJS.cpp†L3965-L4049】【F:src/NuXJS.cpp†L4200-L4238】 By the time deferred compilation occurs, any `with` or direct-eval constructs encountered later in the outer body will already have dropped `allowClosureSlots`, so the child compilers inherit the correct guard automatically. This approach aligns with traditional two-pass hoisting strategies but requires significant refactoring: `functionStatement` currently emits `GEN_FUNC_OP` and updates the hoist table immediately, so deferral would need bookkeeping to store pending function ASTs and to replay their compilation after the guard state stabilises.

3. **Retroactive capture invalidation.** Keep the eager compilation flow but maintain a list of nested `Code` objects created so far; when the parser later encounters a `with` or direct-eval that would have disabled fast bindings, walk that list and scrub their captured-binding tables (for example by clearing `code->capturedBindings` and rewriting any closure opcodes back to `READ_NAMED_OP`).【F:src/NuXJS.cpp†L3876-L3891】【F:src/NuXJS.cpp†L4043-L4050】【F:src/NuXJS.cpp†L4750-L4752】 Because each `Code` object keeps its `Vector<CapturedBinding>` mutable until compilation finishes, the compiler could still patch the instruction stream before handing the function to the runtime. The difficulty lies in tracking every opcode location that referenced a captured binding and ensuring the rewrite covers deletes, reads, and writes in all code sections; missing a site would leave stale fast-path instructions that violate spec semantics once the late `with` executes.

4. **Runtime guard handshake.** Allow compile-time captures to proceed optimistically but teach `FunctionScope::resolveCapturedBinding` (and the closure opcodes that call it) to validate that the activation chain contains only other `FunctionScope` frames before honouring the cached `(depth, slot)` coordinates.【F:src/NuXJS.cpp†L2020-L2156】【F:src/NuXJS.cpp†L2800-L2807】 When a `WITH_SCOPE_OP` or `EvalScope` frame is pushed at runtime, the guard would force `resolveCapturedBinding` to fail, causing the interpreter to fall back to the existing `readVar`/`writeVar` helpers that honour dynamic scope semantics.【F:src/NuXJS.cpp†L2820-L2833】【F:src/NuXJS.cpp†L2304-L2436】 This hybrid design guarantees correctness even if the parser missed a late guard, but it shifts work to the hot path: every closure access must check for dynamic frames and may still pay the slow lookup cost if a `with` or `eval` executed. It also requires storing enough metadata on each `Scope` to distinguish lexical frames from dynamic ones so the validation can run without extra hashing.

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
- Extend `statementList` with a lightweight guard scan and thread the summary into `functionDefinition` so `allowClosureSlots` is set before constructing the child `Compiler`.
- New helper expected to add roughly **80–120 SLOC** spread across the lexer utilities and the guard summary structure.

**Solution 2 – Deferred nested compilation**

*Pros*
- Postponing `functionDefinition` until the outer statement list completes ensures every guard flip (e.g. `with` pushing `withScopeCounter`) is observed before nested compilers are created.【F:src/NuXJS.cpp†L4231-L4249】【F:src/NuXJS.cpp†L3876-L3889】
- Because the parent finishes running `declareIdentifier` for the whole body before the deferred compilation occurs, inner functions finally see `nameIndexes` populated with later `var` declarations, enabling more fast bindings beyond hoisted declarations.【F:src/NuXJS.cpp†L4085-L4125】

*Cons*
- Needs bookkeeping for pending function bodies (source spans, hoist targets, captured-name lists) so the compiler can replay them after the body finishes without violating hoist semantics.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4755-L4787】
- Forces larger structural changes to the parser because `functionStatement` currently emits bytecode immediately and assumes the child `Code` exists for hoist initialisation.【F:src/NuXJS.cpp†L4231-L4237】

*Implementation notes*
- Requires a `PendingFunction` list, delayed `emitWithConstant` calls, and a clean-up phase when `statementList` sees the closing `}`.
- Estimated **220–260 SLOC** once data structures, replay hooks, and error handling are included.

**Solution 3 – Retroactive capture invalidation**

*Pros*
- Reuses the existing `capturedBindings` table and instruction stream so early compiles proceed unchanged; only guard violations trigger rewrites before `code->codeWords` is sealed.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L4744-L4752】
- Avoids recompiling whole functions—unsafe captures are simply rewritten back to `READ_NAMED_OP`/`WRITE_NAMED_OP` using the original identifier.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Must track every opcode location that referenced a captured binding so the scrubber can restore the named operand reliably; missing a site leaves incorrect fast-path bytecode behind.【F:src/NuXJS.cpp†L3893-L3929】【F:src/NuXJS.cpp†L2559-L2609】
- Keeps the `CapturedBinding` vector and `name` pointer alive even after invalidation because the interpreter needs those strings for the fallback helpers.【F:src/NuXJS.cpp†L2559-L2609】

*Implementation notes*
- Introduce a per-function patch list and mutate `code->codeWords` plus `capturedBindings` prior to finalisation.
- Expect approximately **140–180 SLOC**, dominated by the invalidation walker and opcode rewrite helpers.

**Solution 4 – Runtime guard handshake**

*Pros*
- Minimal compiler churn: rely on `FunctionScope::resolveCapturedBinding` to refuse resolutions whenever a dynamic scope intervenes, reusing today’s runtime guard surface.【F:src/NuXJS.cpp†L2138-L2155】【F:src/NuXJS.cpp†L2304-L2363】
- Guarantees correctness even if the parser misses a hazard, because the interpreter falls back to `readVar`/`writeVar` when the guard fails.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Adds runtime overhead to every closure access—the interpreter must probe `resolveCapturedBinding` and often rerun the full named lookup when a `WithScope` or `EvalScope` is active.【F:src/NuXJS.cpp†L2559-L2609】【F:src/NuXJS.cpp†L2304-L2363】
- Cannot drop `CapturedBinding::name` because the fallback path still needs the identifier string for error messages and dynamic lookups.【F:src/NuXJS.cpp†L2559-L2609】

*Implementation notes*
- Mostly tweaks to the existing guard checks and perhaps a cheap `isLexicalFrame` flag on `Scope`.
- Roughly **40–60 SLOC** to thread the validation into the closure opcodes and add fast failure paths.

**Solution 5 – Token-buffer guard pass**

*Pros*
- `compileFunction` already captures raw pointers to the body, making it feasible to lex the full span into a temporary buffer and compute guard metadata before any nested compilation runs.【F:src/NuXJS.cpp†L4755-L4787】
- With the guard settled up front, child compilers can safely emit closure operands and drop auxiliary binding tables for eligible captures.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L3893-L3901】

*Cons*
- Doubles lexing work for large functions and demands extra memory to stash the buffered tokens during the real parse.【F:src/NuXJS.cpp†L4755-L4787】
- Still leaves late `var` hoisting unsolved unless the buffer is also analysed for declarations, which increases the complexity of the pre-pass substantially.【F:src/NuXJS.cpp†L4085-L4125】

*Implementation notes*
- Requires a new tokenisation helper, guard summary structure, and integration with `functionDefinition`.
- Implementation likely lands around **200–230 SLOC** including buffering, scanning, and clean-up code.

**Solution 6 – Pending-closure finalisation barrier**

*Pros*
- Keeps the single-pass parser intact while delaying opcode commitment: nested `functionDefinition` calls queue their binding metadata, and a final sweep decides whether to emit closure or named opcodes before `code->codeWords` is frozen.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4744-L4752】
- Allows dropping the per-function binding array once operands are rewritten, because only the chosen opcode reaches the VM.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Needs placeholder opcodes and relocation tables so the late pass can patch both reads and writes without disturbing stack accounting in `CodeSection::emit`.【F:src/NuXJS.cpp†L3098-L3115】
- Hoist bookkeeping becomes trickier because the compiler must ensure queued closures are materialised before any code that depends on them is emitted.【F:src/NuXJS.cpp†L4231-L4237】

*Implementation notes*
- Introduce `PendingClosure` records, add a commit phase to `statementList`, and update GC tracing for provisional metadata.
- Estimated **170–210 SLOC** once queue management and patching utilities are included.

**Solution 7 – Dual-path emission with late selection**

*Pros*
- Emits both closure and named variants up front so the final selection is a simple pruning step once the guard state is known, eliminating recomputation cost.【F:src/NuXJS.cpp†L3893-L3929】【F:src/NuXJS.cpp†L3313-L3368】
- Guarantees a valid fallback is always available, reducing the risk of spec violations when hazards appear late.【F:src/NuXJS.cpp†L2559-L2609】

*Cons*
- Temporarily doubles instruction and constant-pool usage until the pruning pass runs, increasing compilation time and memory pressure for large scripts.【F:src/NuXJS.cpp†L3098-L3115】
- Still requires a late commit pass to delete the unused opcode, so it inherits part of the complexity of solution 6 without shedding the extra emission cost.【F:src/NuXJS.cpp†L4744-L4752】

*Implementation notes*
- Needs paired placeholder structures, pruning logic, and assembler/disassembler updates to ignore the discarded path.
- Roughly **160–190 SLOC** encompassing the dual emission, tracking, and final selection stages.

**Solution 8 – Guard-triggered recompilation handshake**

*Pros*
- Builds on existing span knowledge: `functionDefinition` already captures the nested body’s `[begin, end)` pointers, so the compiler can re-run `compileFunction` with the definitive guard once the outer body finishes scanning hazards such as `with` or direct `eval` calls.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L3805-L3814】【F:src/NuXJS.cpp†L4240-L4249】
- Guard flips are rare, so most functions compile only once; when a recompile is needed, the second pass can inline `(ancestorDistance, slotOffset)` operands and omit the captured-binding table entirely, leaving the final bytecode as compact as the pure fast-path design.【F:src/NuXJS.cpp†L3893-L3901】【F:src/NuXJS.cpp†L2559-L2609】
- Re-running the child compilation after the outer statement list has processed every declaration lets it see the fully populated `nameIndexes`, unlocking fast bindings for locals declared later in the body in addition to hoisted ones.【F:src/NuXJS.cpp†L4085-L4125】【F:src/NuXJS.cpp†L4714-L4719】

*Cons*
- Requires storing per-closure metadata (source span, captured-name attempts, hoist target) so the second pass can rebuild the `Code` safely and reinstall the hoisted function reference before finalising `code->codeWords` and constant tables.【F:src/NuXJS.cpp†L4231-L4237】【F:src/NuXJS.cpp†L4744-L4752】
- Needs careful integration with GC and error recovery because the speculative `Code` object must be replaced or reset without leaking allocations if the second pass throws an exception mid-compilation.【F:src/NuXJS.cpp†L3876-L3889】【F:src/NuXJS.cpp†L4755-L4787】

*Implementation notes*
- Add a `PendingRecompile` list keyed by the function span, trigger recompilation when `allowClosureSlots` flips, and replace the original bytecode before finalising the parent function.
- Expect **220–280 SLOC** split between metadata storage, recompilation hooks, and bytecode replacement. The recompilation step can share most of the existing `compileFunction` machinery, limiting new logic to bookkeeping rather than rewriting the parser.

Without one of these adjustments, closures created before the guard flips could still execute while a `WithScope` or `EvalScope` sits between them and the target frame, violating the spec’s lookup order. Although the runtime will fall back when such scopes are present—`EvalScope` and `WithScope` explicitly refuse captured-slot resolution, and the `CATCH_PARAMETER` sentinel blocks catch bindings from ever entering the fast table【F:src/NuXJS.cpp†L2300-L2337】【F:src/NuXJS.cpp†L2357-L2379】【F:src/NuXJS.cpp†L3891-L3925】【F:src/NuXJS.cpp†L4516-L4533】【F:src/NuXJS.cpp†L2565-L2603】—the bytecode emitted ahead of time would still be incorrect. Guarding the compilation phase prevents those invalid opcodes from ever materializing.

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

Here the closure would read the wrong value if we bypassed the object environment. A hypothetical fast-path that ignored `with` would still address the outer slot `x = 1`, so `factory({ x: 42 })()` would incorrectly produce `1` instead of the spec-mandated `42`. NuXJS prevents that by incrementing `withScopeCounter` during parsing so any identifier captured inside the block sticks to the named path, and by making `WithScope::resolveCapturedBinding` bail out when the interpreter encounters a precomputed slot under an active `with` guard.【F:src/NuXJS.cpp†L4240-L4249】【F:src/NuXJS.cpp†L2361-L2364】【F:src/NuXJS.cpp†L4032-L4040】 Those checks ensure `(depth, slot)` operands are never emitted for closures that actually need the dynamic lookup.

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

NuXJS mirrors this behaviour by storing a `CATCH_PARAMETER` sentinel in `nameIndexes` so the identifier never upgrades to a slot binding, then restoring the original entry once the block ends.【F:src/NuXJS.cpp†L4505-L4533】 If we forced a `(depth, slot)` operand here, the closure would continue to read the outer lexical `x = 1`, breaking the ES3 guarantee that the handler-local `x` shadows the outer binding. Combined with `CatchScope::resolveCapturedBinding` forwarding rules, the runtime falls back to hashed name lookup whenever a closure relies on the handler’s object environment.【F:src/NuXJS.cpp†L3891-L3925】【F:src/NuXJS.cpp†L2322-L2337】【F:src/NuXJS.cpp†L4516-L4533】 These corrected examples demonstrate that the fast path is safe for closures compiled before the dynamic scope appears, while closures created inside `with` or `catch` blocks must retain name-based resolution.

#### Bytecode emission updates
Once resolution yields a concrete upvalue descriptor, the emitter needs dedicated opcodes (e.g. `READ_CLOSURE_OP`, `WRITE_CLOSURE_OP`, `DELETE_CLOSURE_OP`) whose operands encode the ancestor depth and slot. Adding these opcodes touches the VM enumeration and opcode metadata tables, the interpreter dispatch, and the disassembler that prints human-readable operands.【F:src/NuXJS.h†L1536-L1590】【F:src/NuXJS.cpp†L2164-L2184】【F:src/NuXJS.cpp†L2507-L2548】【F:tools/NuXJSREPL.cpp†L262-L289】 Emission sites such as `makeRValue`, assignment helpers, and delete handling must choose the closure variants when `ExpressionResult::CLOSURE` is present instead of routing through constant-pool strings.【F:src/NuXJS.cpp†L3313-L3368】【F:src/NuXJS.cpp†L3582-L3589】【F:src/NuXJS.cpp†L3975-L3980】

To minimize bytecode size we can reuse the existing signed-index convention: negative values denote `var` slots, non-negative values denote parameters. The depth operand can be a small unsigned integer since closures rarely nest deeply; the compiler should validate it against the maximum supported depth and fall back to `NAMED` if an overflow occurs.

Because nested functions are compiled into standalone `Code` objects, the emitted opcodes also need a per-function relocation table that maps operand indices back to the canonical parent frame. One approach is to reserve a `Vector<CapturedBinding>` inside each `Code` and write `(depth, slot)` tuples into that array; the bytecode operand would then be a short index into the captured table rather than storing both numbers inline. Interpreter helpers can dereference the table via `frame->code->capturedBindings[index]` to recover the coordinates.

#### Interpreter execution path
`Processor::innerRun` handles `READ_LOCAL_OP` by indexing the active frame’s `localsPointer`, while `READ_NAMED_OP` still delegates to scope-chain hashing when a binding remains dynamic.【F:src/NuXJS.cpp†L2502-L2549】【F:src/NuXJS.cpp†L1997-L2042】 With closure metadata available, the interpreter first asks the current `Scope` to `resolveCapturedBinding`; when the guard policy deems the capture safe, that helper walks cached `FunctionScope` parents, computes the `(depth, slot)` address, and copies or updates the value directly so no hash probes occur on the fast path.【F:src/NuXJS.cpp†L2507-L2548】【F:src/NuXJS.cpp†L1964-L2104】 If any scope in the chain reports failure—because a `with`, `catch`, or `eval` frame intervened—the opcode falls back to `Scope::readVar` / `writeVar` / `deleteVar` using the stored identifier name, preserving the observable semantics while still leveraging named-resolution error handling.【F:src/NuXJS.cpp†L2507-L2548】【F:src/NuXJS.cpp†L2732-L2739】

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

`FunctionScope::resolveCapturedBinding` still climbs the linked list of parent activations on every closure opcode, following `parentFunctionScope` pointers until the requested depth is reached before touching the slot array.【F:src/NuXJS.cpp†L2140-L2155】【F:src/NuXJS.h†L1077-L1096】 The walk is cheap for shallow nesting but adds branches to each read/write. Once the compile-time descriptors are in place we can consider caching the resolved frame directly when the closure object is created. `GEN_FUNC_OP` already receives the current `Scope*` and freezes it into the `JSFunction`, so the constructor has access to the precise `FunctionScope` chain that the closure needs later.【F:src/NuXJS.cpp†L2770-L2776】【F:src/NuXJS.h†L969-L985】 A follow-up could allocate a parallel `Vector<Value*>` (or `Vector<CapturedSlot>` storing `{FunctionScope*, Value*}`) on the `JSFunction` the first time each captured binding is touched: the runtime would perform the existing climb once, persist the winning `FunctionScope`/slot pointer pair, and subsequent opcodes would dereference the cached pointer directly. The cache remains safe because `makeClosure` already pins the relevant scopes, and the slot memory lives in the fixed-size `locals` array allocated by the owning `FunctionScope` constructor.【F:src/NuXJS.cpp†L1997-L2054】【F:src/NuXJS.cpp†L2770-L2776】 We would still fall back to the chain walk whenever the descriptor fails to resolve (for example because guards forced the compiler to emit a `NAMED` opcode), but successful captures could skip both the depth loop and the bounds checks on later hits.

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
