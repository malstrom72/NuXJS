# Compile-Time Closure Slot Implementation Plan

This roadmap breaks the closure-slot work into incremental milestones. Each milestone is scoped so that the tree builds and tests cleanly before proceeding to the next stage.

## Milestone 1 – Capture metadata plumbing
- [ ] Extend `Code` with a `Vector<CapturedBinding>` plus serialization helpers that reuse the existing signed slot convention.
- [ ] Thread a lightweight `CapturedLexicalContext` pointer through nested `Compiler` instances so child lookups can see parent `Code::nameIndexes` and the `allowClosureSlots` flag.
- [ ] Teach identifier parsing to produce an explicit closure variant that packages `(depth, slot)` when ancestors remain hoist-safe, falling back to named resolution otherwise.
- [ ] Persist the collected closure descriptors when finalizing a child `Code`, keeping the order aligned with opcode operands.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 2 – Bytecode surface and assembler support
- [ ] Introduce dedicated closure opcodes (read/write/delete) and register them in the opcode tables, metadata arrays, and disassembler.
- [ ] Update expression/assignment emission sites to select the closure opcodes when the new `ExpressionResult::CLOSURE` is present.
- [ ] Adjust bytecode serialization and constant-pool tooling so captured-binding indices survive save/load and debugging paths.
- [ ] Refresh unit/assembly tests that assert opcode ranges or mnemonic layouts.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 3 – Interpreter and runtime integration
- [ ] Add helpers on `FunctionScope` (and siblings) that walk parent frames using `(depth, slot)` while respecting `dynamicVars` and `arguments` aliasing.
- [ ] Wire the new closure opcodes into the interpreter dispatch loop, including slot read/write/delete helpers and error paths.
- [ ] Audit `GEN_FUNC_OP` / closure creation to ensure captured-binding tables are retained and traced by GC.
- [ ] Stress-test dynamic-scope guards (`with`, `catch`, direct `eval`) to confirm the compiler still routes unsafe identifiers through the named path.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 4 – Validation, tooling, and documentation
- [ ] Port debugger, inspector, and logging utilities to display closure-slot operands and captured-binding tables.
- [ ] Add regression tests that exercise nested closures, argument aliasing, dynamic scopes, and serialization/deserialization with the new opcodes.
- [ ] Document the closure-slot behavior and guard policy in `docs/outer-closure-fast-binding.md`, summarizing runtime fallbacks.
- [ ] Conduct targeted performance sampling to quantify wins versus the baseline NAMED path.
- [ ] Run `timeout 180 ./build.sh`.
