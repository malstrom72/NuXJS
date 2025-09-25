# Compile-Time Closure Slot Implementation Plan

This roadmap breaks the closure-slot work into incremental milestones. Each milestone is scoped so that the tree builds and tests cleanly before proceeding to the next stage.

### Goals and guardrails

* Keep every intermediate revision shippable. Compiler changes must continue to generate valid bytecode, even when a milestone only replaces part of the capture path. Guard downgrades fall back to legacy named opcodes so we never ship an operand without runtime support.
* Avoid regressing diagnostics. Whenever a fast-path optimisation hides identifier strings, make sure the slow path still resolves names through `Code::getLocalName` so ReferenceError text remains unchanged.
* Preserve tooling debuggability. As we eliminate `CapturedBinding`, update docs and helper functions in the same milestone so REPL and disassembly output does not degrade.
* Prefer single-purpose helpers. Each new capture helper (for example `Code::ensureCapturedBinding`) should encapsulate reuse logic and be referenced from exactly one abstraction layer. This keeps the eventual deletion straightforward because all call sites are already funnelled through a common entry point.【F:src/NuXJS.cpp†L1623-L1629】【F:src/NuXJS.cpp†L3931-L3949】【F:src/NuXJS.cpp†L4042-L4063】【F:src/NuXJS.h†L1785-L1788】

### Terminology

* *Closure operand* – the packed depth/slot tuple that replaces the historical binding table index.
* *Named opcode* – legacy bytecode that resolves identifiers by string lookup instead of a slot operand.
* *Guard* – any condition that prevents a capture from taking the fast path (e.g. `with` scope, direct `eval`, signed-slot overflow).
* *Slow path* – the runtime fallback that climbs scope chains and resolves identifier names when guards block operand-only execution.

## Milestone 1 – Compiler plumbing for operand-only captures
- [x] Replace `Compiler::recordCapturedBinding`/`ensureCapturedBinding` so they return an inline `(ancestorDistance, slotOffset)` operand instead of appending to `Compiler::capturedBindings`, deleting the vector from `Compiler` entirely while reusing `lookupNameIndex` for signed-slot resolution.【F:src/NuXJS.cpp†L1596-L1629】【F:src/NuXJS.cpp†L3885-L3928】【F:src/NuXJS.h†L1724-L1868】
- Delete the `capturedBindings` member and related helpers from `Compiler`/`Code` headers before touching call sites so the compiler fails fast if a path was overlooked.
- Update `recordCapturedBinding` to call `lookupNameIndex` immediately; clamp the returned slot to the signed 16-bit range and return a `(bool success, UInt16 depth, Int16 slot)` triple (or similar) so downstream emitters can avoid table lookups.
- Audit every caller—`identifier`, assignment lowering, function literals—to use the new tuple rather than indexing into a vector; keep temporary structs local to the compilation pass so nothing survives into runtime metadata.
- [x] Thread the ancestor lookup context through nested `Compiler` instances by extending `functionDefinition` to pass `Code::nameIndexes`, the hoist guard bit, and the parent depth counter so child `identifier` nodes can encode operands during parse time.【F:src/NuXJS.cpp†L3090-L3124】【F:src/NuXJS.cpp†L3885-L3898】【F:src/NuXJS.h†L1724-L1868】
- Amend the `Compiler` constructor parameters to accept a pointer to the parent `Code` (or a light-weight descriptor) and the active lexical depth counter.
- Copy `allowClosureSlots`, `withScopeCounter`, and pending hoist information into the child compiler before it parses its body so its own capture walk sees the correct guards.
- Ensure teardown writes any mutated guard state back to the parent only after the nested body finishes to avoid leaking child state upward.
- Document the new helper surface and guard threading so future contributors understand why the compiler now stores capture operands locally instead of mutating shared vectors; keep milestone notes in sync with the code while the table still exists.【F:src/NuXJS.cpp†L1600-L1629】【F:src/NuXJS.cpp†L3885-L3928】
- [x] Teach `identifier`, assignment, and declaration helpers to emit the dedicated closure opcode when a captured operand is available, falling back to `READ_NAMED_OP`/`WRITE_NAMED_OP` whenever `withScopeCounter`, `CATCH_PARAMETER`, direct `eval`, or slot-range guards reject the capture.【F:src/NuXJS.cpp†L4045-L4067】【F:src/NuXJS.cpp†L3430-L3438】
- [x] Centralise the guard evaluation in `Compiler::maybeEmitClosureOperand`, which returns a closure operand only when the fast-path checks succeed and reuses `Code::ensureCapturedBinding` for deduplication.【F:src/NuXJS.cpp†L1623-L1629】【F:src/NuXJS.cpp†L3931-L3949】【F:src/NuXJS.h†L1785-L1788】
- [x] Update identifier resolution to call the helper after local-slot resolution so expression and assignment sites share a single decision point before emitting closure opcodes.【F:src/NuXJS.cpp†L4042-L4063】
- [x] Extend destructuring, compound assignment, and declaration lowering to reuse the helper so every opcode variant surfaces the packed operand consistently.【F:src/NuXJS.cpp†L3429-L3440】【F:src/NuXJS.cpp†L3764-L3810】【F:src/NuXJS.cpp†L4096-L4134】【F:src/NuXJS.cpp†L4171-L4209】
- Add targeted compiler tests or debug logging while developing to assert that names skipped because of a guard reason still emit the legacy named opcode.
- [x] Run `timeout 180 ./build.sh`.【fa5df0†L1-L4】

## Milestone 2 – Pack `(ancestorDistance, slotOffset)` into bytecode operands
- [x] Introduce a helper such as `Compiler::packClosureOperand(UInt16 depth, Int16 slot)` that validates the 8-bit/16-bit bounds before calling `CodeSection::emit`, and update the closure opcodes to store the packed 24-bit value directly instead of indexing a binding table.【F:src/NuXJS.cpp†L3397-L3450】【F:src/NuXJS.cpp†L3946-L3981】【F:src/NuXJS.cpp†L2584-L2634】【F:src/NuXJS.cpp†L2809-L2830】
- [x] Decide on the bit layout (e.g. `depth << 16 | (slot & 0xFFFF)`) and document it in a shared header so runtime and tooling stay in sync.【F:src/NuXJS.h†L825-L835】
- Add assertions before emitting to ensure the operands never wrap; downgrade to named opcodes in the compiler when the helper rejects a capture and record a diagnostic for debugging.
- Replace all uses of `Code::capturedBindings[index]` with direct operand writes, including any legacy emitters such as function expressions or generator helpers.
- [x] Update assembler/disassembler tables (`Processor::packInstruction`, opcode metadata arrays, and tooling in `tools/NuXJSREPL.cpp` / `tools/work/LegacyReplTests.cpp`) to decode the operand into depth/slot pairs for debugging without referencing `Code::capturedBindings`.【F:src/NuXJS.cpp†L2238-L2260】【F:src/NuXJS.h†L824-L836】【F:tools/NuXJSREPL.cpp†L280-L317】【F:tools/work/LegacyReplTests.cpp†L340-L377】
- Extend the opcode metadata to describe the packed layout so the disassembler prints meaningful labels (for example `closure depth=1 slot=-2`).
- Update REPL inspectors and legacy tooling to reuse a shared `unpackClosureOperand` helper rather than duplicating bit math in multiple files.
- Re-run existing disassembly-based regression tests to confirm the textual output remains stable apart from the new annotations.
- [ ] Adjust bytecode serialization so no captured-binding array is written to or read from save images; ensure section headers, counts, and GC marking no longer assume `Code::capturedBindings` exists.【F:src/NuXJS.cpp†L4562-L4752】【F:src/NuXJS.h†L840-L874】
- Remove the captured-binding chunk from both writer and reader paths, updating version numbers if required so older snapshots fail gracefully.
- Eliminate GC mark loops that iterate the old vector; rely on operand decoding plus `Code::getLocalName` during fallback instead.
- Smoke-test snapshot load/save tooling (if available) or stub out the feature until operand-only captures ship.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 3 – Runtime fast path and fallback without `CapturedBinding`
- [ ] Rewrite `Scope::resolveCapturedBinding` and the closure opcode handlers to accept decoded depth/slot pairs, walking `parentFunctionScope` pointers directly and touching `localsPointer` once the target frame is reached so no heap allocation or binding table lookup occurs.【F:src/NuXJS.cpp†L1997-L2155】【F:src/NuXJS.cpp†L2556-L2611】
- Introduce a lightweight struct (e.g. `ResolvedClosureSlot`) that caches both the frame pointer and slot index; store it on the activation so repeated accesses avoid re-walking the chain.
- Record a doc note explaining how the cache interacts with GC and activation lifetime so the Milestone 4 cleanup can drop any redundant metadata once the runtime path is proven.
- Update interpreter switch cases to call a shared helper that handles cache miss, pointer validation, and depth countdown, keeping the fast path inlined and branch-light.
- Ensure debug builds validate the computed slot against the owning `Code`’s slot counts to catch stale operands early.
- [ ] Implement the slow path by climbing the same number of lexical frames and calling `JSFunction::getScriptCode()->getLocalName(slot)` to recover identifier strings for `readVar`/`writeVar`/`deleteVar` fallbacks when `EvalScope`, `WithScope`, or guard failures block the fast slot.【F:src/NuXJS.cpp†L2138-L2364】【F:src/NuXJS.h†L844-L990】
- Share the ancestor walk between the fast and slow helpers so maintenance stays trivial; when the walk encounters a non-function scope, immediately dispatch to the named helpers.
- Fetch the identifier string from `getLocalName` only once per failure and thread it through to the `ReferenceError` constructors to preserve diagnostics.
- Add instrumentation (temporary counters or tracing) while developing to prove that dynamic-scope cases actually hit the fallback.
- [ ] Ensure every dynamic-scope class (`EvalScope`, `WithScope`, `CatchScope`) continues to veto fast resolution by overriding the new helper, and add regression coverage that triggers each guard while confirming the operand-only slow path reports correct ReferenceError names.【F:src/NuXJS.cpp†L2298-L2364】【F:tests/regression/closureDynamicScopeGuards20250209.io†L1-L120】
- Audit each scope’s override to confirm it receives the packed operand and returns a clear error flag without dereferencing frame pointers it does not own.
- Extend regression tests to include scenarios that mutate captured variables after forcing a fallback, guaranteeing writes propagate correctly.
- Capture expected ReferenceError output in `.io` files so the slow path’s identifier recovery is exercised continuously.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 4 – Remove legacy `CapturedBinding` infrastructure
- [ ] Delete the `CapturedBinding` struct, its GC hooks, and the `Code::capturedBindings` vector from headers and implementation files; replace any remaining callers (including REPL, legacy disassembly, and unit helpers) with operand decoding logic.【F:src/NuXJS.h†L815-L874】【F:src/NuXJS.cpp†L1560-L1661】【F:tools/NuXJSREPL.cpp†L250-L313】
- Start by removing the type definition and GC mark function so any forgotten include or pointer usage fails compilation.
- Sweep the runtime, tools, and tests for `capturedBindings` references, substituting calls to `unpackClosureOperand` where a human-readable name is required.
- Re-run GC stress or leak tooling if available to confirm the removal did not leave dangling references.
- [ ] Rip out `Compiler::capturedBindings` ownership and serialization (`Code::appendCapturedBinding`, `Compiler::ensureCapturedBinding`, etc.) so compilation no longer stores per-binding name pointers or indices.【F:src/NuXJS.cpp†L1614-L1642】【F:src/NuXJS.cpp†L3893-L3942】
- Delete the helper implementations entirely and inline any remaining logic into the operand packer to prevent future reintroduction of the table.
- Update serialization counts and version headers to skip writing the removed data; add asserts that legacy readers are no longer invoked.
- Remove related unit tests or fixtures that expected a populated binding list, replacing them with operand checks.
- [ ] Update documentation and comments that reference `CapturedBinding` or binding tables to explain the operand-only layout and the runtime fallback through `Code::getLocalName`. Ensure the design report stays aligned with the implementation details.【F:docs/outer-closure-fast-binding.md†L1-L260】
- Touch the major design docs (`outer-closure-fast-binding.md`, `solution-10-implementation-plan.md`) and inline code comments to reflect the new invariants.
- Highlight the operand encoding and fallback mechanics in developer-facing docs so future maintainers understand why metadata was removed.
- Capture any caveats (e.g. operand overflow falling back to named) in the troubleshooting section of the docs.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 5 – Tooling, tests, and performance validation
- [ ] Refresh disassembly output, REPL inspectors, and logging utilities to print the unpacked `(ancestorDistance, slotOffset)` directly from operands so developers can diagnose closure captures without referencing removed tables.【F:tools/NuXJSREPL.cpp†L250-L313】【F:tools/work/LegacyReplTests.cpp†L337-L381】
- Share the operand unpacker through a common header so every tool renders identical output, keeping regressions easy to spot.
- Update any scripting harnesses that diff disassembly output to accept the new format and regenerate their golden files.
- Verify interactive REPL commands still work end-to-end by manually inspecting a script with closures.
- [ ] Expand regression suites (`closureCapturedSlotsBasics20250210.io`, `closureDynamicScopeGuards20250209.io`) and add new `.io` cases that assert both the fast path and operand-only fallback behave correctly across eval, with, and catch scenarios after the binding array disappears.【F:tests/regression/closureCapturedSlotsBasics20250210.io†L1-L80】【F:tests/regression/closureDynamicScopeGuards20250209.io†L1-L120】
- Craft explicit `.io` files that exercise operand overflow, forced slow paths, and deletion semantics to keep coverage broad.
- Run the full regression harness locally and capture logs for inclusion in the PR description to demonstrate the absence of guard regressions.
- Add comments to the tests explaining which guard each block validates so future contributors can extend them consistently.
- [ ] Re-run targeted benchmarks (`closure_outer_binding_bm_1.js` and any capture-heavy workloads) to measure the impact of dropping hash-based lookups, recording before/after numbers in the benchmark golden files or design notes.【F:benchmarks/closure_outer_binding_bm_1.js†L1-L26】【F:benchmarks/golden/closure_outer_binding_bm_1.txt†L1-L1】
- Capture baseline numbers from the current main branch before landing operand-only closures, then repeat after the change to show the delta.
- Document the methodology (hardware, iteration count, warm-up) alongside the numbers so results are reproducible.
- Investigate any unexpected regressions immediately—before marking the milestone done—to ensure the fast path is delivering the intended benefit.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone health check

Each milestone ends with a mandatory `timeout 180 ./build.sh` run, ensuring both release and beta configurations compile and execute the regression suite before advancing. The dependencies between milestones are linear—the compiler must emit operands (Milestones 1–2) before the runtime can consume them (Milestone 3), and the legacy removal (Milestone 4) plus tooling/tests (Milestone 5) build on the new data flow. Because every milestone touches self-contained areas (compiler, bytecode format, runtime, then clean-up/tooling) and preserves working binaries at the end, we can safely test and run the project after completing each stage. Should any build break, the added assertions and guard downgrades will force a named-lookup fallback rather than producing incorrect bytecode, giving us clear failure signals while keeping the tree in a runnable state.
