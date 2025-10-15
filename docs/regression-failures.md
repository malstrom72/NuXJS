# Regression Failures TODO

The following regression tests currently fail. Each item links the observed mismatch to the relevant ECMAScript 5.1 clause for reference while we work through fixes.

## Function property invariants
- [ ] `functionLengthNotDeletable.io` – Built-in function `length` properties are non-writable, non-enumerable, and non-configurable, so deleting them must fail. 【F:docs/specs/ECMA-262 5.1.md†L6510-L6514】

## IEEE-754 conformance
- [ ] `IncorrectSubnormal.io` – Subnormal number rounding must follow IEEE “round to nearest, ties to even”. 【F:docs/specs/ECMA-262 5.1.md†L2204-L2238】
- [ ] `mathPowSpecialCases.io` – `Math.pow` has explicit results for ±0, ±1, and infinite exponents that must be respected. 【F:docs/specs/ECMA-262 5.1.txt†L6614-L6639】
- [ ] `powEdgeCases.io` – Raising ±1 to infinite exponents must yield `NaN` per the `Math.pow` special cases. 【F:docs/specs/ECMA-262 5.1.txt†L6614-L6639】

## Array length and indexed property semantics
- [ ] `arrayIndexTooLarge.io` – Non-canonical property names must not change array length; indices are constrained by the array `[[DefineOwnProperty]]` algorithm. 【F:docs/specs/ECMA-262 5.1.md†L5571-L5619】
- [x] `arrayPopPrototypeDelete.io` – `Array.prototype.pop` must delete the final own index before reading inherited values. 【F:docs/specs/ECMA-262 5.1.md†L4943-L4958】【F:docs/specs/ECMA-262 5.1.md†L5571-L5619】
- [x] `arrayPopPrototypeExposure.io` – After popping, array lookup should fall back to prototype data when the own element is removed. 【F:docs/specs/ECMA-262 5.1.md†L4943-L4958】
- [x] `arrayShiftNegativeLength.io` – `Array.prototype.shift` must use `ToUint32(length)` so negative lengths coerce to valid counters. 【F:docs/specs/ECMA-262 5.1.md†L5016-L5039】
- [x] `arrayShiftPrototypeDelete.io` – `shift` must delete vacated indices so inherited values are revealed. 【F:docs/specs/ECMA-262 5.1.md†L5016-L5039】
- [x] `arrayShiftPrototypeExposure.io` – Prototype elements must surface after shifting removes own entries. 【F:docs/specs/ECMA-262 5.1.md†L5016-L5039】
- [ ] `arrayPushBorrowedLengthOverflow.io` – `Array.prototype.push` must honour 32-bit length limits and throw once the array index space is exhausted. 【F:docs/specs/ECMA-262 5.1.md†L4962-L4977】【F:docs/specs/ECMA-262 5.1.md†L5571-L5619】
- [ ] `validArrayLengths.io` – Assigning `length` must apply `ToUint32`, rejecting non-integer values and enforcing range checks. 【F:docs/specs/ECMA-262 5.1.md†L5571-L5619】
- [ ] `variousInvalidArrayIndices.io` – Only canonical array index strings below 2^32−1 affect length; other keys stay as ordinary properties. 【F:docs/specs/ECMA-262 5.1.md†L5571-L5619】

## Array element stringification
- [ ] `arrayToLocaleStringCallsElements.io` – `toLocaleString` must invoke each element’s `toLocaleString` method, even when values are objects or inherited. 【F:docs/specs/ECMA-262 5.1.md†L4846-L4876】
- [ ] `arrayToLocaleStringElementCall.io` – Objects stored in the array must have their `toLocaleString` invoked. 【F:docs/specs/ECMA-262 5.1.md†L4846-L4876】
- [ ] `arrayToLocaleStringPrototypeElement.io` – Sparse slots should consult prototype elements during `toLocaleString`. 【F:docs/specs/ECMA-262 5.1.md†L4846-L4876】
- [ ] `arrayToLocaleStringPrototypeLookup.io` – Missing elements must fall back to prototype-defined entries. 【F:docs/specs/ECMA-262 5.1.md†L4846-L4876】

## Property access ordering
- [x] `assignmentPropertyKeyCoercionBeforeBaseCheck.io` – The base object must be checked for `null`/`undefined` before coercing the computed property key. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】【F:docs/specs/ECMA-262 5.1.md†L3292-L3305】
- [x] `assignmentRightSideBeforeBaseCheck.io` – The left-hand side reference is evaluated before computing the right-hand value for `=` assignments, so a `TypeError` must occur without evaluating the RHS when the base is `null`. 【F:docs/specs/ECMA-262 5.1.md†L5719-L5730】
- [x] `evalOrderOfBaseAndName.io` – `CheckObjectCoercible` occurs before converting the property name, preventing accessor side-effects when the base is invalid. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】
- [x] `nameAndRhsBeforeBaseCheck.io` – For property assignments the base is validated before key coercion or RHS evaluation, so no side-effects should run when the base is `null`. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】【F:docs/specs/ECMA-262 5.1.md†L5719-L5730】

## Date handling
- [ ] `datePrototypeSetFullYearInvalidThis.io` – Date prototype methods must throw if `this` is not a Date object. 【F:docs/specs/ECMA-262 5.1.md†L9398-L9404】【F:docs/specs/ECMA-262 5.1.md†L9811-L9824】
- [ ] `dateSetFullYearPrototypeGuard.io` – The `setFullYear` algorithm should reject non-Date receivers. 【F:docs/specs/ECMA-262 5.1.md†L9398-L9404】【F:docs/specs/ECMA-262 5.1.md†L9811-L9824】
- [ ] `dateTimeClipNegativeZero.io` – `TimeClip` converts −0 to +0 so reciprocals must yield `Infinity`. 【F:docs/specs/ECMA-262 5.1.md†L9164-L9170】
- [ ] `dateTimeClipNormalizesNegativeZero.io` – `TimeClip` normalisation ensures stored times compare strictly equal to +0. 【F:docs/specs/ECMA-262 5.1.md†L9164-L9170】
- [ ] `dateYearMonthDateHoursMinutesSecondsUndefined.io` – Passing `undefined` arguments should produce `NaN` because each component is processed with `ToNumber`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9297】
- [ ] `dateYearMonthDateHoursMinutesUndefined.io` – An explicit `undefined` minutes argument must coerce to `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9297】
- [ ] `dateYearMonthDateHoursUndefined.io` – Undefined hours propagate as `NaN` via `ToNumber`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9297】
- [ ] `dateYearMonthDateUndefined.io` – An explicit undefined date argument should become `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9297】
- [ ] `dateYearMonthUndefined.io` – Undefined month arguments must also yield `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9297】

## String indexing
- [ ] `emptyStringIndex20190507.io` – String exotic objects only expose canonical numeric indices; other property names return `undefined`. 【F:docs/specs/ECMA-262 5.1.md†L6066-L6076】

## Error object properties
- [x] `errorConstructorUndefinedMessage.io` – `new Error()` only creates a `message` own property when the argument is provided. 【F:docs/specs/ECMA-262 5.1.txt†L8217-L8232】
- [x] `errorFunctionUndefinedMessage.io` – Calling `Error()` as a function follows the same rule for the optional `message`. 【F:docs/specs/ECMA-262 5.1.txt†L8217-L8232】
- [x] `errorPrototypeNameEnumerable.io` – `Error.prototype` only defines the non-enumerable `name` and `message` defaults, so iteration should not observe `name`. 【F:docs/specs/ECMA-262 5.1.txt†L8263-L8269】
- [ ] `stackLineNumbers.io` – ES5.1 does not standardise `Error.prototype.stack`; the engine-specific stack trace should still surface accurate function names and source coordinates. 【F:docs/specs/ECMA-262 5.1.txt†L8263-L8272】
- [ ] `stackPropertyNames.io` – The non-standard `stack` string should still include callee names in the expected format. 【F:docs/specs/ECMA-262 5.1.txt†L8263-L8272】
- [ ] `stackTraceVerbatim.io` – Stack traces should preserve exact naming and punctuation even though `stack` is implementation-defined. 【F:docs/specs/ECMA-262 5.1.txt†L8263-L8272】

## Function prototype construction
- [x] `functionPrototypeConstructible.io` – `Function.prototype` is callable but not constructible; `new Function.prototype()` must throw. 【F:docs/specs/ECMA-262 5.1.txt†L4578-L4590】
- [x] `functionPrototypeNotConstructable.io` – Constructing `Function.prototype` should raise a `TypeError`. 【F:docs/specs/ECMA-262 5.1.txt†L4578-L4590】

## Numeric parsing
- [x] `parseInt0XPrefix.io` – `parseInt` must treat `0x`/`0X` prefixes as hexadecimal even when no radix is supplied. 【F:docs/specs/ECMA-262 5.1.txt†L4106-L4115】
- [x] `parseIntRadix16Uppercase.io` – Hexadecimal parsing is case-insensitive when the radix is 16. 【F:docs/specs/ECMA-262 5.1.txt†L4106-L4115】

## Regular expression exec semantics
- [ ] `regExpExecBooleanObject.io` – `RegExp.prototype.exec` coerces the argument with `ToString`, so Boolean objects must unwrap before matching. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecNestedCaptures.io` – The exec result array must include nested captures per the matching algorithm. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8161】
- [ ] `regExpExecNumberObject.io` – Number objects must be stringified before matching. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecObjectString.io` – Objects providing `toString` must be coerced to strings for the search. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecToStringFalse.io` – Custom `toString` return values need to drive the input string for matching. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecToStringObject.io` – Exec must use the string returned by `toString`, not `[object Object]`. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecToStringPi.io` – Numbers produced by `toString` must be matched verbatim. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】
- [ ] `regExpExecValueOfObject.io` – If `toString` returns a non-string, `valueOf` provides the fallback string for matching. 【F:docs/specs/ECMA-262 5.1.txt†L8126-L8153】

## String replacement placeholders
- [ ] `stringReplace11Concat.io` – Replacement text must honour `$n` and related substitution patterns. 【F:docs/specs/ECMA-262 5.1.md†L5841-L5864】
- [ ] `stringReplace11Plus15.io` – Double-digit capture substitutions such as `$11` and `$15` must resolve to the correct captures. 【F:docs/specs/ECMA-262 5.1.md†L5841-L5864】
- [ ] `stringReplace11PlusA15.io` – Literal characters adjoining `$nn` tokens should not alter capture resolution. 【F:docs/specs/ECMA-262 5.1.md†L5841-L5864】
- [ ] `stringReplaceBackreference.io` – `$&`, `$'`, and related tokens must behave per Table 22 in the spec. 【F:docs/specs/ECMA-262 5.1.md†L5848-L5864】
- [ ] `stringReplaceSearchToStringOrder.io` – Search values must be coerced with `ToString` prior to matching. 【F:docs/specs/ECMA-262 5.1.md†L5841-L5854】
- [ ] `stringReplaceTwoDigitBackreference.io` – `$nn` references should bind to the nth capture or remain literal if out of range. 【F:docs/specs/ECMA-262 5.1.md†L5848-L5864】

