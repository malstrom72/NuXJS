# Expression Evaluation Order in NuXJS

This report investigates how NuXJS currently evaluates expressions and outlines the work required to align the engine with the evaluation order mandated by the ECMAScript 3 and ECMAScript 5.1 specifications.

## Background

The ECMAScript 5.1 specification defines the precise order of side‑effect‑producing steps for each language construct. For example:

> The production `AssignmentExpression : LeftHandSideExpression = AssignmentExpression` is evaluated as follows:
> 1. Let *lref* be the result of evaluating *LeftHandSideExpression*.
> 2. Let *rref* be the result of evaluating *AssignmentExpression*.
> 3. Let *rval* be GetValue(*rref*).
> 4. Throw a **SyntaxError** if certain conditions hold.
> 5. Call PutValue(*lref*, *rval*).
> 6. Return *rval*.【F:docs/specs/ECMA-262 5.1.txt†L4106】

> The production `MemberExpression : MemberExpression [ Expression ]` is evaluated as follows:
> 1. Let *baseReference* be the result of evaluating *MemberExpression*.
> 2. Let *baseValue* be GetValue(*baseReference*).
> 3. Let *propertyNameReference* be the result of evaluating *Expression*.
> 4. Let *propertyNameValue* be GetValue(*propertyNameReference*).
> 5. Call CheckObjectCoercible(*baseValue*).
> 6. Let *propertyNameString* be ToString(*propertyNameValue*).
> 7. If the production is contained in strict mode code, let *strict* be true; otherwise let *strict* be false.
> 8. Return a value of type Reference whose base value is *baseValue* and whose referenced name is *propertyNameString*, and whose strict mode flag is *strict*.【F:docs/specs/ECMA-262 5.1.txt†L3165-L3175】

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

### REPL disassembly examples

Running the NuXJS REPL and disassembling compiled functions exposes the misplaced
coercion steps.

#### Property access

Source:

```javascript
function prop(){ return null[side()]; }
```

Disassembly:

```text
1		@0:		CONST #null
2		@1:		READ_NAMED side
3		@2:		CALL *0
3		@3:		OBJ_TO_STRING	   ; ❌ key converted before null is checked
3		@4:		GET_PROPERTY	   ; base coerced after key conversion
2		@5:		PUSH_BACK *1
1		@6:		RETURN
```

The key is converted to a string before `GET_PROPERTY` coerces the `null` base.
A correct disassembly would check the base first and perform the conversion inside
`GET_PROPERTY`:

```text
1		@0:		CONST #null
2		@1:		READ_NAMED side
3		@2:		CALL *0
3		@3:		GET_PROPERTY	   ; ✓ CheckObjectCoercible then ToString(side())
2		@4:		PUSH_BACK *1
1		@5:		RETURN
```

`side()` runs before `GET_PROPERTY` checks the `null` base:

```javascript
function side(){ print("side"); return "x"; }
try { null[side()]; } catch (e) { print("error:" + e); }
```

Output:

```text
side
error:TypeError: Cannot convert undefined or null to object
```

#### Assignment

Source:

```javascript
function assign(){ null[key()] = value(); }
```

Disassembly:

```text
1		@0:		CONST #null
2		@1:		READ_NAMED key
3		@2:		CALL *0
3		@3:		OBJ_TO_STRING	   ; ❌ key converted before null is checked
3		@4:		READ_NAMED value
4		@5:		CALL *0			   ; ❌ right-hand side runs before base check
4		@6:		SET_PROPERTY_POP   ; base coerced only here
1		@7:		POP *1
0		@8:		VOID
1		@9:		RETURN
```

The right-hand side is evaluated before the base object is verified. A corrected
disassembly would resolve the property reference *before* `value()` executes and
would omit `OBJ_TO_STRING`:

```text
1		@0:		CONST #null
2		@1:		READ_NAMED key
3		@2:		CALL *0
3		@3:		RESOLVE_PROPERTY   ; ✓ CheckObjectCoercible and ToString(key)
3		@4:		READ_NAMED value
4		@5:		CALL *0
4		@6:		SET_PROPERTY_POP   ; ✓ assignment using resolved reference
1		@7:		POP *1
0		@8:		VOID
1		@9:		RETURN
```

Because `SET_PROPERTY_POP` executes after `value()` finishes, the right-hand side
observably runs even though the base is `null`:

```javascript
function key(){ print("key"); return "x"; }
function value(){ print("value"); return 1; }
try { null[key()] = value(); } catch (e) { print("error:" + e); }
```

Output:

```text
key
value
error:TypeError: Cannot convert undefined or null to object
```

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

