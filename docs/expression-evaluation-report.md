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

### Accessor properties (getters and setters)

> When a property reference resolves to an accessor, ES5.1 specifies the getter algorithm:
> 1. Let O be ToObject(base).
> 2. Let desc be the result of calling the [[GetProperty]] internal method of O with property name P.
> 3. If desc is undefined, return undefined.
> 4. If IsDataDescriptor(desc) is true, return desc.[[Value]].
> 5. Otherwise, IsAccessorDescriptor(desc) must be true so, let getter be desc.[[Get]].
> 6. If getter is undefined, return undefined.
> 7. Return the result of calling getter with base as the this value and no arguments.【F:docs/specs/ECMA-262 5.1.txt†L1646-L1653】
>
> For writes, the corresponding [[Put]] algorithm invokes the setter only after the base is converted:
> 1. Let O be ToObject(base).
> 2. If the result of [[CanPut]](O, P) is false, handle the Throw flag.
> 3. Let ownDesc be [[GetOwnProperty]](O, P).
> 4. If IsDataDescriptor(ownDesc) is true, handle the Throw flag.
> 5. Let desc be [[GetProperty]](O, P).
> 6. If IsAccessorDescriptor(desc) is true,
>	  1. Let setter be desc.[[Set]] which cannot be undefined.
>	  2. Call setter with base as the this value and W as the sole argument.【F:docs/specs/ECMA-262 5.1.txt†L1674-L1685】

NuXJS performs accessor invocation inside `GET_PROPERTY_OP` and `SET_PROPERTY_POP`. Because the
compiler stringifies the property key before the base is checked and defers reference resolution
until these opcodes execute, side effects in `toString` or in the right-hand side can occur even
when the getter or setter is never reached. Fixing the evaluation order as described below would
prevent these premature side effects.

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

## Asynchronous Execution Model

NuXJS exposes a cooperative VM that can be stepped for a limited number of
cycles before returning to the host. The project README advertises this
behaviour:

> - Fully asynchronous, **non-blocking VM**; run as many cycles as you like
> between host calls.【F:README.md†L7-L14】

`Processor::run` accepts a cycle budget and yields while bytecode remains:

```cpp
bool Processor::run(Int32 maxCycles) {
cyclesLeft = maxCycles;
while (ip != 0 && cyclesLeft >= 0) {
try {
innerRun();
}
catch (const ScriptException& x) {
throwVirtualException(x.value);
}
}
return (ip != 0);
}
```【F:src/NuXJS.cpp†L3123-L3134】

Higher-level APIs loop over `run`, interleaving host work between iterations:

```cpp
Var Runtime::runUntilReturn(Processor& processor) {
while (processor.run(STANDARD_CYCLES_BETWEEN_AUTO_GC)) {
autoGC(true);
checkTimeOut();
}
return Var(*this, processor.getResult());
}
```【F:src/NuXJS.cpp†L5849-L5854】

The ECMAScript specification, however, models execution as a single stack of
contexts with exactly one running at a time:

> When control is transferred to ECMAScript executable code, control is
> entering an execution context. Active execution contexts logically form a
> stack. The top execution context on this logical stack is the running
> execution context. A new execution context is created whenever control is
> transferred from the executable code associated with the currently running
> execution context to executable code that is not associated with that
> execution context. The newly created execution context is pushed onto the
> stack and becomes the running execution context.【F:docs/specs/ECMA-262 5.1.txt†L2619-L2623】

There is no provision for suspending an execution context mid-expression, so
host code should not observe partially evaluated state. Allowing the host to
run between bytecodes can therefore violate the spec’s run-to-completion
semantics and expose intermediate side effects.

NuXJS intentionally retains this cooperative scheduling model. To keep cycle
costs predictable and let the host preempt execution between fine-grained
steps, opcodes are kept small and specialised. Splitting property-key
conversion into its own `OBJ_TO_STRING_OP` allows the engine to yield control
before `GET_PROPERTY` or `SET_PROPERTY` performs the lookup, preserving the
VM’s non-blocking behaviour.

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

## Appendix: Rationale for `OBJ_TO_STRING` Opcode

NuXJS currently converts property keys to strings before issuing the property lookup opcodes. The compiler emits `OBJ_TO_STRING_OP` when compiling bracket notation so that the runtime `GET_PROPERTY_OP` can assume the key is already a primitive string and focus solely on object conversion and lookup:

```
makeRValue(operand(op), true, Processor::OBJ_TO_STRING_OP); // left doesn't need to be primitive, but right does (and preferred string!)
```

This call is generated inside the `PROPERTY_BRACKETS` case of the parser【F:src/NuXJS.cpp†L4149-L4155】 and funnels through `makeRValue`, which conditionally emits the conversion instruction only when the operand might still be an object【F:src/NuXJS.cpp†L3627-L3642】. The resulting bytecode executes the dedicated opcode:

```
case OBJ_TO_STRING_OP: {
		const Object* o = sp[0].asObject();
		if (o != 0) {
				invokeFunction(rt.toPrimitiveFunctions[opcode - OBJ_TO_PRIMITIVE_OP], 0, 1);
				return;
		}
		break;
}
```

【F:src/NuXJS.cpp†L2869-L2878】.

`GET_PROPERTY_OP` then performs only the object check and lookup, trusting that the key is already a string, which keeps the hottest path lean【F:src/NuXJS.cpp†L2791-L2808】.

### Why not bake `ToString` into `GET_PROPERTY`?

1. **Avoiding redundant checks** – With a standalone opcode, constant or already‑primitive keys return early from `makeRValue` and skip `OBJ_TO_STRING_OP` entirely, so no runtime `typeof`/`isObject` checks occur for the common case of string literals or numeric indices. Baking the conversion into `GET_PROPERTY` would force every property access to branch on the key type and possibly invoke the `toString` helper even when unnecessary.
2. **Opcode reuse** – The same `OBJ_TO_STRING_OP` is used by other operators, such as the `in` operator, allowing shared implementation of `ToString` semantics across the VM without duplicating logic in each opcode path.
3. **Simpler hot path** – Keeping `GET_PROPERTY_OP` free of conversion logic reduces its instruction footprint. Property lookups are among the most frequent operations, so even small savings in the opcode’s body were historically measured as a performance win.
4. **Asynchronous granularity** – Because the VM is designed to be stepped with a cycle budget, splitting conversion into `OBJ_TO_STRING_OP` keeps each opcode short and lets the host yield control between the conversion and the subsequent property lookup.

These considerations stem directly from NuXJS's asynchronous design goal.

### Alternative approaches and their drawbacks

* **Integrate `ToString` in `GET_PROPERTY`/`SET_PROPERTY`** – Would require extra branching and a call into the `toPrimitive` helper for every property access. Early experiments indicated this increased instruction count and reduced micro‑benchmark performance.
* **Introduce multiple property opcodes** – Specialized variants (e.g., `GET_PROPERTY_GENERIC` vs. `GET_PROPERTY_STRING`) complicate bytecode generation and VM dispatch while still needing to embed conversion logic in at least one variant.
* **Deferred resolution opcode** – A hypothetical `RESOLVE_PROPERTY` combining `CheckObjectCoercible` and `ToString` could match spec order, but it would also perform the string conversion unconditionally and extend the critical path.

The dedicated `OBJ_TO_STRING_OP` therefore represented a pragmatic compromise: it minimized work in the property opcodes and emitted the potentially expensive conversion only when the compiler could not prove the key was already a primitive.

## Importance of Preserving Evaluation Order

Correct evaluation order is not merely a specification detail—it determines when user code with observable side effects runs. NuXJS’s current deviations surface most clearly when accessor properties are involved:

* **Premature side effects.** Because property keys and right‑hand sides are evaluated before the base object is coerced or the reference is resolved, `toString`/`valueOf` hooks and other side effects can occur even if the subsequent `CheckObjectCoercible` or reference resolution would have thrown a `TypeError`. Accessor getters or setters may never execute, yet their associated side effects have already run.
* **Accessor semantics.** ES5.1 mandates that getters and setters are invoked only after the base is converted to an object and the property name is resolved【F:docs/specs/ECMA-262 5.1.txt†L1646-L1653】【F:docs/specs/ECMA-262 5.1.txt†L1674-L1685】. Reordering these steps alters observable behavior, potentially breaking libraries that rely on getters for validation or setters for enforcing invariants.
* **Interoperability.** Code written for other engines expects ES‑compliant ordering. Divergent semantics complicate portability and make it harder to reason about control flow when integrating third‑party modules.

Given these risks, bringing NuXJS into alignment with ES3/ES5 evaluation order is a significant but important change. It touches fundamental bytecode generation and VM opcodes, yet it ensures that accessor side effects occur only when mandated by the specification and that property lookups behave predictably across engines.

## Incremental Implementation Plan

Implementing ES‑compliant ordering affects both compilation and runtime. The change can be staged to keep each patch reviewable:

1. **Introduce `CHECK_OBJECT_COERCIBLE_OP`.**
* Add a new opcode after `SET_PROPERTY_POP_OP` so the VM can perform `CheckObjectCoercible`/`ToObject` on the base value before any property lookup. This lives alongside the existing property opcodes in the enumeration【F:src/NuXJS.h†L1655-L1666】.
* The handler replaces the `convertToObject` calls currently embedded in `GET_PROPERTY_OP` and `SET_PROPERTY_OP`, leaving those opcodes to assume a pre‑checked base【F:src/NuXJS.cpp†L2791-L2808】【F:src/NuXJS.cpp†L2820-L2834】.

2. **Adjust property opcodes to accept raw keys.**
* With base conversion factored out, `GET_PROPERTY_OP` and `SET_PROPERTY_OP` operate on an object and an uncoerced key, preserving their short critical paths and cooperative granularity.

3. **Reorder compilation of bracket notation.**
* In the `PROPERTY_BRACKETS` parser branch, evaluate the base and key expressions without conversions, then emit `CHECK_OBJECT_COERCIBLE_OP` followed by `OBJ_TO_STRING_OP`. This matches ES5.1’s steps of checking the base before converting the property name【F:docs/specs/ECMA-262 5.1.txt†L3165-L3175】【F:src/NuXJS.cpp†L4149-L4156】【F:src/NuXJS.cpp†L3627-L3642】.

4. **Resolve left‑hand references before right‑hand sides.**
* `makeAssignment` currently emits `SET_PROPERTY_OP` as soon as the right‑hand value is on the stack【F:src/NuXJS.cpp†L3670-L3676】. Modify assignment lowering so the reference resolution sequence (`CHECK_OBJECT_COERCIBLE_OP` + `OBJ_TO_STRING_OP`) runs before compiling the right‑hand side, then perform the store. This satisfies the spec’s requirement to obtain *lref* before evaluating the RHS【F:docs/specs/ECMA-262 5.1.txt†L4106】.

5. **Extend the sequence to all property‑based constructs.**
* Apply the new ordering to method calls, compound assignments, and operators like `in` or `delete` so every property reference observes the same semantics.

6. **Add conformance tests.**
* Create regression tests exercising getters, setters, and `toString`/`valueOf` hooks to verify that key conversion and right‑hand side effects occur only after the base object is validated.

7. **Audit remaining early conversions.**
* After property and assignment paths are updated, review other uses of `OBJ_TO_*` in `makeRValue` to ensure no opcode performs observable conversions earlier than the ES5.1 algorithms allow.

By approaching the migration in these steps, NuXJS can move toward full ES3/ES5 ordering while preserving its cooperative, cycle‑based VM design.

