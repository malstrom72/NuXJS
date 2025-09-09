# Expression Evaluation Order TODO

See [expression-evaluation-report](expression-evaluation-report.md) for background and rationale.

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

## Milestone 5 – Accessor ordering and tests
- [ ] Ensure getters and setters execute after base and property-key coercion.
- [ ] Add regression tests covering getter/setter evaluation order.
- [ ] Run `timeout 600 ./build.sh`.
