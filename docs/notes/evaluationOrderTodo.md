# Evaluation Order TODO

*Reset after reverting ES5.1 call-order change.*


See [evaluationOrderReport](evaluationOrderReport.md) for background and rationale.

The evaluation-order report highlights that variable assignments still evaluate the right-hand side before verifying the left-hand reference, diverging from ES3.

Each milestone must be completed in order and `timeout 600 ./build.sh` must succeed before advancing to the next.

## Milestone 1 – Regression tests
- [x] Audit existing `tests/unconforming` coverage and add missing cases for property-key and right-hand-side evaluation order.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 2 – Base object coercion
- [x] Introduce `CHECK_OBJECT_COERCIBLE_OP` and wire it into the VM.
- [x] Convert base objects before property key evaluation.
- [x] Run `timeout 180 ./build.sh`.

## Milestone 3 – Property key conversion
- [x] Factor `OBJ_TO_STRING_OP` out of property access opcodes.
- [x] Reorder bracket compilation so key conversion occurs after base evaluation.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 4 – Reference resolution before RHS
- [x] Emit a `RESOLVE_PROPERTY` opcode ahead of right-hand evaluation for assignments.
- [x] Update `SET_PROPERTY_POP` to work with a resolved reference.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 5 – Null/undefined base resolution
- [x] Integrate `CHECK_OBJECT_COERCIBLE_OP` with property reference resolution for bracket assignments and postfix updates.
- [x] Ensure `base[prop]` is resolved once and throws before right-side evaluation when the base is `null` or `undefined`.
- [x] Add regression tests for `S11.13.1_A7_T1.js`, `S11.13.1_A7_T2.js`, and `S11.3.1_A6_T1.js`.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 6 – Reference validation for non-property assignments
- [ ] Ensure variable and unqualified assignments validate the left-hand reference before evaluating the right-hand side as mandated by ES3 §11.13.1 and the scope-chain rules in §10.1.4.【F:docs/specs/ECMA-262 3.md†L2879-L2884】【F:docs/specs/ECMA-262 3.md†L1770-L1782】
- [ ] Add regression tests demonstrating that assigning to an undefined identifier reports `ReferenceError` without evaluating the right-hand side.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 7 – ES5.1: Call-target resolution *(future)*
- [ ] Resolve method targets before argument evaluation.
- [ ] Add regression tests for ES5.1 call ordering.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 8 – ES5.1: Accessor ordering and tests *(future)*
- [ ] Ensure getters and setters execute after base and property-key coercion.
- [x] Add regression tests covering getter/setter evaluation order.
- [ ] Document accessor sequencing in the evaluation report.
- [ ] Run `timeout 600 ./build.sh`.
