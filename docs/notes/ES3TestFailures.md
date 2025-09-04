# ES3 Test262 Failures Analysis

This report enumerates the remaining 163 Test262 failures that exercise ECMAScript 3 features. Tests for later ECMAScript editions (e.g. Map/Set iterators) are excluded. 140 failing tests for the optional URI encoding helpers (`decodeURI`, `decodeURIComponent`, `encodeURI`, `encodeURIComponent`) are intentionally omitted and listed separately as by design. Each section lists failing tests and explains why their functionality is expected in an ES3-compliant engine.

### Automated classification

Run `python tools/es3_failure_analyzer.py` to group failures by feature area, flag obvious post-ES3 tests using ripgrep, update `tools/testdash.json`, and produce a progress table with ES3 spec clause references.

Current summary:

| Feature | Spec Clause | Total | non_es3 | Remaining |
| --- | --- | ---:| ---:| ---:|
| Array | §15.4 | 17 | 0 | 17 |
| Date | §15.9 | 7 | 0 | 7 |
| Error |  | 5 | 0 | 5 |
| Function |  | 1 | 0 | 1 |
| Infinity |  | 1 | 0 | 1 |
| Math | §15.8 | 2 | 0 | 2 |
| NaN |  | 1 | 0 | 1 |
| Number | §15.7 | 3 | 0 | 3 |
| Object | §15.2 | 16 | 0 | 16 |
| RegExp | §15.10 | 18 | 0 | 18 |
| String | §15.5 | 73 | 0 | 73 |
| eval |  | 2 | 0 | 2 |
| global |  | 3 | 0 | 3 |
| isFinite |  | 2 | 0 | 2 |
| isNaN |  | 2 | 0 | 2 |
| parseFloat |  | 3 | 0 | 3 |
| parseInt |  | 5 | 0 | 5 |
| undefined |  | 2 | 0 | 2 |
Progress: 163/163 tests reviewed.

### By design (optional URI helpers)

`decodeURI`, `decodeURIComponent`, `encodeURI`, and `encodeURIComponent` are optional in ES3 and intentionally unimplemented in NuXJS. Their 140 failing tests are excluded from the counts above:

- decodeURI – 48 tests
- decodeURIComponent – 48 tests
- encodeURI – 22 tests
- encodeURIComponent – 22 tests



## Array (17 tests)

Array construction and prototype methods like `concat`, `join`, `pop`, `push`, `reverse`, `shift`, `slice`, `sort`, `splice`, `toLocaleString`, `toString`, and `unshift` are part of ES3. Failures here indicate missing core array semantics.

- built-ins/Array/S15.4.3_A2.3 — `Array.length` remains writable even though ES3 §15.3.5.1 requires this property to be read-only.
- built-ins/Array/S15.4.5.1_A2.1_T1 — assigning to keys 4294967295, -1, or `true` should not grow the array (§15.4.5.1), yet NuXJS increments `length`.
- built-ins/Array/S15.4_A1.1_T1 — boolean property names must not be treated as array indices (§15.4); the engine treats `true`/`false` as numeric indexes.
- built-ins/Array/prototype/S15.4.3.1_A3 — `Array.prototype` should be non-configurable and non-deletable (§15.4.3.1), but NuXJS allows deletion.
- built-ins/Array/prototype/S15.4.3.1_A4 — `Array.prototype` is writable although ES3 (§15.4.3.1) mandates a read-only binding.
 - built-ins/Array/prototype/concat/S15.4.4.4_A4.3 — ES3 §15.4.4.4 requires `concat.length` read-only; NuXJS allows writing.
 - built-ins/Array/prototype/join/S15.4.4.5_A6.3 — ES3 §15.3.5.1 mandates `join.length` be read-only; NuXJS writes to it.
 - built-ins/Array/prototype/pop/S15.4.4.6_A2_T2 — when `length` is NaN, ±Infinity, or non-integer, ES3 §15.4.4.6 should coerce to 0; NuXJS leaves other values.
 - built-ins/Array/prototype/pop/S15.4.4.6_A4_T2 — fails to delete own index when prototype defines same property (§15.4.4.6).
 - built-ins/Array/prototype/push/S15.4.4.7_A2_T2 — with NaN/Infinity `length`, push should coerce via ToUint32 (§15.4.4.7); NuXJS misbehaves.
- built-ins/Array/prototype/shift/S15.4.4.9_A3_T3
- built-ins/Array/prototype/shift/S15.4.4.9_A4_T2
- built-ins/Array/prototype/sort/S15.4.4.11_A7.2
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A4.2
- built-ins/Array/prototype/toString/S15.4.4.2_A4.2
## Date (7 tests)

Covers the `Date` constructor, parsing, UTC calculations, and numerous getter/setter methods. Proper `Date` handling is essential to adhere to ES3 time semantics.

- built-ins/Date/S15.9.3.1_A6_T1
- built-ins/Date/S15.9.3.1_A6_T2
- built-ins/Date/S15.9.3.1_A6_T3
- built-ins/Date/S15.9.3.1_A6_T4
- built-ins/Date/S15.9.3.1_A6_T5
- built-ins/Date/TimeClip_negative_zero
- built-ins/Date/prototype/setFullYear/15.9.5.40_1

## eval (2 tests)

Validates global `eval` executes code in the current scope as specified by ES3.

- built-ins/eval/S15.1.2.1_A4.2
- built-ins/eval/S15.1.2.1_A4.3

## global (3 tests)

Ensures global object properties such as `undefined` are configured per ES3.

- built-ins/global/S10.2.3_A1.1_T2 — `NaN` should be non-enumerable on the global object, but NuXJS exposes it during enumeration.
- built-ins/global/S10.2.3_A1.2_T2 — `Infinity` is likewise enumerable even though ES3 marks it as `DontEnum`.
- built-ins/global/S10.2.3_A1.3_T2 — the global `undefined` property appears in `for...in` loops, contrary to ES3 attribute requirements.

## isFinite (2 tests)

Validates the global `isFinite` converts arguments and determines finiteness per ES3.

- built-ins/isFinite/S15.1.2.5_A2.2 — fails to apply `ToNumber` before testing, so string inputs yield wrong results.
- built-ins/isFinite/S15.1.2.5_A2.3 — returns `true` for `NaN` or infinities instead of `false`.

## isNaN (2 tests)

Validates the global `isNaN` function's ability to detect NaN values, a core numeric primitive in ES3.

- built-ins/isNaN/S15.1.2.4_A2.2 — argument coercion via `ToNumber` is skipped, misclassifying numeric strings.
- built-ins/isNaN/S15.1.2.4_A2.3 — some finite numbers incorrectly report `true`.

## parseFloat (3 tests)

Ensures `parseFloat` parses numeric strings according to ES3 grammar.

- built-ins/parseFloat/S15.1.2.3_A2_T10 — fails to skip form-feed (`\u000C`) before digits.
- built-ins/parseFloat/S15.1.2.3_A7.2 — does not recognize the `Infinity` literal.
- built-ins/parseFloat/S15.1.2.3_A7.3 — misparses signed `Infinity` values.

## parseInt (5 tests)

Ensures `parseInt` parses integers with proper radix handling per ES3.

- built-ins/parseInt/S15.1.2.2_A2_T10 — form-feed whitespace is not ignored.
- built-ins/parseInt/S15.1.2.2_A5.2_T2 — mishandles hexadecimal `0x` prefixes.
- built-ins/parseInt/S15.1.2.2_A7.2_T3 — signed hex strings are parsed incorrectly.
- built-ins/parseInt/S15.1.2.2_A9.2 — default radix handling for leading zeros is wrong.
- built-ins/parseInt/S15.1.2.2_A9.3 — leading-zero strings with non-octal digits return `NaN` instead of decimal values.

## undefined (2 tests)

Checks that `undefined` is read-only and globally defined.

- built-ins/undefined/15.1.1.3-1 — deleting `undefined` succeeds even though ES3 prohibits removal.
- built-ins/undefined/S15.1.1.3_A3_T1 — assignments alter `undefined`'s value.

## Function (1 test)

Exercises the `Function` constructor and prototype methods such as `call`, `apply`, and `toString`. ES3 specifies these behaviors.

- built-ins/Function/prototype/S15.3.4_A5
- 
## Error (5 tests)

General `Error` object behavior including construction and message properties must conform to ES3 specifications.

- built-ins/Error/S15.11.1.1_A1_T1
- built-ins/Error/S15.11.2.1_A1_T1
- built-ins/Error/prototype/S15.11.4_A2
- built-ins/Error/prototype/name/15.11.4.2-1
- built-ins/Error/prototype/toString/15.11.4.4-8-1
- 
## Infinity (1 test)

Confirms the `Infinity` property behaves as a read-only global representing positive infinity per ES3.

- built-ins/Infinity/S15.1.1.2_A2_T2
- 
## NaN (1 test)

These verify that the `NaN` property is non-writable, non-enumerable, non-configurable, and retains its special value.

- built-ins/NaN/S15.1.1.1_A2_T2
- 
## Math (2 tests)

Verifies correctness of `Math` constants and functions such as `sin`, `cos`, `pow`, and rounding behavior, all defined in ES3.

- built-ins/Math/pow/applying-the-exp-operator_A7
- built-ins/Math/pow/applying-the-exp-operator_A8
- 
## Number (3 tests)

Covers the `Number` constructor, its constants, and prototype methods that ES3 mandates.

- built-ins/Number/S9.3.1_A2
- built-ins/Number/S9.3.1_A3_T1
- built-ins/Number/S9.3.1_A3_T2
- 
## Object (16 tests)

Tests core `Object` constructor and prototype behaviors present in ES3.

- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A12
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A13
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A12
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A13
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A12
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A13
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A13
- built-ins/Object/prototype/toString/15.2.4.2-1-1
- built-ins/Object/prototype/toString/15.2.4.2-1-2
- built-ins/Object/prototype/toString/15.2.4.2-2-1
- built-ins/Object/prototype/toString/15.2.4.2-2-2
- built-ins/Object/prototype/valueOf/S15.2.4.4_A12
- built-ins/Object/prototype/valueOf/S15.2.4.4_A13
- built-ins/Object/prototype/valueOf/S15.2.4.4_A14
- built-ins/Object/prototype/valueOf/S15.2.4.4_A15

## RegExp (18 tests)

Covers regular expression syntax and `RegExp.prototype.exec`; ES3 defines the full regexp language.
- built-ins/RegExp/S15.10.2.12_A1_T1
- built-ins/RegExp/S15.10.2.12_A2_T1
- built-ins/RegExp/S15.10.2.8_A3_T15
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4
- built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5

## String (73 tests)

Validates the `String` constructor and prototype methods such as `charAt`, `indexOf`, and `slice` per ES3.

- built-ins/String/fromCharCode/name
- built-ins/String/prototype/S15.5.3.1_A3
- built-ins/String/prototype/S15.5.3.1_A4
- built-ins/String/prototype/charAt/S15.5.4.4_A10
- built-ins/String/prototype/charAt/S15.5.4.4_A9
- built-ins/String/prototype/charAt/name
- built-ins/String/prototype/charCodeAt/S15.5.4.5_A10
- built-ins/String/prototype/charCodeAt/S15.5.4.5_A9
- built-ins/String/prototype/charCodeAt/name
- built-ins/String/prototype/concat/S15.5.4.6_A10
- built-ins/String/prototype/concat/S15.5.4.6_A9
- built-ins/String/prototype/concat/name
- built-ins/String/prototype/indexOf/S15.5.4.7_A10
- built-ins/String/prototype/indexOf/S15.5.4.7_A1_T11
- built-ins/String/prototype/indexOf/S15.5.4.7_A9
- built-ins/String/prototype/indexOf/name
- built-ins/String/prototype/lastIndexOf/S15.5.4.8_A10
- built-ins/String/prototype/lastIndexOf/S15.5.4.8_A9
- built-ins/String/prototype/lastIndexOf/name
- built-ins/String/prototype/localeCompare/S15.5.4.9_A10
- built-ins/String/prototype/localeCompare/S15.5.4.9_A9
- built-ins/String/prototype/localeCompare/name
- built-ins/String/prototype/match/S15.5.4.10_A1_T3
- built-ins/String/prototype/match/S15.5.4.10_A9
- built-ins/String/prototype/match/length
- built-ins/String/prototype/match/name
- built-ins/String/prototype/replace/S15.5.4.11_A10
- built-ins/String/prototype/replace/S15.5.4.11_A12
- built-ins/String/prototype/replace/S15.5.4.11_A1_T11
- built-ins/String/prototype/replace/S15.5.4.11_A1_T12
- built-ins/String/prototype/replace/S15.5.4.11_A3_T1
- built-ins/String/prototype/replace/S15.5.4.11_A3_T2
- built-ins/String/prototype/replace/S15.5.4.11_A3_T3
- built-ins/String/prototype/replace/S15.5.4.11_A5_T1
- built-ins/String/prototype/replace/S15.5.4.11_A9
- built-ins/String/prototype/replace/name
- built-ins/String/prototype/search/S15.5.4.12_A10
- built-ins/String/prototype/search/S15.5.4.12_A9
- built-ins/String/prototype/search/name
- built-ins/String/prototype/slice/S15.5.4.13_A10
- built-ins/String/prototype/slice/S15.5.4.13_A9
- built-ins/String/prototype/slice/name
- built-ins/String/prototype/split/S15.5.4.14_A10
- built-ins/String/prototype/split/S15.5.4.14_A1_T3
- built-ins/String/prototype/split/S15.5.4.14_A9
- built-ins/String/prototype/split/name
- built-ins/String/prototype/substring/S15.5.4.15_A10
- built-ins/String/prototype/substring/S15.5.4.15_A9
- built-ins/String/prototype/substring/name
- built-ins/String/prototype/toLocaleLowerCase/S15.5.4.17_A10
- built-ins/String/prototype/toLocaleLowerCase/S15.5.4.17_A9
- built-ins/String/prototype/toLocaleLowerCase/name
- built-ins/String/prototype/toLocaleLowerCase/special_casing_conditional
- built-ins/String/prototype/toLocaleLowerCase/supplementary_plane
- built-ins/String/prototype/toLocaleUpperCase/S15.5.4.19_A10
- built-ins/String/prototype/toLocaleUpperCase/S15.5.4.19_A9
- built-ins/String/prototype/toLocaleUpperCase/name
- built-ins/String/prototype/toLocaleUpperCase/special_casing
- built-ins/String/prototype/toLocaleUpperCase/supplementary_plane
- built-ins/String/prototype/toLowerCase/S15.5.4.16_A10
- built-ins/String/prototype/toLowerCase/S15.5.4.16_A9
- built-ins/String/prototype/toLowerCase/name
- built-ins/String/prototype/toLowerCase/special_casing
- built-ins/String/prototype/toLowerCase/special_casing_conditional
- built-ins/String/prototype/toLowerCase/supplementary_plane
- built-ins/String/prototype/toString/name
- built-ins/String/prototype/toUpperCase/S15.5.4.18_A10
- built-ins/String/prototype/toUpperCase/S15.5.4.18_A9
- built-ins/String/prototype/toUpperCase/name
- built-ins/String/prototype/toUpperCase/special_casing
- built-ins/String/prototype/toUpperCase/supplementary_plane
- built-ins/String/prototype/valueOf/length
- built-ins/String/prototype/valueOf/name

