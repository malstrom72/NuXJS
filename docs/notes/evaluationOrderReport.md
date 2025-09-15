# Expression Evaluation Order in NuXJS

This report investigates how NuXJS currently evaluates expressions and outlines the work required to align the engine with the evaluation order mandated by the ECMAScript 3 specification. ES5.1 semantics are treated as future work; any mention of ES5.1 is explicitly labeled and does not reflect the current implementation.

## Background

The ECMAScript 3 specification defines the precise order of side‑effect‑producing steps for each language construct. For example:

> The production `AssignmentExpression : LeftHandSideExpression = AssignmentExpression` is evaluated as follows:
> 1. Evaluate *LeftHandSideExpression*.
> 2. Evaluate *AssignmentExpression*.
> 3. Call GetValue(Result(2)).
> 4. Call PutValue(Result(1), Result(3)).
> 5. Return Result(3).【F:docs/specs/ECMA-262 3.md†L2879-L2888】

> The production `MemberExpression : MemberExpression [ Expression ]` is evaluated as follows:
> 1. Evaluate *MemberExpression*.
> 2. Call GetValue(Result(1)).
> 3. Evaluate *Expression*.
> 4. Call GetValue(Result(3)).
> 5. Call ToObject(Result(2)).
> 6. Call ToString(Result(4)).
> 7. Return a value of type Reference whose base object is Result(5) and whose property name is Result(6).【F:docs/specs/ECMA-262 3.md†L2063-L2071】

NuXJS deliberately deviates from these algorithms, as documented in `docs/notes/ECMAScript Compatibility Notes.md`:

* *Property access may convert the property key before converting the base object.*
* *Implicit `valueOf` and `toString` conversions may happen earlier than specified.*【F:docs/notes/ECMAScript Compatibility Notes.md†L9-L12】

The following sections analyse the relevant parts of the implementation and describe what would be required to conform to ES3, noting ES5.1 details only for getters and setters.

## Test262 evaluation-order status
NuXJS documentation, compatibility notes, and standard-library guidelines consistently warn that the engine does not fully adhere to strict ES3 evaluation order. Comparison with the Edition 3 specification shows the following:
•Early implicit conversions – in ES3, operands are fully evaluated before any `toString`/`valueOf` is invoked (for example, steps 1–6 of the addition operator). NuXJS may trigger these conversions sooner.
•Member-expression calls – NuXJS evaluates the object and argument expressions before resolving the property, which matches ES3’s algorithm but differs from ES5’s later reversal.
•Assignments – property, variable, and unqualified assignments resolve the left-hand reference before the right-hand side, matching ES3.
•Property access – the property key expression runs before the base is validated, but the base object is checked before the key is coerced and before any right-hand evaluation, matching ES3.
•Project guidelines explicitly warn contributors to avoid relying on these non-ES3 evaluation orders.

### Test262 coverage (externals/test262)
The following tables list every referenced Test262 evaluation-order case. Paths are relative to the Test262 `test/` directory.

#### Targeted assignment and property tests
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/assignment/S11.13.1_A7_T1.js | `base[prop] = expr` with `base` null; left side should run before right side | pass |
| language/expressions/assignment/S11.13.1_A7_T2.js | `base` undefined variant of the above | pass |
| language/expressions/assignment/S11.13.1_A7_T3.js | property key coercion throws before evaluating right side | pass |
| language/expressions/assignment/S11.13.1_A7_T4.js | property key coercion executed only once | pass |
| language/expressions/postfix-increment/S11.3.1_A6_T1.js | `base[prop]++` with `base` null should evaluate reference once | pass |
| language/expressions/prefix-increment/S11.4.4_A6_T1.js | `++base[prop]` with `base` null should evaluate reference once | pass |

#### ES3 evaluation order tests
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/call/S11.2.4_A1.4_T1.js | first argument assignment visible to later arguments | pass |
| language/expressions/call/S11.2.4_A1.4_T2.js | first argument evaluated before second, triggering ReferenceError | pass |
| language/expressions/call/S11.2.4_A1.4_T3.js | arguments `x=1,y=x,x+y` evaluated left to right | pass |
| language/expressions/call/S11.2.4_A1.4_T4.js | first argument throwing prevents evaluation of second | pass |
| language/expressions/addition/S11.6.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/addition/S11.6.1_A2.4_T1.js | assignments inside `+` are evaluated left to right | pass |
| language/expressions/subtraction/S11.6.2_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/multiplication/S11.5.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/division/S11.5.2_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/modulus/S11.5.3_A2.4_T1.js | assignments inside `%` are evaluated left to right | pass |
| language/expressions/left-shift/S11.7.1_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/right-shift/S11.7.2_A2.4_T1.js | assignments inside `>>` are evaluated left to right | pass |
| language/expressions/unsigned-right-shift/S11.7.3_A2.3_T1.js | ToNumber on left operand runs before right | pass |
| language/expressions/bitwise-xor/S11.10.2_A2.4_T1.js | assignments inside `^` are evaluated left to right | pass |
| language/expressions/less-than/S11.8.1_A2.4_T1.js | assignments inside `<` are evaluated left to right | pass |
| language/expressions/greater-than/S11.8.2_A2.3_T1.js | ToNumber left operand before right in `>` | pass |
| language/expressions/greater-than/S11.8.2_A2.4_T1.js | assignments inside `>` are evaluated left to right | pass |
| language/expressions/greater-than/11.8.2-1.js | left `valueOf` runs before right `valueOf` in `>` | pass |
| language/expressions/greater-than/11.8.2-2.js | left `valueOf` runs before right `toString` in `>` | pass |
| language/expressions/greater-than/11.8.2-3.js | left `toString` runs before right `valueOf` in `>` | pass |
| language/expressions/greater-than/11.8.2-4.js | left `toString` runs before right `toString` in `>` | pass |
| language/expressions/less-than-or-equal/11.8.3-1.js | left `valueOf` runs before right `valueOf` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-2.js | left `valueOf` runs before right `toString` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-3.js | left `toString` runs before right `valueOf` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-4.js | left `toString` runs before right `toString` in `<=` | pass |
| language/expressions/less-than-or-equal/11.8.3-5.js | mixed coercions still evaluate left side first in `<=` | pass |
| language/expressions/in/S11.8.7_A2.4_T1.js | assignments inside `in` are evaluated left to right | pass |
| language/expressions/strict-equals/S11.9.4_A2.4_T1.js | assignments inside `===` are evaluated left to right | pass |
| language/expressions/does-not-equals/S11.9.2_A2.4_T1.js | assignments inside `!=` are evaluated left to right | pass |

#### Non-ES3 features
| Test file | What it checks | Result |
| --- | --- | --- |
| language/expressions/exponentiation/exp-operator-evaluation-order.js | evaluation order for `**` operator (ES2016) | SyntaxError |
| language/expressions/template-literal/evaluation-order.js | evaluation order for template literals (ES2015) | SyntaxError |

These tests confirm NuXJS’s left-to-right operand evaluation for ES3 constructs.

## Current Implementation

### Assignment

The compiler now resolves every assignment target before the right‑hand side runs. For property targets, it emits `RESOLVE_PROPERTY_OP` to capture the base object and property name. For named and local variables, it performs a non‑throwing read (`TYPEOF_NAMED_OP` or `READ_LOCAL_OP`) and immediately discards the result so the scope chain is walked before compiling the right-hand expression. This mirrors the ES3 algorithm, which evaluates the *LeftHandSideExpression* prior to the *AssignmentExpression*【F:docs/specs/ECMA-262 3.md†L2879-L2884】【F:docs/specs/ECMA-262 3.md†L1770-L1782】.

`makeAssignment` then performs the write using the value currently on top of the stack:

```cpp
switch (xr.t) {
                case ExpressionResult::LOCAL: emit(Processor::WRITE_LOCAL_OP, xr.v.toInt()); break;
                case ExpressionResult::NAMED: emitWithConstant(Processor::WRITE_NAMED_OP, xr.v); break;
                case ExpressionResult::PROPERTY: emit(Processor::SET_PROPERTY_OP); break;
                ...
}
```【F:src/NuXJS.cpp†L3237-L3242】

Because named and local assignments skip the preliminary read, a missing variable triggers a `ReferenceError` only after the right‑hand side has executed. This remaining discrepancy is tracked in `evaluationOrderTodo.md`.

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

This order causes `toString`/`valueOf` on the property expression to run before `CheckObjectCoercible` on the base value, allowing observable side effects that differ from ES3.

### Method calls

NuXJS currently follows the ES3 algorithm, where argument evaluation precedes resolving the call target:

> The production `CallExpression : MemberExpression Arguments` is evaluated as follows:
> 1. Evaluate *MemberExpression*.
> 2. Evaluate *Arguments*, producing an internal list of argument values.
> 3. Call GetValue(Result(1)).【F:docs/specs/ECMA-262 3.md†L2098-L2103】

ES5.1 reversed steps 2 and 3 so the function is fetched before the arguments【F:docs/specs/ECMA-262 5.1.txt†L3199-L3205】. NuXJS retains the ES3 ordering: the member expression and arguments are compiled separately and the call target is resolved only after the arguments have finished evaluating.

The virtual machine performs the lookup immediately before invocation:

```cpp
Object* const o = convertToObject(sp[-im - 1], true);
if (o != 0) {
Value v(UNDEFINED_VALUE);
Function* f;
const Value& name = sp[-im];
if (o->getProperty(rt, name, &v) == NONEXISTENT || (f = v.asFunction()) == 0) {
error(TYPE_ERROR, new(heap) String(heap.managed(), *name.toString(heap), IS_NOT_A_FUNCTION_STRING));
} else {
invokeFunction(f, im + 1, im, o);
}
}
```【F:src/NuXJS.cpp†L2579-L2588】

This allows side effects in argument expressions to change the method or `this` value before the call, matching ES3 behaviour without extra opcodes.

To adopt ES5.1's target-first semantics, the compiler must fetch the method and base before running the arguments. One way is to resolve the property and stash the original pair on the stack:

```
emit(Processor::RESOLVE_PROPERTY_OP);
emit(Processor::REPUSH_OP, -1);
emit(Processor::SWAP_OP);
emit(Processor::GET_PROPERTY_OP);
```

Here `RESOLVE_PROPERTY_OP` converts the base and captures the property name, `REPUSH_OP` duplicates the base for `this`, and `SWAP_OP` arranges the stack so `GET_PROPERTY_OP` can obtain the function ahead of argument evaluation. After the arguments execute, the VM invokes the pre‑resolved function.

A dedicated `RESOLVE_METHOD_OP` could compress this sequence and avoid the temporary stack shuffling. NuXJS keeps ES3 ordering for now. Bringing the engine in line with ES5.1 would require this opcode sequence or an equivalent and is tracked as future Milestone 7 in `evaluationOrderTodo.md`.

This method-call ordering oversight went unnoticed in earlier analyses because the report focused on property access and assignment. Surfacing the issue required re-examining how property references behave when used as call targets.

### Accessor properties (getters and setters) — ES5.1 future work

ES3 has no concept of property getters or setters. The rules below come from ES5.1 and are
recorded here for planned future support:

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

> When control is transferred to ECMAScript executable code, control is entering an *execution context*. Active execution contexts logically form a stack. The top execution context on this logical stack is the running execution context.【F:docs/specs/ECMA-262 3.md†L1738-L1738】

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
* **Runtime:** Modify `GET_PROPERTY_OP` and `SET_PROPERTY_OP` so that they first call `convertToObject` on the base value (`CheckObjectCoercible`), *then* convert the property value using a `ToString` helper. This change ensures the conversion order follows ES3 and also means each property access performs `ToString` exactly once as specified.
* **Increment and compound assignments:** Review `PRE_INC_DEC`, `POST_INC_DEC`, and compound assignment paths to ensure they still preserve the correct stack layout when the property key is no longer pre‑converted.
* **Testing:** Create tests where the base value and property expression each have observable side effects (e.g. getters or `toString` methods) to confirm that the base coercion happens before property key conversion and that both occur exactly once.

### 3. Defer implicit conversions to spec points

Because `makeRValue` eagerly performs conversions such as `OBJ_TO_STRING_OP`, moving these conversions into the property opcodes will align the engine with the spec and eliminate cases where `valueOf`/`toString` executes earlier than required. Ensure that any other early conversions (e.g. within arithmetic operators) are audited to confirm they match ES3 rules.

## Additional Considerations

* Updating the compiler and VM to handle pre‑resolved references may require extra temporary storage on the operand stack. Care must be taken to maintain stack discipline so existing bytecode sequences remain valid.
* Performance impact should be measured; deferring resolution and conversions may change optimisation opportunities.
* The documentation in `docs/notes/ECMAScript Compatibility Notes.md` should be updated once conformance is achieved, and new tests should be added under `tests/` to guard against regressions.

## Summary

Bringing NuXJS in line with ES3 evaluation order (with ES5.1 semantics for getters and setters) requires front‑end and VM changes:

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

Given these risks, bringing NuXJS into alignment with ES3 evaluation order is a significant but important change. It touches fundamental bytecode generation and VM opcodes, yet it ensures that accessor side effects occur only when mandated by the specification and that property lookups behave predictably across engines.

## Incremental Implementation Plan

Implementing ES‑compliant ordering affects both compilation and runtime. The change can be staged to keep each patch reviewable:

1. **Introduce `CHECK_OBJECT_COERCIBLE_OP`.**
* Add a new opcode after `SET_PROPERTY_POP_OP` so the VM can perform `CheckObjectCoercible`/`ToObject` on the base value before any property lookup. This lives alongside the existing property opcodes in the enumeration【F:src/NuXJS.h†L1655-L1666】.
* The handler replaces the `convertToObject` calls currently embedded in `GET_PROPERTY_OP` and `SET_PROPERTY_OP`, leaving those opcodes to assume a pre‑checked base【F:src/NuXJS.cpp†L2791-L2808】【F:src/NuXJS.cpp†L2820-L2834】.

2. **Adjust property opcodes to accept raw keys.**
* With base conversion factored out, `GET_PROPERTY_OP` and `SET_PROPERTY_OP` operate on an object and an uncoerced key, preserving their short critical paths and cooperative granularity.

3. **Reorder compilation of bracket notation.**
* In the `PROPERTY_BRACKETS` parser branch, evaluate the base and key expressions without conversions, then emit `CHECK_OBJECT_COERCIBLE_OP` followed by `OBJ_TO_STRING_OP`. This mirrors ES3’s steps of checking the base before converting the property name【F:docs/specs/ECMA-262 3.md†L2063-L2071】【F:src/NuXJS.cpp†L4149-L4156】【F:src/NuXJS.cpp†L3627-L3642】.

4. **Resolve left‑hand references before right‑hand sides.**
* `makeAssignment` currently emits `SET_PROPERTY_OP` as soon as the right‑hand value is on the stack【F:src/NuXJS.cpp†L3670-L3676】. Modify assignment lowering so the reference resolution sequence (`CHECK_OBJECT_COERCIBLE_OP` + `OBJ_TO_STRING_OP`) runs before compiling the right‑hand side, then perform the store. This satisfies the spec’s requirement to obtain *lref* before evaluating the RHS【F:docs/specs/ECMA-262 3.md†L2879-L2888】.

5. **Extend the sequence to all property‑based constructs.**
* Apply the new ordering to method calls, compound assignments, and operators like `in` or `delete` so every property reference observes the same semantics.

6. **Add conformance tests.**
* Create regression tests exercising getters, setters, and `toString`/`valueOf` hooks to verify that key conversion and right‑hand side effects occur only after the base object is validated.

7. **Audit remaining early conversions.**
* After property and assignment paths are updated, review other uses of `OBJ_TO_*` in `makeRValue` to ensure no opcode performs observable conversions earlier than the ES3 algorithms allow.

By approaching the migration in these steps, NuXJS can move toward full ES3 ordering (with ES5.1 semantics for getters and setters) while preserving its cooperative, cycle‑based VM design.

## Future ES5.1 work

The current effort stops at ES3 conformance. Advancing to ES5.1 would require:

* Resolving method-call targets before argument evaluation (see Milestone 5).
* Executing getters and setters only after base and property-name coercion (see Milestone 6).

These tasks remain open and are documented here so they are not lost.

