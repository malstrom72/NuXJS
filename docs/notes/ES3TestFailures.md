# ES3 Test262 Failures Analysis

_Updated after re-running the targeted `fails` bucket on September 17, 2025._

The `fails` manifest now lists five ES3 Test262 cases across the Object, RegExp, and String built-ins.【F:fails†L1-L47】

| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Object | §15.2, §15.4.5.1 | 2 |
| RegExp | §15.10 | 1 |
| String | §15.5.4.11 | 2 |

Each subsection quotes the relevant ECMA-262 3rd edition requirements and summarises the current NuXJS behaviour. Every fix should ship with a focused regression `.io` test alongside the code change.

### Recently Resolved

1. **`built-ins/Array/prototype/push/S15.4.4.7_A3`** and **`…_A4_T2`**  
   `Array.prototype.push` now appends elements before revalidating `length`, allowing the setter to raise the mandated `RangeError` while leaving inserted data visible and permitting borrowed calls on plain objects to extend past `2^32−1`. Focused regressions capture both the array overflow and the generic-object growth scenarios.【F:src/stdlib.js†L655-L668】【F:tests/regression/arrayPushLengthRangeError.io†L1-L8】【F:tests/regression/arrayPushBorrowedLengthOverflow.io†L1-L8】

2. **`built-ins/Function/prototype/S15.3.4_A5`**
   `Runtime::FunctionPrototypeFunction::construct` now raises a `TypeError`, preventing `new Function.prototype()` from creating objects and matching ES3's prohibition on a `[[Construct]]` hook. A regression script asserts the thrown error and message.【F:src/NuXJS.cpp†L4607-L4624】【F:tests/regression/functionPrototypeNotConstructable.io†L1-L9】

3. **`built-ins/String/prototype/replace/S15.5.4.11_A1_T11`** and **`…_A1_T12`**
   `String.prototype.replace` now coerces the search operand before stringifying `replaceValue`, so user-defined `toString` hooks fire in the ES3-mandated order and propagate search exceptions ahead of replacement coercion. A regression transcript records the evaluation order and verifies the thrown error message.【F:src/stdlib.js†L486-L541】【F:tests/regression/stringReplaceSearchToStringOrder.io†L1-L15】

4. **`built-ins/String/prototype/replace/S15.5.4.11_A3_T1`**, **`…_A3_T2`**, and **`…_A3_T3`**
   The replacement parser now keeps a two-digit backreference only when the combined index names an existing capture; otherwise the first digit falls back to the single-digit capture and the second digit becomes literal output. This preserves `$12` when a twelfth capture exists while producing `$1` plus `'2'` for patterns with a single group. A focused `.io` script locks in the `$11` and `$1A` behaviours alongside a 12-group sanity check.【F:src/stdlib.js†L500-L516】【F:src/stdlibJS.cpp†L236-L239】【F:tests/regression/stringReplaceTwoDigitBackreference.io†L1-L8】

### Object (2 remaining)

2. **`built-ins/Object/defineProperty/15.2.3.6-4-127`** and **`built-ins/Object/defineProperty/15.2.3.6-4-128`**
   **Spec excerpt (ES3 §15.4.5.1):**
   > 12. Compute ToUint32(V).
   > 13. If Result(12) is not equal to ToNumber(V), throw a RangeError exception.
   > 14. For every integer k that is less than the value of the length property of A but not less than Result(12), if A itself has a property named ToString(k), then delete that property.
   > 15. Set the value of property P of A to Result(12).【docs/specs/ECMA-262 3.md†L4784-L4802】

   **NuXJS diagnosis:** `JSArray::setOwnProperty` calls `v.toArrayIndex(newLength)` when handling the `length` property. The helper only accepts numeric and string inputs, so boolean values (`false`/`true`) trigger a RangeError before `ToNumber`/`ToUint32` coercion runs.【src/NuXJS.cpp†L1696-L1709】 The tests expect the array to shrink to length `0` or `1` without throwing.

   **Implementation notes:** Replace the direct `toArrayIndex` call with explicit coercion: read `double raw = v.toDouble();`, bail out with RangeError when `raw` is `NaN`, negative, or larger than `2^32−1`, and otherwise compute `UInt32 coerced = static_cast<UInt32>(raw);` only if `raw == coerced`. Reuse the existing element-deletion loop for `coerced < length`. Add regression files that exercise both boolean inputs (for example `tests/regression/definePropertyLengthBooleanFalse.io` and `...BooleanTrue.io`).

### RegExp (1 remaining)

3. **`built-ins/RegExp/S15.10.2.8_A3_T15`**
   **Spec excerpt (ES3 §15.10.2.1 & §15.10.2.8):**
   > A State is an ordered pair (endIndex, captures) where captures is an internal array of NCapturingParens values. ... The production Atom :: ( Disjunction ) evaluates by creating a fresh copy of y's captures array and setting the parenIndex-th entry for each successful path.【docs/specs/ECMA-262 3.md†L6835-L6840】【docs/specs/ECMA-262 3.md†L6875-L6904】

   **NuXJS diagnosis:** Deeply nested capturing groups exhaust the hard-coded `MAX_NESTED_EXPRESSION_DEPTH` limit (`64`), so compiling a 200-parenthesis pattern throws `RangeError: Internal compiler limitations reached`.【src/NuXJS.cpp†L3702-L3705】 The test expects the engine to build all capture slots successfully.

   **Implementation notes:** Raise the recursion budget (and any matching guard) high enough for the ES3 suites, or refactor `compileRegExp` to track capturing-parenthesis depth independently from expression nesting so patterns with hundreds of groups compile. Ship an `.io` regression test that instantiates the 200-group pattern and verifies that `exec` returns the expected capture array.

### String (2 remaining)

4. **`built-ins/String/prototype/replace/S15.5.4.11_A12`**
   **Spec excerpt (ES3 §15.5.4.11):**
   > Let string denote the result of converting the this value to a string.【docs/specs/ECMA-262 3.md†L5015-L5022】

   **NuXJS diagnosis:** When `replace` is borrowed with `this` equal to `undefined`, the runtime has already substituted the global object for the receiver before `str(this)` executes. The conversion therefore yields `"[object Object]"` and the result becomes `"[object Object]"` instead of `"unDefineD"`.【F:src/stdlib.js†L486-L541】

   **Implementation notes:** Thread the original `this` value into built-ins so `String` methods can apply `ToString` to `undefined`/`null` directly. One approach is to extend the call machinery in `Function::call` to pass both the substituted object and the raw `Value`, adding a helper (e.g. `support.stringThis`) that mirrors ES3’s `ToString` semantics. Add an `.io` regression (`stringReplaceUndefinedReceiver.io`) that asserts `String.prototype.replace.call(undefined, 'd', 'D') === 'unDefineD'`.

5. **`built-ins/String/prototype/replace/S15.5.4.11_A5_T1`**
   **Spec excerpt (ES3 §15.10.2.1 & §15.10.2.8):**
   > A State ... stores the start and end of each capturing parenthesis. The backreference \1 retrieves the substring captured by the first group for each iteration.【docs/specs/ECMA-262 3.md†L6835-L6840】【docs/specs/ECMA-262 3.md†L6875-L6904】

   **NuXJS diagnosis:** The backreference quantifier branch generated by `compileRegExp` fails to iterate over the captured span when the pattern includes `\1*`, so `/^(a+)\1*,\1+$/` never matches and the replacement leaves the input unchanged.【src/stdlib.js†L1374-L1389】

   **Implementation notes:** Instrument the `case '\\'` path to ensure the quantified backreference advances `p` when the referenced capture has non-zero length. Tighten the generated guard around `stepSize = c(n+1) - c(n)` so zero-length matches terminate but positive-length captures allow repetition. Add an `.io` regression that checks `"aaaaaaaaaa,aaaaaaaaaaaaaaa".replace(/^(a+)\1*,\1+$/, "$1") === "aaaaa"`.
