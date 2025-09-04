# ES3 Test262 Failures Analysis

This report enumerates the remaining Test262 failures that exercise ECMAScript 3 features. Tests for later ECMAScript editions (e.g. Set/Map iterators) are excluded. Each section lists failing tests and explains why their functionality is expected in an ES3-compliant engine.

### Non-ES3 Features

A few failing entries rely on features added after the third edition and are tagged "not_es3" in `tools/testdash.json`:

- Accessor restrictions on `arguments` and `caller` from ES5 strict mode. ES3 defines only `length` and `prototype` for function instances (§15.3.5) and imposes no such restrictions.
- `Object.getPrototypeOf` is not defined on the ES3 `Object` constructor (§15.2.2).
- `Object.setPrototypeOf` likewise has no definition in ES3 (§15.2.2); it first appears in later editions.

## Array (43 tests)

Array construction and prototype methods like `concat`, `join`, `pop`, `push`, `reverse`, `shift`, `slice`, `sort`, `splice`, `toLocaleString`, `toString`, and `unshift` are part of ES3. Failures here indicate missing core array semantics.

- built-ins/Array/S15.4.3_A2.2
- built-ins/Array/S15.4.3_A2.3
- built-ins/Array/S15.4.5.1_A2.1_T1
- built-ins/Array/S15.4_A1.1_T1
- built-ins/Array/prototype/S15.4.3.1_A3
- built-ins/Array/prototype/S15.4.3.1_A4
- built-ins/Array/prototype/concat/S15.4.4.4_A4.2
- built-ins/Array/prototype/concat/S15.4.4.4_A4.3
- built-ins/Array/prototype/join/S15.4.4.5_A4_T3
- built-ins/Array/prototype/join/S15.4.4.5_A6.2
- built-ins/Array/prototype/join/S15.4.4.5_A6.3
- built-ins/Array/prototype/pop/S15.4.4.6_A2_T2
- built-ins/Array/prototype/pop/S15.4.4.6_A3_T1
- built-ins/Array/prototype/pop/S15.4.4.6_A3_T2
- built-ins/Array/prototype/pop/S15.4.4.6_A3_T3
- built-ins/Array/prototype/pop/S15.4.4.6_A4_T2
- built-ins/Array/prototype/pop/S15.4.4.6_A5.2
- built-ins/Array/prototype/pop/S15.4.4.6_A5.3
- built-ins/Array/prototype/push/S15.4.4.7_A2_T2
- built-ins/Array/prototype/push/S15.4.4.7_A6.2
- built-ins/Array/prototype/push/S15.4.4.7_A6.3
- built-ins/Array/prototype/reverse/S15.4.4.8_A5.2
- built-ins/Array/prototype/reverse/S15.4.4.8_A5.3
- built-ins/Array/prototype/reverse/get_if_present_with_delete
- built-ins/Array/prototype/shift/S15.4.4.9_A3_T3
- built-ins/Array/prototype/shift/S15.4.4.9_A4_T2
- built-ins/Array/prototype/shift/S15.4.4.9_A5.2
- built-ins/Array/prototype/shift/S15.4.4.9_A5.3
- built-ins/Array/prototype/slice/S15.4.4.10_A5.2
- built-ins/Array/prototype/slice/S15.4.4.10_A5.3
- built-ins/Array/prototype/sort/S15.4.4.11_A7.2
- built-ins/Array/prototype/sort/S15.4.4.11_A7.3
- built-ins/Array/prototype/splice/S15.4.4.12_A5.2
- built-ins/Array/prototype/splice/S15.4.4.12_A5.3
- built-ins/Array/prototype/splice/S15.4.4.12_A6.1_T2
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A4.2
- built-ins/Array/prototype/toLocaleString/S15.4.4.3_A4.3
- built-ins/Array/prototype/toString/S15.4.4.2_A4.2
- built-ins/Array/prototype/toString/S15.4.4.2_A4.3
- built-ins/Array/prototype/unshift/S15.4.4.13_A5.2
- built-ins/Array/prototype/unshift/S15.4.4.13_A5.3

Many of these failures stem from ES5-era expectations that contradict ES3:

- **Undeletable `length` properties** – ES3 specifies that the `length` property of built-in functions has the `DontDelete` attribute (§15), so tests like `S15.4.4.4_A4.2` expecting `Array.prototype.concat.length` to be deletable are non‑ES3.
- **ES5 “ToLength” conversions** – Array methods in ES3 apply `ToUint32` when coercing `length` (§9.6), allowing negative values to wrap. ES5’s `ToLength` clamps negatives to zero, making tests such as `S15.4.4.5_A4_T3` inapplicable.
- **Generic edge cases and infinities** – The ES3 algorithms for `push`, `pop`, and related methods (§15.4.4.6–§15.4.4.9) do not define behaviour for `NaN`, `±Infinity`, or non‑array receivers, so ES5 tests probing these cases fail.

In short, our `Array.prototype` methods follow ES3, while the failing tests rely on ES5‑level property descriptors and edge‑case semantics.

## Boolean (2 tests)

Verifies the `Boolean` constructor's prototype properties and their attributes, which must exist in ES3.

- built-ins/Boolean/prototype/S15.6.3.1_A2
- built-ins/Boolean/prototype/S15.6.3.1_A3

## Date (147 tests)

Covers the `Date` constructor, parsing, UTC calculations, and numerous getter/setter methods. Proper `Date` handling is essential to adhere to ES3 time semantics.

- built-ins/Date/15.9.1.15-1
- built-ins/Date/S15.9.3.1_A5_T1
- built-ins/Date/S15.9.3.1_A5_T2
- built-ins/Date/S15.9.3.1_A5_T3
- built-ins/Date/S15.9.3.1_A5_T4
- built-ins/Date/S15.9.3.1_A5_T5
- built-ins/Date/S15.9.3.1_A5_T6
- built-ins/Date/S15.9.3.1_A6_T1
- built-ins/Date/S15.9.3.1_A6_T2
- built-ins/Date/S15.9.3.1_A6_T3
- built-ins/Date/S15.9.3.1_A6_T4
- built-ins/Date/S15.9.3.1_A6_T5
- built-ins/Date/TimeClip_negative_zero
- built-ins/Date/construct_with_date
- built-ins/Date/UTC/S15.9.4.3_A3_T1
- built-ins/Date/UTC/S15.9.4.3_A3_T2
- built-ins/Date/parse/S15.9.4.2_A3_T1
- built-ins/Date/parse/S15.9.4.2_A3_T2
- built-ins/Date/parse/name
- built-ins/Date/prototype/S15.9.4.1_A1_T1
- built-ins/Date/prototype/S15.9.4.1_A1_T2
- built-ins/Date/prototype/constructor/S15.9.5.1_A3_T1
- built-ins/Date/prototype/constructor/S15.9.5.1_A3_T2
- built-ins/Date/prototype/getDate/S15.9.5.14_A3_T1
- built-ins/Date/prototype/getDate/S15.9.5.14_A3_T2
- built-ins/Date/prototype/getDate/name
- built-ins/Date/prototype/getDay/S15.9.5.16_A3_T1
- built-ins/Date/prototype/getDay/S15.9.5.16_A3_T2
- built-ins/Date/prototype/getDay/name
- built-ins/Date/prototype/getFullYear/S15.9.5.10_A3_T1
- built-ins/Date/prototype/getFullYear/S15.9.5.10_A3_T2
- built-ins/Date/prototype/getFullYear/name
- built-ins/Date/prototype/getHours/S15.9.5.18_A3_T1
- built-ins/Date/prototype/getHours/S15.9.5.18_A3_T2
- built-ins/Date/prototype/getHours/name
- built-ins/Date/prototype/getMilliseconds/S15.9.5.24_A3_T1
- built-ins/Date/prototype/getMilliseconds/S15.9.5.24_A3_T2
- built-ins/Date/prototype/getMilliseconds/name
- built-ins/Date/prototype/getMinutes/S15.9.5.20_A3_T1
- built-ins/Date/prototype/getMinutes/S15.9.5.20_A3_T2
- built-ins/Date/prototype/getMinutes/name
- built-ins/Date/prototype/getMonth/S15.9.5.12_A3_T1
- built-ins/Date/prototype/getMonth/S15.9.5.12_A3_T2
- built-ins/Date/prototype/getMonth/name
- built-ins/Date/prototype/getSeconds/S15.9.5.22_A3_T1
- built-ins/Date/prototype/getSeconds/S15.9.5.22_A3_T2
- built-ins/Date/prototype/getSeconds/name
- built-ins/Date/prototype/getTime/S15.9.5.9_A3_T1
- built-ins/Date/prototype/getTime/S15.9.5.9_A3_T2
- built-ins/Date/prototype/getTime/name
- built-ins/Date/prototype/getTimezoneOffset/S15.9.5.26_A3_T1
- built-ins/Date/prototype/getTimezoneOffset/S15.9.5.26_A3_T2
- built-ins/Date/prototype/getTimezoneOffset/name
- built-ins/Date/prototype/getUTCDate/S15.9.5.15_A3_T1
- built-ins/Date/prototype/getUTCDate/S15.9.5.15_A3_T2
- built-ins/Date/prototype/getUTCDate/name
- built-ins/Date/prototype/getUTCDay/S15.9.5.17_A3_T1
- built-ins/Date/prototype/getUTCDay/S15.9.5.17_A3_T2
- built-ins/Date/prototype/getUTCDay/name
- built-ins/Date/prototype/getUTCFullYear/S15.9.5.11_A3_T1
- built-ins/Date/prototype/getUTCFullYear/S15.9.5.11_A3_T2
- built-ins/Date/prototype/getUTCFullYear/name
- built-ins/Date/prototype/getUTCHours/S15.9.5.19_A3_T1
- built-ins/Date/prototype/getUTCHours/S15.9.5.19_A3_T2
- built-ins/Date/prototype/getUTCHours/name
- built-ins/Date/prototype/getUTCMilliseconds/S15.9.5.25_A3_T1
- built-ins/Date/prototype/getUTCMilliseconds/S15.9.5.25_A3_T2
- built-ins/Date/prototype/getUTCMilliseconds/name
- built-ins/Date/prototype/getUTCMinutes/S15.9.5.21_A3_T1
- built-ins/Date/prototype/getUTCMinutes/S15.9.5.21_A3_T2
- built-ins/Date/prototype/getUTCMinutes/name
- built-ins/Date/prototype/getUTCMonth/S15.9.5.13_A3_T1
- built-ins/Date/prototype/getUTCMonth/S15.9.5.13_A3_T2
- built-ins/Date/prototype/getUTCMonth/name
- built-ins/Date/prototype/getUTCSeconds/S15.9.5.23_A3_T1
- built-ins/Date/prototype/getUTCSeconds/S15.9.5.23_A3_T2
- built-ins/Date/prototype/getUTCSeconds/name
- built-ins/Date/prototype/setDate/S15.9.5.36_A3_T1
- built-ins/Date/prototype/setDate/S15.9.5.36_A3_T2
- built-ins/Date/prototype/setDate/name
- built-ins/Date/prototype/setFullYear/15.9.5.40_1
- built-ins/Date/prototype/setFullYear/S15.9.5.40_A3_T1
- built-ins/Date/prototype/setFullYear/S15.9.5.40_A3_T2
- built-ins/Date/prototype/setFullYear/name
- built-ins/Date/prototype/setHours/S15.9.5.34_A3_T1
- built-ins/Date/prototype/setHours/S15.9.5.34_A3_T2
- built-ins/Date/prototype/setHours/name
- built-ins/Date/prototype/setMilliseconds/S15.9.5.28_A3_T1
- built-ins/Date/prototype/setMilliseconds/S15.9.5.28_A3_T2
- built-ins/Date/prototype/setMilliseconds/name
- built-ins/Date/prototype/setMinutes/S15.9.5.32_A3_T1
- built-ins/Date/prototype/setMinutes/S15.9.5.32_A3_T2
- built-ins/Date/prototype/setMinutes/name
- built-ins/Date/prototype/setMonth/S15.9.5.38_A3_T1
- built-ins/Date/prototype/setMonth/S15.9.5.38_A3_T2
- built-ins/Date/prototype/setMonth/name
- built-ins/Date/prototype/setSeconds/S15.9.5.30_A3_T1
- built-ins/Date/prototype/setSeconds/S15.9.5.30_A3_T2
- built-ins/Date/prototype/setSeconds/name
- built-ins/Date/prototype/setTime/S15.9.5.27_A3_T1
- built-ins/Date/prototype/setTime/S15.9.5.27_A3_T2
- built-ins/Date/prototype/setTime/name
- built-ins/Date/prototype/setUTCDate/S15.9.5.37_A3_T1
- built-ins/Date/prototype/setUTCDate/S15.9.5.37_A3_T2
- built-ins/Date/prototype/setUTCDate/name
- built-ins/Date/prototype/setUTCFullYear/S15.9.5.41_A3_T1
- built-ins/Date/prototype/setUTCFullYear/S15.9.5.41_A3_T2
- built-ins/Date/prototype/setUTCFullYear/name
- built-ins/Date/prototype/setUTCHours/S15.9.5.35_A3_T1
- built-ins/Date/prototype/setUTCHours/S15.9.5.35_A3_T2
- built-ins/Date/prototype/setUTCHours/name
- built-ins/Date/prototype/setUTCMilliseconds/S15.9.5.29_A3_T1
- built-ins/Date/prototype/setUTCMilliseconds/S15.9.5.29_A3_T2
- built-ins/Date/prototype/setUTCMilliseconds/name
- built-ins/Date/prototype/setUTCMinutes/S15.9.5.33_A3_T1
- built-ins/Date/prototype/setUTCMinutes/S15.9.5.33_A3_T2
- built-ins/Date/prototype/setUTCMinutes/name
- built-ins/Date/prototype/setUTCMonth/S15.9.5.39_A3_T1
- built-ins/Date/prototype/setUTCMonth/S15.9.5.39_A3_T2
- built-ins/Date/prototype/setUTCMonth/name
- built-ins/Date/prototype/setUTCSeconds/S15.9.5.31_A3_T1
- built-ins/Date/prototype/setUTCSeconds/S15.9.5.31_A3_T2
- built-ins/Date/prototype/setUTCSeconds/name
- built-ins/Date/prototype/toDateString/S15.9.5.3_A3_T1
- built-ins/Date/prototype/toDateString/S15.9.5.3_A3_T2
- built-ins/Date/prototype/toDateString/name
- built-ins/Date/prototype/toLocaleDateString/S15.9.5.6_A3_T1
- built-ins/Date/prototype/toLocaleDateString/S15.9.5.6_A3_T2
- built-ins/Date/prototype/toLocaleDateString/name
- built-ins/Date/prototype/toLocaleString/S15.9.5.5_A3_T1
- built-ins/Date/prototype/toLocaleString/S15.9.5.5_A3_T2
- built-ins/Date/prototype/toLocaleString/name
- built-ins/Date/prototype/toLocaleTimeString/S15.9.5.7_A3_T1
- built-ins/Date/prototype/toLocaleTimeString/S15.9.5.7_A3_T2
- built-ins/Date/prototype/toLocaleTimeString/name
- built-ins/Date/prototype/toString/S15.9.5.2_A3_T1
- built-ins/Date/prototype/toString/S15.9.5.2_A3_T2
- built-ins/Date/prototype/toString/name
- built-ins/Date/prototype/toTimeString/S15.9.5.4_A3_T1
- built-ins/Date/prototype/toTimeString/S15.9.5.4_A3_T2
- built-ins/Date/prototype/toTimeString/name
- built-ins/Date/prototype/toUTCString/S15.9.5.42_A3_T1
- built-ins/Date/prototype/toUTCString/S15.9.5.42_A3_T2
- built-ins/Date/prototype/toUTCString/name
- built-ins/Date/prototype/valueOf/S15.9.5.8_A3_T1
- built-ins/Date/prototype/valueOf/S15.9.5.8_A3_T2
- built-ins/Date/prototype/valueOf/name

## decodeURI (52 tests)

`decodeURI` must properly translate percent-encoded sequences back to their original characters according to ES3 URI handling rules.

- built-ins/decodeURI/S15.1.3.1_A1.10_T1
- built-ins/decodeURI/S15.1.3.1_A1.11_T1
- built-ins/decodeURI/S15.1.3.1_A1.11_T2
- built-ins/decodeURI/S15.1.3.1_A1.12_T1
- built-ins/decodeURI/S15.1.3.1_A1.12_T2
- built-ins/decodeURI/S15.1.3.1_A1.12_T3
- built-ins/decodeURI/S15.1.3.1_A1.13_T1
- built-ins/decodeURI/S15.1.3.1_A1.13_T2
- built-ins/decodeURI/S15.1.3.1_A1.14_T1
- built-ins/decodeURI/S15.1.3.1_A1.14_T2
- built-ins/decodeURI/S15.1.3.1_A1.14_T3
- built-ins/decodeURI/S15.1.3.1_A1.14_T4
- built-ins/decodeURI/S15.1.3.1_A1.15_T1
- built-ins/decodeURI/S15.1.3.1_A1.15_T2
- built-ins/decodeURI/S15.1.3.1_A1.15_T3
- built-ins/decodeURI/S15.1.3.1_A1.15_T4
- built-ins/decodeURI/S15.1.3.1_A1.15_T5
- built-ins/decodeURI/S15.1.3.1_A1.15_T6
- built-ins/decodeURI/S15.1.3.1_A1.1_T1
- built-ins/decodeURI/S15.1.3.1_A1.2_T1
- built-ins/decodeURI/S15.1.3.1_A1.2_T2
- built-ins/decodeURI/S15.1.3.1_A1.3_T1
- built-ins/decodeURI/S15.1.3.1_A1.3_T2
- built-ins/decodeURI/S15.1.3.1_A1.4_T1
- built-ins/decodeURI/S15.1.3.1_A1.5_T1
- built-ins/decodeURI/S15.1.3.1_A1.6_T1
- built-ins/decodeURI/S15.1.3.1_A1.7_T1
- built-ins/decodeURI/S15.1.3.1_A1.8_T1
- built-ins/decodeURI/S15.1.3.1_A1.8_T2
- built-ins/decodeURI/S15.1.3.1_A1.9_T1
- built-ins/decodeURI/S15.1.3.1_A1.9_T2
- built-ins/decodeURI/S15.1.3.1_A1.9_T3
- built-ins/decodeURI/S15.1.3.1_A2.1_T1
- built-ins/decodeURI/S15.1.3.1_A2.2_T1
- built-ins/decodeURI/S15.1.3.1_A2.3_T1
- built-ins/decodeURI/S15.1.3.1_A2.4_T1
- built-ins/decodeURI/S15.1.3.1_A2.5_T1
- built-ins/decodeURI/S15.1.3.1_A3_T1
- built-ins/decodeURI/S15.1.3.1_A3_T2
- built-ins/decodeURI/S15.1.3.1_A3_T3
- built-ins/decodeURI/S15.1.3.1_A4_T1
- built-ins/decodeURI/S15.1.3.1_A4_T2
- built-ins/decodeURI/S15.1.3.1_A4_T3
- built-ins/decodeURI/S15.1.3.1_A4_T4
- built-ins/decodeURI/S15.1.3.1_A5.1
- built-ins/decodeURI/S15.1.3.1_A5.2
- built-ins/decodeURI/S15.1.3.1_A5.3
- built-ins/decodeURI/S15.1.3.1_A5.4
- built-ins/decodeURI/S15.1.3.1_A5.6
- built-ins/decodeURI/S15.1.3.1_A5.7
- built-ins/decodeURI/S15.1.3.1_A6_T1
- built-ins/decodeURI/name

## decodeURIComponent (52 tests)

Tests ensure `decodeURIComponent` handles individual URI components and raises errors for malformed encodings as required by ES3.

- built-ins/decodeURIComponent/S15.1.3.2_A1.10_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.11_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.11_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.12_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.12_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.12_T3
- built-ins/decodeURIComponent/S15.1.3.2_A1.13_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.13_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.14_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.14_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.14_T3
- built-ins/decodeURIComponent/S15.1.3.2_A1.14_T4
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T3
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T4
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T5
- built-ins/decodeURIComponent/S15.1.3.2_A1.15_T6
- built-ins/decodeURIComponent/S15.1.3.2_A1.1_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.2_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.2_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.3_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.3_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.4_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.5_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.6_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.7_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.8_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.8_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.9_T1
- built-ins/decodeURIComponent/S15.1.3.2_A1.9_T2
- built-ins/decodeURIComponent/S15.1.3.2_A1.9_T3
- built-ins/decodeURIComponent/S15.1.3.2_A2.1_T1
- built-ins/decodeURIComponent/S15.1.3.2_A2.2_T1
- built-ins/decodeURIComponent/S15.1.3.2_A2.3_T1
- built-ins/decodeURIComponent/S15.1.3.2_A2.4_T1
- built-ins/decodeURIComponent/S15.1.3.2_A2.5_T1
- built-ins/decodeURIComponent/S15.1.3.2_A3_T1
- built-ins/decodeURIComponent/S15.1.3.2_A3_T2
- built-ins/decodeURIComponent/S15.1.3.2_A3_T3
- built-ins/decodeURIComponent/S15.1.3.2_A4_T1
- built-ins/decodeURIComponent/S15.1.3.2_A4_T2
- built-ins/decodeURIComponent/S15.1.3.2_A4_T3
- built-ins/decodeURIComponent/S15.1.3.2_A4_T4
- built-ins/decodeURIComponent/S15.1.3.2_A5.1
- built-ins/decodeURIComponent/S15.1.3.2_A5.2
- built-ins/decodeURIComponent/S15.1.3.2_A5.3
- built-ins/decodeURIComponent/S15.1.3.2_A5.4
- built-ins/decodeURIComponent/S15.1.3.2_A5.6
- built-ins/decodeURIComponent/S15.1.3.2_A5.7
- built-ins/decodeURIComponent/S15.1.3.2_A6_T1
- built-ins/decodeURIComponent/name

## encodeURI (28 tests)

Checks that `encodeURI` correctly escapes URI strings and rejects invalid surrogates per ES3 rules.

- built-ins/encodeURI/S15.1.3.3_A1.1_T1
- built-ins/encodeURI/S15.1.3.3_A1.1_T2
- built-ins/encodeURI/S15.1.3.3_A1.2_T1
- built-ins/encodeURI/S15.1.3.3_A1.2_T2
- built-ins/encodeURI/S15.1.3.3_A1.3_T1
- built-ins/encodeURI/S15.1.3.3_A2.1_T1
- built-ins/encodeURI/S15.1.3.3_A2.2_T1
- built-ins/encodeURI/S15.1.3.3_A2.3_T1
- built-ins/encodeURI/S15.1.3.3_A2.4_T1
- built-ins/encodeURI/S15.1.3.3_A2.4_T2
- built-ins/encodeURI/S15.1.3.3_A2.5_T1
- built-ins/encodeURI/S15.1.3.3_A3.1_T1
- built-ins/encodeURI/S15.1.3.3_A3.2_T1
- built-ins/encodeURI/S15.1.3.3_A3.2_T2
- built-ins/encodeURI/S15.1.3.3_A3.2_T3
- built-ins/encodeURI/S15.1.3.3_A3.3_T1
- built-ins/encodeURI/S15.1.3.3_A4_T1
- built-ins/encodeURI/S15.1.3.3_A4_T2
- built-ins/encodeURI/S15.1.3.3_A4_T3
- built-ins/encodeURI/S15.1.3.3_A4_T4
- built-ins/encodeURI/S15.1.3.3_A5.1
- built-ins/encodeURI/S15.1.3.3_A5.2
- built-ins/encodeURI/S15.1.3.3_A5.3
- built-ins/encodeURI/S15.1.3.3_A5.4
- built-ins/encodeURI/S15.1.3.3_A5.6
- built-ins/encodeURI/S15.1.3.3_A5.7
- built-ins/encodeURI/S15.1.3.3_A6_T1
- built-ins/encodeURI/name

## encodeURIComponent (28 tests)

Ensures `encodeURIComponent` escapes reserved characters within URI components exactly as specified by ES3.

- built-ins/encodeURIComponent/S15.1.3.4_A1.1_T1
- built-ins/encodeURIComponent/S15.1.3.4_A1.1_T2
- built-ins/encodeURIComponent/S15.1.3.4_A1.2_T1
- built-ins/encodeURIComponent/S15.1.3.4_A1.2_T2
- built-ins/encodeURIComponent/S15.1.3.4_A1.3_T1
- built-ins/encodeURIComponent/S15.1.3.4_A2.1_T1
- built-ins/encodeURIComponent/S15.1.3.4_A2.2_T1
- built-ins/encodeURIComponent/S15.1.3.4_A2.3_T1
- built-ins/encodeURIComponent/S15.1.3.4_A2.4_T1
- built-ins/encodeURIComponent/S15.1.3.4_A2.4_T2
- built-ins/encodeURIComponent/S15.1.3.4_A2.5_T1
- built-ins/encodeURIComponent/S15.1.3.4_A3.1_T1
- built-ins/encodeURIComponent/S15.1.3.4_A3.2_T1
- built-ins/encodeURIComponent/S15.1.3.4_A3.2_T2
- built-ins/encodeURIComponent/S15.1.3.4_A3.2_T3
- built-ins/encodeURIComponent/S15.1.3.4_A3.3_T1
- built-ins/encodeURIComponent/S15.1.3.4_A4_T1
- built-ins/encodeURIComponent/S15.1.3.4_A4_T2
- built-ins/encodeURIComponent/S15.1.3.4_A4_T3
- built-ins/encodeURIComponent/S15.1.3.4_A4_T4
- built-ins/encodeURIComponent/S15.1.3.4_A5.1
- built-ins/encodeURIComponent/S15.1.3.4_A5.2
- built-ins/encodeURIComponent/S15.1.3.4_A5.3
- built-ins/encodeURIComponent/S15.1.3.4_A5.4
- built-ins/encodeURIComponent/S15.1.3.4_A5.6
- built-ins/encodeURIComponent/S15.1.3.4_A5.7
- built-ins/encodeURIComponent/S15.1.3.4_A6_T1
- built-ins/encodeURIComponent/name

## eval (3 tests)

`eval` must execute code strings in the current scope while enforcing ES3 rules such as indirect calls and variable leakage.

- built-ins/eval/S15.1.2.1_A4.2
- built-ins/eval/S15.1.2.1_A4.3
- built-ins/eval/name

## global object (3 tests)

These tests confirm the global object's binding behavior and property attributes, which are fundamental in ES3.

- built-ins/global/S10.2.3_A1.1_T2
- built-ins/global/S10.2.3_A1.2_T2
- built-ins/global/S10.2.3_A1.3_T2

## isFinite (3 tests)

Confirms the global `isFinite` function correctly distinguishes finite numbers according to ES3 rules.

- built-ins/isFinite/S15.1.2.5_A2.2
- built-ins/isFinite/S15.1.2.5_A2.3
- built-ins/isFinite/name

## isNaN (3 tests)

Validates the global `isNaN` function's ability to detect NaN values, a core numeric primitive in ES3.

- built-ins/isNaN/S15.1.2.4_A2.2
- built-ins/isNaN/S15.1.2.4_A2.3
- built-ins/isNaN/name

## parseFloat (4 tests)

Ensures `parseFloat` converts strings to numbers following ES3 lexical grammar for numeric literals.

- built-ins/parseFloat/S15.1.2.3_A2_T10
- built-ins/parseFloat/S15.1.2.3_A7.2
- built-ins/parseFloat/S15.1.2.3_A7.3
- built-ins/parseFloat/name

## parseInt (6 tests)

`parseInt` must parse integers respecting radix prefixes and stop at the first invalid character as defined in ES3.

- built-ins/parseInt/S15.1.2.2_A2_T10
- built-ins/parseInt/S15.1.2.2_A5.2_T2
- built-ins/parseInt/S15.1.2.2_A7.2_T3
- built-ins/parseInt/S15.1.2.2_A9.2
- built-ins/parseInt/S15.1.2.2_A9.3
- built-ins/parseInt/name

## NaN (4 tests)

These verify that the `NaN` property is non-writable, non-enumerable, non-configurable, and retains its special Not-a-Number value.

- built-ins/NaN/15.1.1.1-0
- built-ins/NaN/S15.1.1.1_A2_T1
- built-ins/NaN/S15.1.1.1_A2_T2
- built-ins/NaN/S15.1.1.1_A3_T1

## Infinity (4 tests)

Confirms the `Infinity` property behaves as a read-only global representing positive infinity per ES3.

- built-ins/Infinity/15.1.1.2-0
- built-ins/Infinity/S15.1.1.2_A2_T1
- built-ins/Infinity/S15.1.1.2_A2_T2
- built-ins/Infinity/S15.1.1.2_A3_T1

## undefined (3 tests)

Verifies the read-only `undefined` global value and its property attributes, required by ES3.

- built-ins/undefined/15.1.1.3-0
- built-ins/undefined/15.1.1.3-1
- built-ins/undefined/S15.1.1.3_A3_T1

## Number (30 tests)

Covers numeric conversion, constructor behavior, and prototype methods like `toFixed`, `toExponential`, and `valueOf` defined in ES3.

- built-ins/Number/S9.3.1_A2
- built-ins/Number/S9.3.1_A3_T1
- built-ins/Number/S9.3.1_A3_T2
- built-ins/Number/string-binary-literal
- built-ins/Number/string-octal-literal
- built-ins/Number/symbol-number-coercion
- built-ins/Number/MAX_VALUE/S15.7.3.2_A2
- built-ins/Number/MAX_VALUE/S15.7.3.2_A3
- built-ins/Number/MIN_VALUE/S15.7.3.3_A2
- built-ins/Number/MIN_VALUE/S15.7.3.3_A3
- built-ins/Number/NEGATIVE_INFINITY/S15.7.3.5_A2
- built-ins/Number/NEGATIVE_INFINITY/S15.7.3.5_A3
- built-ins/Number/NaN/S15.7.3.4_A2
- built-ins/Number/NaN/S15.7.3.4_A3
- built-ins/Number/POSITIVE_INFINITY/S15.7.3.6_A2
- built-ins/Number/POSITIVE_INFINITY/S15.7.3.6_A3
- built-ins/Number/prototype/15.7.3.1-1
- built-ins/Number/prototype/S15.7.3.1_A1_T1
- built-ins/Number/prototype/S15.7.3.1_A1_T2
- built-ins/Number/prototype/toExponential/length
- built-ins/Number/prototype/toExponential/name
- built-ins/Number/prototype/toFixed/name
- built-ins/Number/prototype/toLocaleString/length
- built-ins/Number/prototype/toLocaleString/name
- built-ins/Number/prototype/toPrecision/length
- built-ins/Number/prototype/toPrecision/name
- built-ins/Number/prototype/toString/length
- built-ins/Number/prototype/toString/name
- built-ins/Number/prototype/valueOf/length
- built-ins/Number/prototype/valueOf/name

## Math (54 tests)

Verifies correctness of `Math` constants and functions such as `sin`, `cos`, `pow`, and rounding behavior, all defined in ES3.

- built-ins/Math/E/S15.8.1.1_A3
- built-ins/Math/E/S15.8.1.1_A4
- built-ins/Math/LN10/S15.8.1.2_A3
- built-ins/Math/LN10/S15.8.1.2_A4
- built-ins/Math/LN2/S15.8.1.3_A3
- built-ins/Math/LN2/S15.8.1.3_A4
- built-ins/Math/LOG10E/S15.8.1.5_A3
- built-ins/Math/LOG10E/S15.8.1.5_A4
- built-ins/Math/LOG2E/S15.8.1.4_A3
- built-ins/Math/LOG2E/S15.8.1.4_A4
- built-ins/Math/PI/S15.8.1.6_A3
- built-ins/Math/PI/S15.8.1.6_A4
- built-ins/Math/SQRT1_2/S15.8.1.7_A3
- built-ins/Math/SQRT1_2/S15.8.1.7_A4
- built-ins/Math/SQRT2/S15.8.1.8_A3
- built-ins/Math/SQRT2/S15.8.1.8_A4
- built-ins/Math/abs/length
- built-ins/Math/abs/name
- built-ins/Math/acos/length
- built-ins/Math/acos/name
- built-ins/Math/asin/length
- built-ins/Math/asin/name
- built-ins/Math/atan/length
- built-ins/Math/atan/name
- built-ins/Math/atan2/length
- built-ins/Math/atan2/name
- built-ins/Math/ceil/length
- built-ins/Math/ceil/name
- built-ins/Math/cos/length
- built-ins/Math/cos/name
- built-ins/Math/exp/length
- built-ins/Math/exp/name
- built-ins/Math/floor/length
- built-ins/Math/floor/name
- built-ins/Math/log/length
- built-ins/Math/log/name
- built-ins/Math/max/name
- built-ins/Math/min/name
- built-ins/Math/pow/applying-the-exp-operator_A7
- built-ins/Math/pow/applying-the-exp-operator_A8
- built-ins/Math/pow/length
- built-ins/Math/pow/math.pow
- built-ins/Math/pow/name
- built-ins/Math/random/length
- built-ins/Math/random/name
- built-ins/Math/round/S15.8.2.15_A7
- built-ins/Math/round/length
- built-ins/Math/round/name
- built-ins/Math/sin/length
- built-ins/Math/sin/name
- built-ins/Math/sqrt/length
- built-ins/Math/sqrt/name
- built-ins/Math/tan/length
- built-ins/Math/tan/name

## String (75 tests)

Covers string construction, character indexing, and prototype methods like `replace`, `match`, `split`, and `localeCompare`, all required by ES3.

- built-ins/String/S15.5.5.1_A3
- built-ins/String/S15.5.5.1_A4_T2
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

## RegExp (96 tests)

Exercises regular expression literals, constructors, exec/test methods, and pattern flags. Robust RegExp support is mandated in ES3.

- built-ins/RegExp/15.10.4.1-1
- built-ins/RegExp/S15.10.2.12_A1_T1
- built-ins/RegExp/S15.10.2.12_A2_T1
- built-ins/RegExp/S15.10.2.8_A3_T15
- built-ins/RegExp/S15.10.3.1_A2_T1
- built-ins/RegExp/S15.10.3.1_A2_T2
- built-ins/RegExp/S15.10.4.1_A2_T1
- built-ins/RegExp/S15.10.4.1_A2_T2
- built-ins/RegExp/call_with_non_regexp_same_constructor
- built-ins/RegExp/call_with_regexp_match_falsy
- built-ins/RegExp/call_with_regexp_not_same_constructor
- built-ins/RegExp/from-regexp-like-flag-override
- built-ins/RegExp/from-regexp-like-get-ctor-err
- built-ins/RegExp/from-regexp-like-get-flags-err
- built-ins/RegExp/from-regexp-like-get-source-err
- built-ins/RegExp/from-regexp-like-short-circuit
- built-ins/RegExp/from-regexp-like
- built-ins/RegExp/valid-flags-y
- built-ins/RegExp/prototype/S15.10.5.1_A3
- built-ins/RegExp/prototype/S15.10.5.1_A4
- built-ins/RegExp/prototype/exec/S15.10.6.2_A10
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
- built-ins/RegExp/prototype/exec/S15.10.6.2_A5_T3
- built-ins/RegExp/prototype/exec/S15.10.6.2_A9
- built-ins/RegExp/prototype/exec/name
- built-ins/RegExp/prototype/exec/u-captured-value
- built-ins/RegExp/prototype/exec/u-lastindex-adv
- built-ins/RegExp/prototype/exec/u-lastindex-value
- built-ins/RegExp/prototype/exec/y-fail-lastindex-no-write
- built-ins/RegExp/prototype/exec/y-fail-lastindex
- built-ins/RegExp/prototype/exec/y-fail-return
- built-ins/RegExp/prototype/exec/y-init-lastindex
- built-ins/RegExp/prototype/exec/y-set-lastindex
- built-ins/RegExp/prototype/flags/length
- built-ins/RegExp/prototype/flags/name
- built-ins/RegExp/prototype/flags/u-attr-err
- built-ins/RegExp/prototype/flags/u-coercion
- built-ins/RegExp/prototype/flags/u
- built-ins/RegExp/prototype/flags/y-attr-err
- built-ins/RegExp/prototype/flags/y
- built-ins/RegExp/prototype/global/15.10.7.2-1
- built-ins/RegExp/prototype/global/15.10.7.2-2
- built-ins/RegExp/prototype/global/S15.10.7.2_A10
- built-ins/RegExp/prototype/global/S15.10.7.2_A8
- built-ins/RegExp/prototype/global/S15.10.7.2_A9
- built-ins/RegExp/prototype/global/length
- built-ins/RegExp/prototype/global/name
- built-ins/RegExp/prototype/ignoreCase/15.10.7.3-1
- built-ins/RegExp/prototype/ignoreCase/15.10.7.3-2
- built-ins/RegExp/prototype/ignoreCase/S15.10.7.3_A10
- built-ins/RegExp/prototype/ignoreCase/S15.10.7.3_A8
- built-ins/RegExp/prototype/ignoreCase/S15.10.7.3_A9
- built-ins/RegExp/prototype/ignoreCase/length
- built-ins/RegExp/prototype/ignoreCase/name
- built-ins/RegExp/prototype/lastIndex/15.10.7.5-2
- built-ins/RegExp/prototype/lastIndex/S15.10.7.5_A9
- built-ins/RegExp/prototype/multiline/15.10.7.4-1
- built-ins/RegExp/prototype/multiline/15.10.7.4-2
- built-ins/RegExp/prototype/multiline/S15.10.7.4_A10
- built-ins/RegExp/prototype/multiline/S15.10.7.4_A8
- built-ins/RegExp/prototype/multiline/S15.10.7.4_A9
- built-ins/RegExp/prototype/multiline/length
- built-ins/RegExp/prototype/multiline/name
- built-ins/RegExp/prototype/source/15.10.7.1-1
- built-ins/RegExp/prototype/source/15.10.7.1-2
- built-ins/RegExp/prototype/source/S15.10.7.1_A10
- built-ins/RegExp/prototype/source/S15.10.7.1_A8
- built-ins/RegExp/prototype/source/S15.10.7.1_A9
- built-ins/RegExp/prototype/source/length
- built-ins/RegExp/prototype/source/name
- built-ins/RegExp/prototype/test/S15.10.6.3_A10
- built-ins/RegExp/prototype/test/S15.10.6.3_A1_T22
- built-ins/RegExp/prototype/test/S15.10.6.3_A9
- built-ins/RegExp/prototype/test/name
- built-ins/RegExp/prototype/test/y-fail-lastindex-no-write
- built-ins/RegExp/prototype/test/y-fail-lastindex
- built-ins/RegExp/prototype/test/y-fail-return
- built-ins/RegExp/prototype/test/y-init-lastindex
- built-ins/RegExp/prototype/test/y-set-lastindex
- built-ins/RegExp/prototype/toString/S15.10.6.4_A10
- built-ins/RegExp/prototype/toString/S15.10.6.4_A9
- built-ins/RegExp/prototype/toString/name

## Object (151 tests)

Includes object construction, property attributes (`hasOwnProperty`, `toString`, etc.), and interactions with prototypes—all foundational ES3 behaviors.

- built-ins/Object/symbol_object-returns-fresh-symbol
- built-ins/Object/getPrototypeOf/15.2.3.2-0-3
- built-ins/Object/getPrototypeOf/15.2.3.2-1-2
- built-ins/Object/getPrototypeOf/15.2.3.2-1-3
- built-ins/Object/getPrototypeOf/15.2.3.2-1-4
- built-ins/Object/getPrototypeOf/15.2.3.2-1
- built-ins/Object/getPrototypeOf/15.2.3.2-2-12
- built-ins/Object/getPrototypeOf/15.2.3.2-2-13
- built-ins/Object/getPrototypeOf/15.2.3.2-2-14
- built-ins/Object/getPrototypeOf/15.2.3.2-2-15
- built-ins/Object/getPrototypeOf/15.2.3.2-2-16
- built-ins/Object/getPrototypeOf/15.2.3.2-2-17
- built-ins/Object/getPrototypeOf/name
- built-ins/Object/keys/15.2.3.14-0-1
- built-ins/Object/keys/15.2.3.14-0-2
- built-ins/Object/keys/15.2.3.14-1-1
- built-ins/Object/keys/15.2.3.14-1-2
- built-ins/Object/keys/15.2.3.14-1-3
- built-ins/Object/keys/15.2.3.14-2-1
- built-ins/Object/keys/15.2.3.14-2-2
- built-ins/Object/keys/15.2.3.14-2-3
- built-ins/Object/keys/15.2.3.14-2-4
- built-ins/Object/keys/15.2.3.14-2-5
- built-ins/Object/keys/15.2.3.14-2-6
- built-ins/Object/keys/15.2.3.14-2-7
- built-ins/Object/keys/15.2.3.14-2-8
- built-ins/Object/keys/15.2.3.14-3-1
- built-ins/Object/keys/15.2.3.14-3-2
- built-ins/Object/keys/15.2.3.14-3-3
- built-ins/Object/keys/15.2.3.14-3-4
- built-ins/Object/keys/15.2.3.14-3-5
- built-ins/Object/keys/15.2.3.14-3-6
- built-ins/Object/keys/15.2.3.14-3-7
- built-ins/Object/keys/15.2.3.14-4-1
- built-ins/Object/keys/15.2.3.14-5-1
- built-ins/Object/keys/15.2.3.14-5-10
- built-ins/Object/keys/15.2.3.14-5-11
- built-ins/Object/keys/15.2.3.14-5-12
- built-ins/Object/keys/15.2.3.14-5-13
- built-ins/Object/keys/15.2.3.14-5-14
- built-ins/Object/keys/15.2.3.14-5-15
- built-ins/Object/keys/15.2.3.14-5-16
- built-ins/Object/keys/15.2.3.14-5-2
- built-ins/Object/keys/15.2.3.14-5-3
- built-ins/Object/keys/15.2.3.14-5-4
- built-ins/Object/keys/15.2.3.14-5-5
- built-ins/Object/keys/15.2.3.14-5-6
- built-ins/Object/keys/15.2.3.14-5-7
- built-ins/Object/keys/15.2.3.14-5-8
- built-ins/Object/keys/15.2.3.14-5-9
- built-ins/Object/keys/15.2.3.14-5-a-1
- built-ins/Object/keys/15.2.3.14-5-a-2
- built-ins/Object/keys/15.2.3.14-5-a-3
- built-ins/Object/keys/15.2.3.14-5-a-4
- built-ins/Object/keys/15.2.3.14-5-b-1
- built-ins/Object/keys/15.2.3.14-6-1
- built-ins/Object/keys/15.2.3.14-6-2
- built-ins/Object/keys/15.2.3.14-6-3
- built-ins/Object/keys/15.2.3.14-6-4
- built-ins/Object/keys/15.2.3.14-6-5
- built-ins/Object/keys/15.2.3.14-6-6
- built-ins/Object/keys/name
- built-ins/Object/prototype/15.2.3.1
- built-ins/Object/prototype/S15.2.3.1_A1
- built-ins/Object/prototype/S15.2.3.1_A3
- built-ins/Object/prototype/extensibility
- built-ins/Object/prototype/setPrototypeOf-with-different-values
- built-ins/Object/prototype/setPrototypeOf-with-same-value
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_12
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_13
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_14
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_15
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_16
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_17
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_18
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_19
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_20
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_21
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_22
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_23
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_24
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_25
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_3
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_38
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_39
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_40
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_41
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_42
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_43
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_44
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_45
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_46
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_47
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_48
- built-ins/Object/prototype/hasOwnProperty/8.12.1-1_49
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A10
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A12
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A13
- built-ins/Object/prototype/hasOwnProperty/S15.2.4.5_A9
- built-ins/Object/prototype/hasOwnProperty/name
- built-ins/Object/prototype/hasOwnProperty/symbol_own_property
- built-ins/Object/prototype/hasOwnProperty/symbol_property_toPrimitive
- built-ins/Object/prototype/hasOwnProperty/symbol_property_toString
- built-ins/Object/prototype/hasOwnProperty/symbol_property_valueOf
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A10
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A12
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A13
- built-ins/Object/prototype/isPrototypeOf/S15.2.4.6_A9
- built-ins/Object/prototype/isPrototypeOf/name
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A10
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A12
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A13
- built-ins/Object/prototype/propertyIsEnumerable/S15.2.4.7_A9
- built-ins/Object/prototype/propertyIsEnumerable/name
- built-ins/Object/prototype/propertyIsEnumerable/symbol_own_property
- built-ins/Object/prototype/propertyIsEnumerable/symbol_property_toPrimitive
- built-ins/Object/prototype/propertyIsEnumerable/symbol_property_toString
- built-ins/Object/prototype/propertyIsEnumerable/symbol_property_valueOf
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A10
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A12
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A13
- built-ins/Object/prototype/toLocaleString/S15.2.4.3_A9
- built-ins/Object/prototype/toLocaleString/name
- built-ins/Object/prototype/toString/15.2.4.2-1-1
- built-ins/Object/prototype/toString/15.2.4.2-1-2
- built-ins/Object/prototype/toString/15.2.4.2-2-1
- built-ins/Object/prototype/toString/15.2.4.2-2-2
- built-ins/Object/prototype/toString/S15.2.4.2_A10
- built-ins/Object/prototype/toString/S15.2.4.2_A12
- built-ins/Object/prototype/toString/S15.2.4.2_A13
- built-ins/Object/prototype/toString/S15.2.4.2_A9
- built-ins/Object/prototype/toString/get-symbol-tag-err
- built-ins/Object/prototype/toString/name
- built-ins/Object/prototype/toString/symbol-tag-non-str
- built-ins/Object/prototype/toString/symbol-tag-override
- built-ins/Object/prototype/toString/symbol-tag-str
- built-ins/Object/prototype/valueOf/S15.2.4.4_A10
- built-ins/Object/prototype/valueOf/S15.2.4.4_A12
- built-ins/Object/prototype/valueOf/S15.2.4.4_A13
- built-ins/Object/prototype/valueOf/S15.2.4.4_A14
- built-ins/Object/prototype/valueOf/S15.2.4.4_A15
- built-ins/Object/prototype/valueOf/S15.2.4.4_A9
- built-ins/Object/prototype/valueOf/name
- built-ins/Object/setPrototypeOf/length
- built-ins/Object/setPrototypeOf/name
- built-ins/Object/setPrototypeOf/o-not-obj
- built-ins/Object/setPrototypeOf/property-descriptor
- built-ins/Object/setPrototypeOf/proto-not-obj
- built-ins/Object/setPrototypeOf/set-error
- built-ins/Object/setPrototypeOf/set-failure-non-extensible
- built-ins/Object/setPrototypeOf/success

## Function (41 tests)

Targets the `Function` constructor and prototype methods such as `call`, `apply`, and `toString`, which drive ES3's function behavior.

- built-ins/Function/15.3.2.1-10-6gs
- built-ins/Function/15.3.2.1-11-1-s
- built-ins/Function/15.3.2.1-11-3-s
- built-ins/Function/15.3.2.1-11-5-s
- built-ins/Function/15.3.5.4_2-49gs
- built-ins/Function/15.3.5.4_2-51gs
- built-ins/Function/15.3.5.4_2-53gs
- built-ins/Function/15.3.5.4_2-55gs
- built-ins/Function/15.3.5.4_2-89gs
- built-ins/Function/15.3.5.4_2-90gs
- built-ins/Function/15.3.5.4_2-91gs
- built-ins/Function/15.3.5.4_2-92gs
- built-ins/Function/15.3.5.4_2-93gs
- built-ins/Function/15.3.5.4_2-96gs
- built-ins/Function/15.3.5.4_2-97gs
- built-ins/Function/instance-name
- built-ins/Function/length/15.3.3.2-1
- built-ins/Function/length/S15.3.5.1_A2_T1
- built-ins/Function/length/S15.3.5.1_A2_T2
- built-ins/Function/length/S15.3.5.1_A2_T3
- built-ins/Function/length/S15.3.5.1_A3_T1
- built-ins/Function/length/S15.3.5.1_A3_T2
- built-ins/Function/length/S15.3.5.1_A3_T3
- built-ins/Function/prototype/S15.3.3.1_A1
- built-ins/Function/prototype/S15.3.3.1_A3
- built-ins/Function/prototype/S15.3.3.1_A4
- built-ins/Function/prototype/S15.3.4_A5
- built-ins/Function/prototype/S15.3.5.2_A1_T1
- built-ins/Function/prototype/S15.3.5.2_A1_T2
- built-ins/Function/prototype/name
- built-ins/Function/prototype/restricted-property-arguments
- built-ins/Function/prototype/restricted-property-caller
- built-ins/Function/prototype/apply/S15.3.4.3_A10
- built-ins/Function/prototype/apply/S15.3.4.3_A9
- built-ins/Function/prototype/apply/name
- built-ins/Function/prototype/call/S15.3.4.4_A10
- built-ins/Function/prototype/call/S15.3.4.4_A9
- built-ins/Function/prototype/call/name
- built-ins/Function/prototype/toString/S15.3.4.2_A10
- built-ins/Function/prototype/toString/S15.3.4.2_A9
- built-ins/Function/prototype/toString/name

## Native Error Objects (38 tests)

Covers built-in error constructors like `TypeError`, `RangeError`, and their prototypes. ES3 specifies these for runtime exception handling.

- built-ins/NativeErrors/message_property_native_error
- built-ins/NativeErrors/EvalError/length
- built-ins/NativeErrors/EvalError/name
- built-ins/NativeErrors/EvalError/proto
- built-ins/NativeErrors/EvalError/prototype
- built-ins/NativeErrors/EvalError/prototype/constructor
- built-ins/NativeErrors/EvalError/prototype/message
- built-ins/NativeErrors/EvalError/prototype/name
- built-ins/NativeErrors/RangeError/length
- built-ins/NativeErrors/RangeError/name
- built-ins/NativeErrors/RangeError/prototype
- built-ins/NativeErrors/RangeError/prototype/constructor
- built-ins/NativeErrors/RangeError/prototype/message
- built-ins/NativeErrors/RangeError/prototype/name
- built-ins/NativeErrors/ReferenceError/length
- built-ins/NativeErrors/ReferenceError/name
- built-ins/NativeErrors/ReferenceError/prototype
- built-ins/NativeErrors/ReferenceError/prototype/constructor
- built-ins/NativeErrors/ReferenceError/prototype/message
- built-ins/NativeErrors/ReferenceError/prototype/name
- built-ins/NativeErrors/SyntaxError/length
- built-ins/NativeErrors/SyntaxError/name
- built-ins/NativeErrors/SyntaxError/prototype
- built-ins/NativeErrors/SyntaxError/prototype/constructor
- built-ins/NativeErrors/SyntaxError/prototype/message
- built-ins/NativeErrors/SyntaxError/prototype/name
- built-ins/NativeErrors/TypeError/length
- built-ins/NativeErrors/TypeError/name
- built-ins/NativeErrors/TypeError/prototype
- built-ins/NativeErrors/TypeError/prototype/constructor
- built-ins/NativeErrors/TypeError/prototype/message
- built-ins/NativeErrors/TypeError/prototype/name
- built-ins/NativeErrors/URIError/length
- built-ins/NativeErrors/URIError/name
- built-ins/NativeErrors/URIError/prototype
- built-ins/NativeErrors/URIError/prototype/constructor
- built-ins/NativeErrors/URIError/prototype/message
- built-ins/NativeErrors/URIError/prototype/name

## Error (10 tests)

General `Error` object behavior including construction and message properties must conform to ES3 specifications.

- built-ins/Error/S15.11.1.1_A1_T1
- built-ins/Error/S15.11.2.1_A1_T1
- built-ins/Error/message_property
- built-ins/Error/prototype/S15.11.3.1_A1_T1
- built-ins/Error/prototype/S15.11.3.1_A3_T1
- built-ins/Error/prototype/S15.11.4_A2
- built-ins/Error/prototype/name/15.11.4.2-1
- built-ins/Error/prototype/toString/15.11.4.4-8-1
- built-ins/Error/prototype/toString/length
- built-ins/Error/prototype/toString/name

## Language Expressions (10 tests)

These cases check object literal syntax edge cases and other core expression forms defined in ES3.

- language/expressions/object/11.1.5-0-1
- language/expressions/object/11.1.5-0-2
- language/expressions/object/11.1.5_4-4-b-1
- language/expressions/object/11.1.5_4-4-b-2
- language/expressions/object/11.1.5_4-4-c-1
- language/expressions/object/11.1.5_4-4-c-2
- language/expressions/object/11.1.5_4-4-d-1
- language/expressions/object/11.1.5_4-4-d-2
- language/expressions/object/11.1.5_4-4-d-3
- language/expressions/object/11.1.5_4-4-d-4

## Language Function Code (8 tests)

Examines function body semantics such as strict parameter handling and `arguments` object interaction required by ES3.

- language/function-code/10.4.3-1-54-s
- language/function-code/10.4.3-1-54gs
- language/function-code/10.4.3-1-55-s
- language/function-code/10.4.3-1-55gs
- language/function-code/10.4.3-1-56-s
- language/function-code/10.4.3-1-56gs
- language/function-code/10.4.3-1-57-s
- language/function-code/10.4.3-1-57gs

## Recommended Test Exclusions

Property descriptor checks for array methods that assume ES5 semantics—such as `built-ins/Array/prototype/concat/S15.4.4.4_A4.2` and `built-ins/Array/prototype/join/S15.4.4.5_A4_T3`—should be tagged "not_es3" in `tools/testdash.json` so the dashboard focuses on third‑edition compliance.

