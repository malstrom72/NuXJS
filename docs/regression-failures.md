# Regression Failures TODO

The following regression tests currently fail. Each item links the observed mismatch to the relevant ECMAScript 5.1 clause for reference while we work through fixes.

## Function property invariants
- [x] `functionLengthNotDeletable.io` – Built-in function `length` properties are non-writable, non-enumerable, and non-configurable, so deleting them must fail. 【F:docs/specs/ECMA-262 5.1.md†L6510-L6514】

## IEEE-754 conformance
- [x] `IncorrectSubnormal.io` – Subnormal number rounding must follow IEEE “round to nearest, ties to even”. 【F:docs/specs/ECMA-262 5.1.md†L2204-L2238】
- [x] `mathPowSpecialCases.io` – `Math.pow` has explicit results for ±0, ±1, and infinite exponents that must be respected. 【F:docs/specs/ECMA-262 5.1.md†L8788-L8814】
- [x] `powEdgeCases.io` – Raising ±1 to infinite exponents must yield `NaN` per the `Math.pow` special cases. 【F:docs/specs/ECMA-262 5.1.md†L8788-L8814】

## Array length and indexed property semantics
- [x] `arrayIndexTooLarge.io` – Non-canonical property names must not change array length; indices are constrained by the array `[[DefineOwnProperty]]` algorithm. 【F:docs/specs/ECMA-262 5.1.md†L7496-L7544】
- [x] `arrayPopPrototypeDelete.io` – `Array.prototype.pop` must delete the final own index before reading inherited values. 【F:docs/specs/ECMA-262 5.1.md†L6794-L6808】
- [x] `arrayPopPrototypeExposure.io` – After popping, array lookup should fall back to prototype data when the own element is removed. 【F:docs/specs/ECMA-262 5.1.md†L6794-L6808】
- [x] `arrayShiftNegativeLength.io` – `Array.prototype.shift` must use `ToUint32(length)` so negative lengths coerce to valid counters. 【F:docs/specs/ECMA-262 5.1.md†L6879-L6903】
- [x] `arrayShiftPrototypeDelete.io` – `shift` must delete vacated indices so inherited values are revealed. 【F:docs/specs/ECMA-262 5.1.md†L6879-L6903】
- [x] `arrayShiftPrototypeExposure.io` – Prototype elements must surface after shifting removes own entries. 【F:docs/specs/ECMA-262 5.1.md†L6879-L6903】
- [x] `arrayPushBorrowedLengthOverflow.io` – `Array.prototype.push` must honour 32-bit length limits and throw once the array index space is exhausted. 【F:docs/specs/ECMA-262 5.1.md†L6817-L6832】【F:docs/specs/ECMA-262 5.1.md†L7496-L7544】
- [x] `validArrayLengths.io` – Assigning `length` must apply `ToUint32`, rejecting non-integer values and enforcing range checks. 【F:docs/specs/ECMA-262 5.1.md†L7509-L7534】
- [x] `variousInvalidArrayIndices.io` – Only canonical array index strings below 2^32−1 affect length; other keys stay as ordinary properties. 【F:docs/specs/ECMA-262 5.1.md†L7536-L7544】

## Array element stringification
- [x] `arrayToLocaleStringCallsElements.io` – `toLocaleString` must invoke each element’s `toLocaleString` method, even when values are objects or inherited. 【F:docs/specs/ECMA-262 5.1.md†L6683-L6715】
- [x] `arrayToLocaleStringElementCall.io` – Objects stored in the array must have their `toLocaleString` invoked. 【F:docs/specs/ECMA-262 5.1.md†L6683-L6715】
- [x] `arrayToLocaleStringPrototypeElement.io` – Sparse slots should consult prototype elements during `toLocaleString`. 【F:docs/specs/ECMA-262 5.1.md†L6683-L6715】
- [x] `arrayToLocaleStringPrototypeLookup.io` – Missing elements must fall back to prototype-defined entries. 【F:docs/specs/ECMA-262 5.1.md†L6683-L6715】

## Property access ordering
- [x] `assignmentPropertyKeyCoercionBeforeBaseCheck.io` – The base object must be checked for `null`/`undefined` before coercing the computed property key. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】【F:docs/specs/ECMA-262 5.1.md†L3292-L3305】
- [x] `assignmentRightSideBeforeBaseCheck.io` – The left-hand side reference is evaluated before computing the right-hand value for `=` assignments, so a `TypeError` must occur without evaluating the RHS when the base is `null`. 【F:docs/specs/ECMA-262 5.1.md†L5719-L5730】
- [x] `evalOrderOfBaseAndName.io` – `CheckObjectCoercible` occurs before converting the property name, preventing accessor side-effects when the base is invalid. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】
- [x] `nameAndRhsBeforeBaseCheck.io` – For property assignments the base is validated before key coercion or RHS evaluation, so no side-effects should run when the base is `null`. 【F:docs/specs/ECMA-262 5.1.md†L4390-L4399】【F:docs/specs/ECMA-262 5.1.md†L5719-L5730】

## Date handling
- [x] `datePrototypeSetFullYearInvalidThis.io` – Date prototype methods must throw if `this` is not a Date object. 【F:docs/specs/ECMA-262 5.1.md†L9398-L9404】【F:docs/specs/ECMA-262 5.1.md†L9811-L9824】
- [x] `dateSetFullYearPrototypeGuard.io` – The `setFullYear` algorithm should reject non-Date receivers. 【F:docs/specs/ECMA-262 5.1.md†L9398-L9404】【F:docs/specs/ECMA-262 5.1.md†L9811-L9824】
- [x] `dateTimeClipNegativeZero.io` – `TimeClip` converts −0 to +0 so reciprocals must yield `Infinity`. 【F:docs/specs/ECMA-262 5.1.md†L9164-L9170】
- [x] `dateTimeClipNormalizesNegativeZero.io` – `TimeClip` normalisation ensures stored times compare strictly equal to +0. 【F:docs/specs/ECMA-262 5.1.md†L9164-L9170】
- [x] `dateYearMonthDateHoursMinutesSecondsUndefined.io` – Passing `undefined` arguments should produce `NaN` because each component is processed with `ToNumber`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9294】
- [x] `dateYearMonthDateHoursMinutesUndefined.io` – An explicit `undefined` minutes argument must coerce to `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9294】
- [x] `dateYearMonthDateHoursUndefined.io` – Undefined hours propagate as `NaN` via `ToNumber`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9294】
- [x] `dateYearMonthDateUndefined.io` – An explicit undefined date argument should become `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9294】
- [x] `dateYearMonthUndefined.io` – Undefined month arguments must also yield `NaN`. 【F:docs/specs/ECMA-262 5.1.md†L9288-L9294】

## String indexing
- [x] `emptyStringIndex20190507.io` – String exotic objects only expose canonical numeric indices; other property names return `undefined`. 【F:docs/specs/ECMA-262 5.1.md†L8108-L8124】

## Error object properties
- [x] `errorConstructorUndefinedMessage.io` – `new Error()` only creates a `message` own property when the argument is provided. 【F:docs/specs/ECMA-262 5.1.md†L10999-L11010】
- [x] `errorFunctionUndefinedMessage.io` – Calling `Error()` as a function follows the same rule for the optional `message`. 【F:docs/specs/ECMA-262 5.1.md†L10979-L10992】
- [x] `errorPrototypeNameEnumerable.io` – `Error.prototype` only defines the non-enumerable `name` and `message` defaults, so iteration should not observe `name`. 【F:docs/specs/ECMA-262 5.1.md†L11031-L11052】
- [x] `stackLineNumbers.io` – ES5.1 does not standardise `Error.prototype.stack`; the engine-specific stack trace should still surface accurate function names and source coordinates. 【F:docs/specs/ECMA-262 5.1.md†L11031-L11052】
- [x] `stackPropertyNames.io` – The non-standard `stack` string should still include callee names in the expected format. 【F:docs/specs/ECMA-262 5.1.md†L11031-L11052】
- [x] `stackTraceVerbatim.io` – Stack traces should preserve exact naming and punctuation even though `stack` is implementation-defined. 【F:docs/specs/ECMA-262 5.1.md†L11031-L11052】

## Function prototype construction
- [x] `functionPrototypeConstructible.io` – `Function.prototype` is callable but not constructible; `new Function.prototype()` must throw. 【F:docs/specs/ECMA-262 5.1.md†L6362-L6368】
- [x] `functionPrototypeNotConstructable.io` – Constructing `Function.prototype` should raise a `TypeError`. 【F:docs/specs/ECMA-262 5.1.md†L6362-L6368】

## Numeric parsing
- [x] `parseInt0XPrefix.io` – `parseInt` must treat `0x`/`0X` prefixes as hexadecimal even when no radix is supplied. 【F:docs/specs/ECMA-262 5.1.md†L5719】
- [x] `parseIntRadix16Uppercase.io` – Hexadecimal parsing is case-insensitive when the radix is 16. 【F:docs/specs/ECMA-262 5.1.md†L5719】

## Regular expression exec semantics
- [x] `regExpExecBooleanObject.io` – `RegExp.prototype.exec` coerces the argument with `ToString`, so Boolean objects must unwrap before matching. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecNestedCaptures.io` – The exec result array must include nested captures per the matching algorithm. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecNumberObject.io` – Number objects must be stringified before matching. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecObjectString.io` – Objects providing `toString` must be coerced to strings for the search. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecToStringFalse.io` – Custom `toString` return values need to drive the input string for matching. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecToStringObject.io` – Exec must use the string returned by `toString`, not `[object Object]`. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecToStringPi.io` – Numbers produced by `toString` must be matched verbatim. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】
- [x] `regExpExecValueOfObject.io` – If `toString` returns a non-string, `valueOf` provides the fallback string for matching. 【F:docs/specs/ECMA-262 5.1.md†L10867-L10905】

## String replacement placeholders
- [x] `stringReplace11Concat.io` – Replacement text must honour `$n` and related substitution patterns. 【F:docs/specs/ECMA-262 5.1.md†L7830-L7853】
- [x] `stringReplace11Plus15.io` – Double-digit capture substitutions such as `$11` and `$15` must resolve to the correct captures. 【F:docs/specs/ECMA-262 5.1.md†L7830-L7853】
- [x] `stringReplace11PlusA15.io` – Literal characters adjoining `$nn` tokens should not alter capture resolution. 【F:docs/specs/ECMA-262 5.1.md†L7830-L7853】
- [x] `stringReplaceBackreference.io` – `$&`, `$'`, and related tokens must behave per Table 22 in the spec. 【F:docs/specs/ECMA-262 5.1.md†L7830-L7853】
- [x] `stringReplaceSearchToStringOrder.io` – Search values must be coerced with `ToString` prior to matching. 【F:docs/specs/ECMA-262 5.1.md†L7832-L7841】
- [x] `stringReplaceTwoDigitBackreference.io` – `$nn` references should bind to the nth capture or remain literal if out of range. 【F:docs/specs/ECMA-262 5.1.md†L7830-L7853】

