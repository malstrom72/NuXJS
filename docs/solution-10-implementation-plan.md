# Solution 10 Implementation Plan

This checklist breaks down the work needed to adopt **Solution 10 – Ancestor-name runtime fallback**. The target end state is that every closure opcode operand directly encodes the capture coordinates—an 8‑bit ancestor *level* and a signed 16‑bit *slot index*—with bounds checks that fall back to the existing name-based helpers whenever those coordinates are unsafe.

## Milestone 1 – Encode capture coordinates in the operand
- [ ] Introduce a shared helper (for example `packClosureOperand`) that packs `(level << 16) | (slot & 0xFFFF)` into the 24-bit operand field and returns `false` when `level > 255` or `slot` falls outside `[-32768, 32767]`.
- [ ] Update the compiler’s capture walker so `emitClosureOperand` (and friends) invoke the packer, and automatically downgrade the binding to the named path when the helper reports out-of-range coordinates.
- [ ] Adjust the bytecode reader/disassembler to decode `level` and `slot` from the operand rather than reading a side-table entry.
- [ ] Ensure `CapturedBinding` serialization no longer stores the identifier pointer—only the packed `(level, slot)` pair used to populate operands and cache runtime lookups.
- [ ] Extend the compiler regression tests to cover captures that sit exactly on the `255`/`±32768` edges and verify they fall back to named access when they overflow.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 2 – Runtime fallback helpers
- [ ] Add a runtime utility (for example on `FunctionScope`) that accepts the operand, walks `parentFunctionScope` the encoded level, and returns both the resolved slot pointer and owning `Code` object so the identifier name can be recovered via `getLocalName` when needed.
- [ ] Teach the `READ_CLOSURE_OP`, `WRITE_CLOSURE_OP`, `WRITE_CLOSURE_POP_OP`, and `DELETE_CLOSURE_OP` interpreter cases to decode the operand, use cached slot pointers when the fast lookup succeeds, and call the fallback helper when resolution fails.
- [ ] Ensure every scope that can invalidate slot resolution (`EvalScope`, `WithScope`, `CatchScope`) continues to override `resolveClosureOperand` with `false` so the fallback is exercised reliably.
- [x] Instrument the closure opcodes with runtime counters and expose REPL helpers to reset/read the totals so cache hits, misses, and guarded fallbacks can be monitored in regression tests.【F:src/NuXJS.h†L1176-L1252】【F:src/NuXJS.cpp†L2556-L2607】【F:tools/NuXJSREPL.cpp†L195-L233】【F:tests/regression/closureInstrumentationCounters20250211.io†L1-L36】
- [ ] Extend the regression suite to cover fallback execution (e.g. closure inside `with`, closure inside `catch`, direct `eval` that mutates an outer binding) and verify the reported names in ReferenceErrors match the ancestor table.
- [ ] Run `timeout 180 ./build.sh`.

## Milestone 3 – Metadata retention and documentation
- [ ] Audit the code that prunes `Code` metadata after compilation to guarantee `argumentNames` and `varNames` stay populated, since the fallback now depends on them for identifier recovery.
- [ ] Update developer tooling (REPL dumps, disassembler output, benchmark notes) to mention the operand-only representation and the new slow-path resolution.
- [ ] Document the operand packing, bounds checks, and dynamic-scope guard behavior in `docs/outer-closure-fast-binding.md`.
- [ ] Expand the benchmark coverage (e.g. `closure_outer_binding_bm_1.js`) to sample both fast-slot access and forced fallbacks so performance regressions are caught.
- [ ] Run `timeout 180 ./build.sh`.
