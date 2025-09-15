# Evaluation Order TODO

*Reset after reverting ES5.1 call-order change.*


See [evaluationOrderReport](evaluationOrderReport.md) for background and rationale.

## Findings

- **Non-property assignments still resolve the right-hand side before validating the target.** Named and local assignments only emit the non-throwing `TYPEOF_NAMED_OP`/`READ_LOCAL_OP` probe ahead of right-hand compilation, so an unresolved identifier does not fault until after the right-hand side has already executed—contrary to ES3’s requirement that the reference be resolved first.【F:docs/specs/ECMA-262 3.md†L2879-L2884】【F:docs/specs/ECMA-262 3.md†L1770-L1782】【F:docs/specs/ECMA-262 3.md†L1438-L1446】 Regression coverage in [`tests/unconforming/rightSideBeforeAssignmentRef.io`](../../tests/unconforming/rightSideBeforeAssignmentRef.io) (and its `testsBroken` counterpart) confirms the deviation remains.
- **Bracket property compilation now validates the base before property-key evaluation.** `PROPERTY_BRACKETS` emits `CHECK_OBJECT_COERCIBLE_OP` immediately after compiling the base so `base[prop]` throws prior to any key-side effects, aligning with ES3’s `MemberExpression : MemberExpression [ Expression ]` rules in §11.2.1.【F:docs/specs/ECMA-262 3.md†L2063-L2071】【F:src/NuXJS.cpp†L3670-L3681】 Regression coverage in [`tests/erroneous/assignmentNullBaseBracketLeftFirst.io`](../../tests/erroneous/assignmentNullBaseBracketLeftFirst.io) and [`assignmentUndefinedBaseBracketLeftFirst.io`](../../tests/erroneous/assignmentUndefinedBaseBracketLeftFirst.io) now confirms the key expression is skipped once the base faults.【F:tests/erroneous/assignmentNullBaseBracketLeftFirst.io†L1-L11】【F:tests/erroneous/assignmentUndefinedBaseBracketLeftFirst.io†L1-L11】
- **Property reference resolution enforces the same ordering for bracket assignments and updates.** `RESOLVE_PROPERTY_OP` now swaps the stack to run `CHECK_OBJECT_COERCIBLE_OP` against the stored base before re-pushing operands, so `base[prop] = rhs` and `base[prop]++` throw prior to any property-key or right-hand evaluation when the base is `null`/`undefined`. Updated regression coverage in [`postfixIncrementNullBaseBracketLeftFirst.io`](../../tests/erroneous/postfixIncrementNullBaseBracketLeftFirst.io) and [`postfixIncrementUndefinedBaseBracketLeftFirst.io`](../../tests/erroneous/postfixIncrementUndefinedBaseBracketLeftFirst.io) confirms the property expression is skipped for both null and undefined bases.【F:tests/erroneous/postfixIncrementNullBaseBracketLeftFirst.io†L1-L10】【F:tests/erroneous/postfixIncrementUndefinedBaseBracketLeftFirst.io†L1-L10】
- **Conclusion.** NuXJS still deviates from ES3’s mandated evaluation order for unqualified assignments and bracket property accesses; these remain open work even though earlier milestone checkboxes were marked complete.

Each milestone must be completed in order and `timeout 600 ./build.sh` must succeed before advancing to the next.

## Milestone 1 – Regression tests
- [x] Audit existing `tests/unconforming` coverage and add missing cases for property-key and right-hand-side evaluation order.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 2 – Base object coercion
- [x] Introduce `CHECK_OBJECT_COERCIBLE_OP` and wire it into the VM.
- [x] Reorder bracket compilation so the base is validated and coerced before property-key evaluation, matching ES3 §11.2.1’s requirement that the base be checked prior to the property expression.【F:docs/specs/ECMA-262 3.md†L2063-L2071】
- [x] Update regression coverage (e.g. `assignmentNullBaseBracketLeftFirst.io`, `assignmentUndefinedBaseBracketLeftFirst.io`) to verify no key-side effects occur once the base throws.
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
- [x] Integrate `CHECK_OBJECT_COERCIBLE_OP` with property reference resolution for bracket assignments and postfix updates so `base[prop]` throws before any property-key or right-hand evaluation when the base is `null`/`undefined`.
- [x] Ensure regression scenarios (`assignmentNullBaseBracketLeftFirst.io`, `assignmentUndefinedBaseBracketLeftFirst.io`, `postfixIncrementNullBaseBracketLeftFirst.io`, etc.) observe the ES3 ordering and pass without key-side effects.
- [x] Run `timeout 600 ./build.sh`.

## Milestone 6 – Reference validation for non-property assignments
- [ ] Ensure variable and unqualified assignments resolve their left-hand references before evaluating the right-hand side, as mandated by ES3 §11.13.1, the scope-chain rules in §10.1.4, and the `PutValue` algorithm in §8.7.2.【F:docs/specs/ECMA-262 3.md†L2879-L2884】【F:docs/specs/ECMA-262 3.md†L1770-L1782】【F:docs/specs/ECMA-262 3.md†L1438-L1446】
- [ ] Update regression coverage (`tests/unconforming/rightSideBeforeAssignmentRef.io`, `testsBroken/unconforming/rightSideBeforeAssignmentRef.io`) to confirm the right-hand side no longer executes when the reference is unresolved.
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
