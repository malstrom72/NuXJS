# Expression Evaluation Order in NuXJS

This report investigates how NuXJS currently evaluates expressions and outlines the work required to align the engine with the evaluation order mandated by the ECMAScript 3 and ECMAScript 5.1 specifications.

## Background

The ECMAScript 5.1 specification defines the precise order of side‑effect‑producing steps for each language construct. For example, simple assignment evaluates the left‑hand side reference before the right‑hand side expression, and property access first coerces the base value to an object before converting the property key to a string. The algorithms are specified in the following clauses:

* **Simple assignment** – The production `AssignmentExpression : LeftHandSideExpression = AssignmentExpression` evaluates the left reference first, then the right expression, before invoking `PutValue`【F:docs/specs/ECMA-262 5.1.md†L5719-L5732】.
* **Property access** – The production `MemberExpression : MemberExpression [ Expression ]` evaluates the base expression, then the property expression, invokes `CheckObjectCoercible` on the base value, and only afterwards converts the property name to a string【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】.

NuXJS deliberately deviates from these algorithms, as documented in `docs/notes/ECMAScript Compatibility Notes.md`:

* *Assignments evaluate the right-hand side before resolving the reference on the left-hand side.*
* *Property access may convert the property key before converting the base object.*
* *Implicit `valueOf` and `toString` conversions may happen earlier than specified.*【F:docs/notes/ECMAScript Compatibility Notes.md†L9-L12】

The following sections analyse the relevant parts of the implementation and describe what would be required to conform to ES3/ES5.

## Current Implementation

### Assignment

During parsing, the left‑hand side expression is compiled first. When the compiler encounters the `=` operator, it emits code for the right‑hand side and only then emits the write operation:

```cpp
const ExpressionResult rxr = makeRValue(operand(op), false);
makeAssignment(xr);
xr = rxr;
```【F:src/NuXJS.cpp†L4124-L4130】

`makeAssignment` immediately performs the write using the value currently on top of the stack:

```cpp
switch (xr.t) {
		case ExpressionResult::LOCAL: emit(Processor::WRITE_LOCAL_OP, xr.v.toInt()); break;
		case ExpressionResult::NAMED: emitWithConstant(Processor::WRITE_NAMED_OP, xr.v); break;
		case ExpressionResult::PROPERTY: emit(Processor::SET_PROPERTY_OP); break;
		...
}
```【F:src/NuXJS.cpp†L3668-L3674】

As a result, resolution of the left‑hand side reference (for example, verifying that a variable exists in strict mode) is deferred until the write opcode executes. If the reference turns out to be invalid, the right‑hand side has already been evaluated, contradicting the spec.

### Property access

Bracket property access is compiled by first emitting code that converts the property expression to a string and only then leaves both the base value and key on the stack:

```cpp
makeRValue(xr, false);
...
makeRValue(operand(op), true, Processor::OBJ_TO_STRING_OP);
```【F:src/NuXJS.cpp†L4149-L4155】

At run time the `GET_PROPERTY_OP` instruction converts the base to an object *after* the key is already a string:

```cpp
const Object* o = convertToObject(sp[-1], false);
...
Flags f = o->getProperty(rt, *this, sp[0], sp - 1);
```【F:src/NuXJS.cpp†L2791-L2798】

This order causes `toString`/`valueOf` on the property expression to run before `CheckObjectCoercible` on the base value, allowing observable side effects that differ from ES3/ES5.

## Required Changes

### 1. Resolve assignment targets before evaluating right‑hand sides

* **Compiler:** Introduce a preparation step that resolves the left‑hand side reference immediately after parsing it. For variables this means emitting a `RESOLVE_LOCAL`/`RESOLVE_NAMED` opcode that checks for strict‑mode errors and caches any environment lookups. For property references, emit a new opcode that converts the base to an object and saves the base and property name without performing the assignment.
* **Runtime:** Implement the new opcodes so that reference resolution (including strict‑mode checks) occurs before any right‑hand side bytecode runs. The existing `WRITE_*` opcodes can then assume the reference is already resolved and simply store the value that is on top of the stack.
* **Compiler (assignment case):** Rewrite `postOperate` so that it emits the resolve opcodes, then compiles the right‑hand side, and finally emits a lightweight `PUT` opcode that performs the actual write using the pre‑resolved reference.
* **Testing:** Add regression tests where the left‑hand side throws (e.g. assigning to an undeclared variable in strict mode) and ensure the right‑hand side has no side effects when the assignment fails.

### 2. Reorder property access coercions

* **Compiler:** Stop converting the property expression to a string in `PROPERTY_BRACKETS`. Instead, leave the raw property value on the stack.
* **Runtime:** Modify `GET_PROPERTY_OP` and `SET_PROPERTY_OP` so that they first call `convertToObject` on the base value (`CheckObjectCoercible`), *then* convert the property value using a `ToString` helper. This change ensures the conversion order follows ES3/ES5 and also means each property access performs `ToString` exactly once as specified.
* **Increment and compound assignments:** Review `PRE_INC_DEC`, `POST_INC_DEC`, and compound assignment paths to ensure they still preserve the correct stack layout when the property key is no longer pre‑converted.
* **Testing:** Create tests where the base value and property expression each have observable side effects (e.g. getters or `toString` methods) to confirm that the base coercion happens before property key conversion and that both occur exactly once.

### 3. Defer implicit conversions to spec points

Because `makeRValue` eagerly performs conversions such as `OBJ_TO_STRING_OP`, moving these conversions into the property opcodes will align the engine with the spec and eliminate cases where `valueOf`/`toString` executes earlier than required. Ensure that any other early conversions (e.g. within arithmetic operators) are audited to confirm they match ES5 rules.

## Additional Considerations

* Updating the compiler and VM to handle pre‑resolved references may require extra temporary storage on the operand stack. Care must be taken to maintain stack discipline so existing bytecode sequences remain valid.
* Performance impact should be measured; deferring resolution and conversions may change optimisation opportunities.
* The documentation in `docs/notes/ECMAScript Compatibility Notes.md` should be updated once conformance is achieved, and new tests should be added under `tests/` to guard against regressions.

## Summary

Bringing NuXJS in line with ES3/ES5 evaluation order requires front‑end and VM changes:

1. Resolve assignment targets before evaluating right‑hand sides, emitting new opcodes that perform early reference checks.
2. Reorder property access so that base values are coerced to objects before property keys are converted to strings, moving conversions into `GET_PROPERTY_OP`/`SET_PROPERTY_OP`.
3. Audit and defer implicit `valueOf`/`toString` conversions to their specification points.

Implementing these changes and accompanying tests will eliminate the deviations noted in the compatibility document and ensure NuXJS follows the evaluation semantics defined by the ECMAScript standards.

