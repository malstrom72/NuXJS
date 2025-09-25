# Evaluation Order Update Introduction

This report identifies the commits on the `include-more-262-tests` branch that first introduced the slower evaluation-order machinery (`CHECK_OBJECT_COERCIBLE_OP` and `CHECK_RESOLVE_PROPERTY_OP`).

## 94b0718 — Add expression evaluation order docs and NuXJS sources (2025-09-10)
* Adds design documentation under `docs/notes/` describing a new opcode named `CHECK_OBJECT_COERCIBLE_OP` and why it should precede property name coercion.
* Introduces prototype implementations in `srcBroken/NuXJS.cpp` and `srcBroken/NuXJS.h`, including the initial opcode table entries and interpreter case for `CHECK_OBJECT_COERCIBLE_OP`. Although these files were not yet wired into the shipping VM, they document the intended execution order changes that later patches implemented.

## 95b6346 — Restore ES3 evaluation order and add regression tests (2025-09-10)
* Extends the shipping VM by adding `CHECK_OBJECT_COERCIBLE_OP` to the opcode enum (`src/NuXJS.h`) and interpreter dispatch (`Processor::innerRun` in `src/NuXJS.cpp`). The new case throws a `TypeError` if the value atop the stack is `undefined` or `null` before converting it into an object.
* Updates the compiler to emit the new opcode before dotted and bracketed property accesses (`PROPERTY_DOT` and `PROPERTY_BRACKETS` cases) and ahead of assignments that operate on property references. This ensures the base object is validated prior to evaluating the right-hand side or converting the property key.
* Adds multiple regression tests under `tests/regression/` that expect ES3 ordering, confirming that the opcode runs before RHS evaluation or key coercion. These tests began failing for null/undefined bases prior to the change and now pass.

## 4f28ec6 — Replace RESOLVE_PROPERTY_OP with CHECK_RESOLVE_PROPERTY_OP (2025-09-17)
* Replaces the earlier `RESOLVE_PROPERTY_OP` helper with a stricter `CHECK_RESOLVE_PROPERTY_OP` that first performs the null/undefined guard and then calls `convertToObject`. The interpreter switch gained a new combined case and removed the old opcode.
* Revises the compiler so that any assignment, compound assignment, or post-increment targeting a property emits `CHECK_RESOLVE_PROPERTY_OP` (with optional `REPUSH_2_OP`) before evaluating the RHS. This extends the evaluation-order guard to every property write path.
* Updates branch documentation (`fails`) to reflect the tightened semantics, signaling that the new opcode is expected to execute on every property reference before further computation.

## Current cleanup
* Removed `CHECK_OBJECT_COERCIBLE_OP` and `CHECK_RESOLVE_PROPERTY_OP` from the opcode table and interpreter so property access now follows the pre-experiment execution order again.【F:src/NuXJS.cpp†L2370-L2387】【F:src/NuXJS.h†L1585-L1603】
* Pruned guard-specific test cases under `tests/erroneous`, `tests/regression`, and `tests/unconforming` that assumed the stricter evaluation order, keeping the suite aligned with the restored behavior.
