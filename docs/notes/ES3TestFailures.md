# ES3 Test262 Failures Analysis
109 Test262 tests that target ECMAScript 3 features still fail in NuXJS. The table summarizes the failing areas:
| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Array | §15.4 | 12 |
| Date | §15.9 | 7 |
| Error | §15.11 | 5 |
| Function | §15.3 | 1 |
| Infinity |  | 1 |
| Math | §15.8 | 2 |
| NaN |  | 1 |
| Number | §15.7 | 3 |
| Object | §15.2 | 16 |
| RegExp | §15.10 | 18 |
| String | §15.5 | 33 |
| eval |  | 1 |
| isFinite |  | 1 |
| isNaN |  | 1 |
| parseFloat |  | 2 |
| parseInt |  | 4 |
| undefined |  | 1 |

Tests that rely on the optional URI helpers (`decodeURI`, `encodeURI`, and their component variants) are excluded: cases targeting these helpers are marked as by_design, while unrelated tests that require them are tagged bad_test.

Each list below states the ES3 requirement that the corresponding test checks. NuXJS currently violates these behaviors.

### Array
- built-ins/Array/S15.4.5.1_A2.1_T1 — P in [4294967295, -1, true]
- built-ins/Array/S15.4_A1.1_T1 — Checking for boolean primitive
- built-ins/Array/prototype/pop/S15.4.4.6_A2_T2 — If ToUint32(length) equal zero, call the [[Put]] method  of this object with arguments "length" and 0 and return undefined
- built-ins/Array/prototype/pop/S15.4.4.6_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
- built-ins/Array/prototype/push/S15.4.4.7_A2_T2 — The arguments are appended to the end of the array, in  the order in which they appear. The new length of the array is returned  as the result of the call
- built-ins/Array/prototype/shift/S15.4.4.9_A3_T3 — length is arbitrarily
- built-ins/Array/prototype/shift/S15.4.4.9_A4_T2 — [[Prototype]] of Array instance is Array.prototype, [[Prototype] of Array.prototype is Object.prototype
- built-ins/Array/prototype/sort/S15.4.4.11_A7.2 — Checking use hasOwnProperty, delete
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1 — it is the function that should be invoked
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1 — "[[Prototype]] of Array instance is Array.prototype"
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A4.2 — Checking use hasOwnProperty, delete
- built-ins/Array/prototype/toString/S15.4.4.2_A4.2 — Checking use hasOwnProperty, delete

### Date
- built-ins/Date/S15.9.3.1_A6_T1 — 2 arguments, (year, month)
- built-ins/Date/S15.9.3.1_A6_T2 — 3 arguments, (year, month, date)
- built-ins/Date/S15.9.3.1_A6_T3 — 4 arguments, (year, month, date, hours)
- built-ins/Date/S15.9.3.1_A6_T4 — 5 arguments, (year, month, date, hours, minutes)
- built-ins/Date/S15.9.3.1_A6_T5 — 6 arguments, (year, month, date, hours, minutes, seconds)
- built-ins/Date/TimeClip_negative_zero — TimeClip converts negative zero to positive zero
- built-ins/Date/prototype/setFullYear/15.9.5.40_1 — Date.prototype.setFullYear - Date.prototype is itself not an instance of Date

### Error
- built-ins/Error/S15.11.1.1_A1_T1 — Checking message property of different error objects
- built-ins/Error/S15.11.2.1_A1_T1 — Checking message property of different error objects
- built-ins/Error/prototype/S15.11.4_A2 — Getting the value of the internal [[Class]] property using Error.prototype.toString() function
- built-ins/Error/prototype/name/15.11.4.2-1 — Error.prototype.name is not enumerable.
- built-ins/Error/prototype/toString/15.11.4.4-8-1 — Error.prototype.toString return the value of 'msg' when 'name' is empty string and 'msg' isn't undefined

### Function
- built-ins/Function/prototype/S15.3.4_A5 — Checking if creating "new Function.prototype object" fails

### Infinity
- built-ins/Infinity/S15.1.1.2_A2_T2 — Checking typeof Functions

### Math
- built-ins/Math/pow/applying-the-exp-operator_A7 — If abs(base) is 1 and exponent is +∞, the result is NaN.
- built-ins/Math/pow/applying-the-exp-operator_A8 — If abs(base) is 1 and exponent is −∞, the result is NaN.

### NaN
- built-ins/NaN/S15.1.1.1_A2_T2 — Checking typeof Functions

### Number
- built-ins/Number/S9.3.1_A2 — Strings with various WhiteSpaces convert to Number by explicit transformation
- built-ins/Number/S9.3.1_A3_T1 — static string
- built-ins/Number/S9.3.1_A3_T2 — dynamic string

### Object
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A13 — Let O be the result of calling ToObject passing the this value as the argument.
- built-ins/Object/prototype/toString/15.2.4.2-1-1 — Object.prototype.toString - '[object Undefined]' will be returned when 'this' value is undefined
- built-ins/Object/prototype/toString/15.2.4.2-1-2 — Object.prototype.toString - '[object Undefined]' will be returned when 'this' value is undefined
- built-ins/Object/prototype/toString/15.2.4.2-2-1 — Object.prototype.toString - '[object Null]' will be returned when 'this' value is null
- built-ins/Object/prototype/toString/15.2.4.2-2-2 — Object.prototype.toString - '[object Null]' will be returned when 'this' value is null
- built-ins/Object/prototype/valueOf/S15.2.4.4_A12 — Checking Object.prototype.valueOf invoked by the 'call' property.
- built-ins/Object/prototype/valueOf/S15.2.4.4_A13 — Checking Object.prototype.valueOf invoked by the 'call' property.
- built-ins/Object/prototype/valueOf/S15.2.4.4_A14 — Checking Object.prototype.valueOf invoked by the 'call' property.
- built-ins/Object/prototype/valueOf/S15.2.4.4_A15 — Checking Object.prototype.valueOf when called as a global function.

### RegExp
- built-ins/RegExp/S15.10.2.12_A1_T1 — WhiteSpace
- built-ins/RegExp/S15.10.2.12_A2_T1 — WhiteSpace
- built-ins/RegExp/S15.10.2.8_A3_T15 — "see bug http:bugzilla.mozilla.org/show_bug.cgi?id=119909" — RangeError: Internal compiler limitations reached. Reduce code complexity.
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10 — String is 1.01 and RegExp is /1|12/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11 — String is new Number(1.012) and RegExp is /2|12/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12 — String is {toString:function(){return Math.PI;}} and RegExp is /\.14/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13 — String is true and RegExp is /t[a-b|q-s]/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14 — String is new Boolean and RegExp is /AL|se/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15 — "String is {toString:function(){return false;}} and RegExp is /LS/i"
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17 — String is null and RegExp is /ll|l/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18 — String is undefined and RegExp is /nd|ne/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19 — String is void 0 and RegExp is /e{1}/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2 — String is new String("123") and RegExp is /((1)|(12))((3)|(23))/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20 — String is x and RegExp is /[a-f]d/, where x is undefined variable
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21 — String is function(){}() and RegExp is /[a-z]n/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3 — String is new Object("abcdefghi") and RegExp is /a[a-z]{2,4}/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4 — String is {toString:function(){return "abcdefghi";}} and RegExp is /a[a-z]{2,4}?/
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5 — String is {toString:function(){return {};}, valueOf:function(){return "aabaac";}} and RegExp is /(aa|aabaac|ba|b|c)* /

### String
- String.prototype method length property deletion tests (16 cases) —
  Manual tests (`tests/conforming/functionLengthNotDeletable.io`) confirm NuXJS retains these non-configurable `length` properties; the earlier failure classification was incorrect
- built-ins/String/prototype/indexOf/S15.5.4.7_A1_T11 — Instance is Date(0) object
- built-ins/String/prototype/replace/S15.5.4.11_A12 — replaceValue tests that its this value is undefined
- built-ins/String/prototype/replace/S15.5.4.11_A1_T11 — Call replace (searchValue, replaceValue) function with objects arguments of string object. Objects have overrided toString function, that throw exception
- built-ins/String/prototype/replace/S15.5.4.11_A1_T12 — Call replace (searchValue, replaceValue) function with objects arguments of String object.  First objects have overrided toString and valueOf functions, valueOf throw exception.  Second objects have overrided toString function, that throw exception
- built-ins/String/prototype/replace/S15.5.4.11_A3_T1 — replaceValue is "$11" + 15
- built-ins/String/prototype/replace/S15.5.4.11_A3_T2 — replaceValue is "$11" + '15'
- built-ins/String/prototype/replace/S15.5.4.11_A3_T3 — replaceValue is "$11" + 'A15'
- built-ins/String/prototype/replace/S15.5.4.11_A5_T1 — searchValue is  regexp /^(a+)\1*,\1+$/ and replaceValue is "$1"
- built-ins/String/prototype/toLocaleLowerCase/special_casing_conditional — Check if String.prototype.toLocaleLowerCase supports conditional mappings defined in SpecialCasings
- built-ins/String/prototype/toLocaleLowerCase/supplementary_plane — String.prototype.toLocaleLowerCase() iterates over code points
- built-ins/String/prototype/toLocaleUpperCase/special_casing — Check if String.prototype.toLocaleUpperCase supports mappings defined in SpecialCasings
- built-ins/String/prototype/toLocaleUpperCase/supplementary_plane — String.prototype.toLocaleUpperCase() iterates over code points
- built-ins/String/prototype/toLowerCase/special_casing — Check if String.prototype.toLowerCase supports mappings defined in SpecialCasings
- built-ins/String/prototype/toLowerCase/special_casing_conditional — Check if String.prototype.toLowerCase supports conditional mappings defined in SpecialCasings
- built-ins/String/prototype/toLowerCase/supplementary_plane — String.prototype.toLowerCase() iterates over code points
- built-ins/String/prototype/toUpperCase/special_casing — Check if String.prototype.toUpperCase supports mappings defined in SpecialCasings
- built-ins/String/prototype/toUpperCase/supplementary_plane — String.prototype.toUpperCase() iterates over code points

### eval
- built-ins/eval/S15.1.2.1_A4.2 — Checking use hasOwnProperty, delete

### isFinite
- built-ins/isFinite/S15.1.2.5_A2.2 — Checking use hasOwnProperty, delete

### isNaN
- built-ins/isNaN/S15.1.2.4_A2.2 — Checking use hasOwnProperty, delete

### parseFloat
- built-ins/parseFloat/S15.1.2.3_A2_T10 — "StrWhiteSpaceChar :: USP"
- built-ins/parseFloat/S15.1.2.3_A7.2 — Checking use hasOwnProperty, delete

### parseInt
- built-ins/parseInt/S15.1.2.2_A2_T10 — "StrWhiteSpaceChar :: USP"
- built-ins/parseInt/S15.1.2.2_A5.2_T2 — ": 0X"
- built-ins/parseInt/S15.1.2.2_A7.2_T3 — Checking algorithm for R = 16
- built-ins/parseInt/S15.1.2.2_A9.2 — Checking use hasOwnProperty, delete

### undefined
- built-ins/undefined/15.1.1.3-1 — undefined is not writable, should not throw in non-strict mode
