# Expression Evaluation Order TODO

See [expression-evaluation-report](expression-evaluation-report.md) for background and rationale.

Each milestone must be completed in order and `timeout 600 ./build.sh` must succeed before advancing to the next.

## Milestone 1 – Regression tests
- [ ] Audit existing `tests/unconforming` coverage and add missing cases for property-key and right-hand-side evaluation order.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 2 – Base object coercion
- [ ] Introduce `CHECK_OBJECT_COERCIBLE_OP` and wire it into the VM.
- [ ] Update `GET_PROPERTY_OP` to perform `CheckObjectCoercible` before key conversion.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 3 – Property key conversion
- [ ] Factor `OBJ_TO_STRING_OP` out of property access opcodes.
- [ ] Reorder bracket compilation so key conversion occurs after base evaluation.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 4 – Reference resolution before RHS
- [ ] Emit a `RESOLVE_PROPERTY` opcode ahead of right-hand evaluation for assignments.
- [ ] Update `SET_PROPERTY_POP` to work with a resolved reference.
- [ ] Run `timeout 600 ./build.sh`.

## Milestone 5 – Accessor ordering and tests
- [ ] Ensure getters and setters execute after base and property-key coercion.
- [ ] Add regression tests covering getter/setter evaluation order.
- [ ] Run `timeout 600 ./build.sh`.
