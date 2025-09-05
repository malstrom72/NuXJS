# ES3 Test262 Failures Analysis
81 Test262 tests from the ES3 portion of Test262 still fail in NuXJS. All of these tests target ES3 semantics that NuXJS does not yet implement correctly.
| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Array | §15.4 | 9 |
| Date | §15.9 | 7 |
| Error | §15.11 | 5 |
| Function | §15.3 | 1 |
| Infinity |  | 1 |
| Math | §15.8 | 2 |
| NaN |	 | 1 |
| Number | §15.7 | 3 |
| Object | §15.2 | 12 |
| RegExp | §15.10 | 18 |
| String | §15.5 | 17 |
| parseFloat |	| 1 |
| parseInt |  | 3 |
| undefined |  | 1 |

Tests that rely on the optional URI helpers (`decodeURI`, `encodeURI`, and their component variants) are excluded: cases targeting these helpers are marked as by_design, while unrelated tests that require them are tagged bad_test.

Each list below states the ES3 requirement that the corresponding test checks. NuXJS currently violates these behaviors.

When an item is resolved, check it off and add a brief note citing the ES3 spec section and the regression `.io` test that verifies the fix.

### Array
- [ ] built-ins/Array/S15.4.5.1_A2.1_T1 — P in [4294967295, -1, true]
- [ ] built-ins/Array/S15.4_A1.1_T1 — Checking for boolean primitive
- [ ] built-ins/Array/prototype/pop/S15.4.4.6_A2_T2 — If ToUint32(length) equal zero, call the [[Put]] method	 of this object with arguments "length" and 0 and return undefined
- [ ] built-ins/Array/prototype/pop/S15.4.4.6_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
- [ ] built-ins/Array/prototype/push/S15.4.4.7_A2_T2 — The arguments are appended to the end of the array, in	 the order in which they appear. The new length of the array is returned  as the result of the call
- [ ] built-ins/Array/prototype/shift/S15.4.4.9_A3_T3 — length is arbitrarily
- [ ] built-ins/Array/prototype/shift/S15.4.4.9_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
- [ ] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1 — it is the function that should be invoked
- [ ] built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1 — "[[Prototype]] of Array instance is Array.prototype"

### Date
- [ ] built-ins/Date/S15.9.3.1_A6_T1 — 2 arguments, (year, month)
- [ ] built-ins/Date/S15.9.3.1_A6_T2 — 3 arguments, (year, month, date)
- [ ] built-ins/Date/S15.9.3.1_A6_T3 — 4 arguments, (year, month, date, hours)
- [ ] built-ins/Date/S15.9.3.1_A6_T4 — 5 arguments, (year, month, date, hours, minutes)
- [ ] built-ins/Date/S15.9.3.1_A6_T5 — 6 arguments, (year, month, date, hours, minutes, seconds)
- [ ] built-ins/Date/TimeClip_negative_zero — TimeClip converts negative zero to positive zero
- [ ] built-ins/Date/prototype/setFullYear/15.9.5.40_1 — Date.prototype.setFullYear - Date.prototype is itself not an instance of Date

### Error
- [ ] built-ins/Error/S15.11.1.1_A1_T1 — Checking message property of different error objects
- [ ] built-ins/Error/S15.11.2.1_A1_T1 — Checking message property of different error objects
- [ ] built-ins/Error/prototype/S15.11.4_A2 — Getting the value of the internal [[Class]] property using Error.prototype.toString() function
- [ ] built-ins/Error/prototype/name/15.11.4.2-1 — Error.prototype.name is not enumerable.
- [ ] built-ins/Error/prototype/toString/15.11.4.4-8-1 — Error.prototype.toString return the value of 'msg' when 'name' is empty string and 'msg' isn't undefined

### Function
- [ ] built-ins/Function/prototype/S15.3.4_A5 — Checking if creating "new Function.prototype object" fails

### Infinity
- [ ] built-ins/Infinity/S15.1.1.2_A2_T2 — Checking typeof Functions

### Math
- [ ] built-ins/Math/pow/applying-the-exp-operator_A7 — If abs(base) is 1 and exponent is +∞, the result is NaN.
- [ ] built-ins/Math/pow/applying-the-exp-operator_A8 — If abs(base) is 1 and exponent is −∞, the result is NaN.

### NaN
- [ ] built-ins/NaN/S15.1.1.1_A2_T2 — Checking typeof Functions

### Number
- [ ] built-ins/Number/S9.3.1_A2 — Strings with various WhiteSpaces convert to Number by explicit transformation
- [ ] built-ins/Number/S9.3.1_A3_T1 — static string
- [ ] built-ins/Number/S9.3.1_A3_T2 — dynamic string

### Object
- [ ] built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/toLocaleString/S15.2.4.3_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A12 — Checking Object.prototype.valueOf invoked by the 'call' property.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A13 — Checking Object.prototype.valueOf invoked by the 'call' property.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A14 — Checking Object.prototype.valueOf invoked by the 'call' property.
- [ ] built-ins/Object/prototype/valueOf/S15.2.4.4_A15 — Checking Object.prototype.valueOf when called as a global function.

> Tests exercising `Object.prototype.toString` with `undefined` or `null` have been dropped: ES3 does not specify the method's behaviour for these values.

### RegExp
- [ ] built-ins/RegExp/S15.10.2.12_A1_T1 — WhiteSpace
- [ ] built-ins/RegExp/S15.10.2.12_A2_T1 — WhiteSpace
- [ ] built-ins/RegExp/S15.10.2.8_A3_T15 — "see bug http:bugzilla.mozilla.org/show_bug.cgi?id=119909" — RangeError: Internal compiler limitations reached. Reduce code complexity.
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10 — String is 1.01 and RegExp is /1|12/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11 — String is new Number(1.012) and RegExp is /2|12/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12 — String is {toString:function(){return Math.PI;}} and RegExp is /\.14/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13 — String is true and RegExp is /t[a-b|q-s]/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14 — String is new Boolean and RegExp is /AL|se/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15 — "String is {toString:function(){return false;}} and RegExp is /LS/i"
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17 — String is null and RegExp is /ll|l/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18 — String is undefined and RegExp is /nd|ne/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19 — String is void 0 and RegExp is /e{1}/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2 — String is new String("123") and RegExp is /((1)|(12))((3)|(23))/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20 — String is x and RegExp is /[a-f]d/, where x is undefined variable
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21 — String is function(){}() and RegExp is /[a-z]n/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3 — String is new Object("abcdefghi") and RegExp is /a[a-z]{2,4}/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4 — String is {toString:function(){return "abcdefghi";}} and RegExp is /a[a-z]{2,4}?/
- [ ] built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5 — String is {toString:function(){return {};}, valueOf:function(){return "aabaac";}} and RegExp is /(aa|aabaac|ba|b|c)* /

### String
- [ ] built-ins/String/prototype/indexOf/S15.5.4.7_A1_T11 — calling `indexOf` with Date object `this` yields wrong index
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A12 — `replace` should treat undefined `this` correctly
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T11 — replacing with objects whose `toString` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A1_T12 — replacing with object whose `valueOf` throws
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T1 — `replaceValue` is "$11" + 15
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T2 — `replaceValue` is "$11" + "15"
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A3_T3 — `replaceValue` is "$11" + "A15"
- [ ] built-ins/String/prototype/replace/S15.5.4.11_A5_T1 — regex `/^(a+)\1*,\1+$/` with backreference
- [ ] built-ins/String/prototype/toLocaleLowerCase/special_casing_conditional — missing conditional Unicode mappings
- [ ] built-ins/String/prototype/toLocaleLowerCase/supplementary_plane — fails to iterate over supplementary-plane code points
- [ ] built-ins/String/prototype/toLocaleUpperCase/special_casing — missing special Unicode casing mappings
- [ ] built-ins/String/prototype/toLocaleUpperCase/supplementary_plane — fails to iterate over supplementary-plane code points
- [ ] built-ins/String/prototype/toLowerCase/special_casing — missing special Unicode lowercase mappings
- [ ] built-ins/String/prototype/toLowerCase/special_casing_conditional — missing conditional lowercase mappings
- [ ] built-ins/String/prototype/toLowerCase/supplementary_plane — fails to iterate over supplementary-plane code points
- [ ] built-ins/String/prototype/toUpperCase/special_casing — missing special Unicode uppercase mappings
- [ ] built-ins/String/prototype/toUpperCase/supplementary_plane — fails to iterate over supplementary-plane code points
### parseFloat
- [ ] built-ins/parseFloat/S15.1.2.3_A2_T10 — "StrWhiteSpaceChar :: USP"

### parseInt
- [ ] built-ins/parseInt/S15.1.2.2_A2_T10 — "StrWhiteSpaceChar :: USP"
- [ ] built-ins/parseInt/S15.1.2.2_A5.2_T2 — ": 0X"
- [ ] built-ins/parseInt/S15.1.2.2_A7.2_T3 — Checking algorithm for R = 16

### undefined
- [ ] built-ins/undefined/15.1.1.3-1 — undefined is not writable, should not throw in non-strict mode
