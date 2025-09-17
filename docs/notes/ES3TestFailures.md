# ES3 Test262 Failures Analysis

_Updated after re-running the targeted `fails` bucket on September 17, 2025._

The `fails` manifest now lists thirteen ES3 Test262 cases spanning the Array, Function, Object, RegExp, and String built-ins.【F:fails†L1-L77】

| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Array | §15.4.4.7 | 2 |
| Function | §15.3 | 1 |
| Object | §15.2, §15.4.5.1 | 2 |
| RegExp | §15.10 | 1 |
| String | §15.5.4.11 | 7 |

Each subsection quotes the relevant ECMA-262 3rd edition requirements and summarises the current NuXJS behaviour. Every fix should ship with a focused regression `.io` test alongside the code change.

### Array (2 remaining)

1. **`built-ins/Array/prototype/push/S15.4.4.7_A3`**
   **Spec excerpt (ES3 §15.4.4.7 & §15.4.5.1):**
   > When `push` is invoked, it appends each argument via `[[Put]]` on the numeric index, then assigns the new `length`. If updating `length` produces a value whose `ToUint32` differs from `ToNumber`, the algorithm throws a `RangeError`.
   > The push function is intentionally generic; it does not require that its this value be an Array object.【F:docs/specs/ECMA-262 3.md†L4492-L4511】【F:docs/specs/ECMA-262 3.md†L4784-L4804】

   **NuXJS diagnosis:** `Array.prototype.push` pre-computes `end = offset + argc` and throws a `TypeError` when `end > 4294967295`, so the "x" element is never assigned and the observable exception type is wrong when the `length` property is already `2^32−1`.【F:src/stdlib.js†L655-L668】

   **Implementation notes:** Remove the eager overflow guard, append the arguments first, and then update the `length` property through the same `ToUint32`/`ToNumber` check used by `[[Put]]` so that the setter stores the element, preserves the old `length`, and raises a `RangeError`. Add a regression `.io` script that asserts `x[4294967295] === "x"` and that `push` reports a `RangeError` when the `length` starts at `4294967295`.

2. **`built-ins/Array/prototype/push/S15.4.4.7_A4_T2`**
   **Spec excerpt (ES3 §15.4.4.7):**
   > The `push` algorithm simply walks the argument list, calling `[[Put]]` on each successive index and finally writing the numeric result into the `length` property; because the function is intentionally generic, these steps apply to non-Array receivers as well.【F:docs/specs/ECMA-262 3.md†L4492-L4511】

   **NuXJS diagnosis:** The same overflow guard (`end > 4294967295`) rejects non-Array objects that carry a `length` near `2^32`, even though the spec allows `push` to create indices and extend `length` beyond that range on plain objects. The runtime therefore throws `TypeError: Invalid array length` instead of returning `4294967298` and writing the three new properties.【F:src/stdlib.js†L655-L668】

   **Implementation notes:** Detect when the receiver is an actual array before enforcing the `2^32−1` limit, or compute the overflow condition through the array `[[Put]]` path. Ensure plain objects can grow past `2^32−1` while genuine arrays still raise `RangeError` as required. Add an `.io` regression that borrows `push` onto an object with `length = 0xFFFFFFFF` and verifies the returned `length` and the populated numeric keys.

### Function (1 remaining)

1. **`built-ins/Function/prototype/S15.3.4_A5`**
   **Spec excerpt (ES3 §15.3, §15.3.4):**
   > None of the built-in functions described in this section shall implement the internal [[Construct]] method unless otherwise specified in the description of a particular function. ... The Function prototype object is itself a Function object (its [[Class]] is "Function") that, when invoked, accepts any arguments and returns undefined.【docs/specs/ECMA-262 3.md†L3718-L3723】【docs/specs/ECMA-262 3.md†L4241-L4248】

   **NuXJS diagnosis:** `Runtime::FunctionPrototypeFunction` inherits `ExtensibleFunction::construct`, so `new Function.prototype()` currently succeeds and manufactures an empty object.【src/NuXJS.cpp†L4607-L4624】 The test expects a TypeError instead.

   **Implementation notes:** Override `FunctionPrototypeFunction::construct` to throw a `TypeError` via `ScriptException::throwError`, mirroring the guard used by `SeparateConstructorFunction`. Add a regression `.io` test (for example `tests/regression/functionPrototypeNotConstructable.io`) that asserts `new Function.prototype()` throws.

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

### String (7 remaining)

4. **`built-ins/String/prototype/replace/S15.5.4.11_A12`**
   **Spec excerpt (ES3 §15.5.4.11):**
   > Let string denote the result of converting the this value to a string.【docs/specs/ECMA-262 3.md†L5015-L5022】

   **NuXJS diagnosis:** When `replace` is borrowed with `this` equal to `undefined`, the runtime has already substituted the global object for the receiver before `str(this)` executes. The conversion therefore yields `"[object Object]"` and the result becomes `"[object Object]"` instead of `"unDefineD"`.【src/stdlib.js†L486-L533】

   **Implementation notes:** Thread the original `this` value into built-ins so `String` methods can apply `ToString` to `undefined`/`null` directly. One approach is to extend the call machinery in `Function::call` to pass both the substituted object and the raw `Value`, adding a helper (e.g. `support.stringThis`) that mirrors ES3’s `ToString` semantics. Add an `.io` regression (`stringReplaceUndefinedReceiver.io`) that asserts `String.prototype.replace.call(undefined, 'd', 'D') === 'unDefineD'`.

5. **`built-ins/String/prototype/replace/S15.5.4.11_A1_T11`** and **`…_A1_T12`**
   **Spec excerpt (ES3 §15.5.4.11):**
   > Otherwise, let newstring denote the result of converting replaceValue to a string.【docs/specs/ECMA-262 3.md†L5028-L5037】

   **NuXJS diagnosis:** The implementation converts `replaceValue` to a string before coercing `searchValue`, so a throwing `searchValue.toString` never executes—the engine throws `"inreplaceValue"` instead of the required `"insearchValue"`.【src/stdlib.js†L487-L516】

   **Implementation notes:** Reorder the coercion logic so `searchValue` undergoes `ToString` (or `RegExp` construction) before touching `replaceValue`. Preserve the existing closure cache but delay `str(replaceValue)` until after the search operand resolves. Capture the behaviour with an `.io` test that wires throwing `toString`/`valueOf` implementations onto both operands.

6. **`built-ins/String/prototype/replace/S15.5.4.11_A3_T1`**, **`…_A3_T2`**, **`…_A3_T3`**
   **Spec excerpt (ES3 §15.5.4.11, replacement table):**
   > The sequence "$" followed by one or two decimal digits nn (0 < nn ≤ NCaptures) is replaced by the nnth captured substring. ... If nn > m, the result is implementation-defined.【docs/specs/ECMA-262 3.md†L5038-L5062】

   **NuXJS diagnosis:** When encountering `$11`, `$12`, etc., the parser consumes both digits even when the two-digit capture index exceeds the available capture count, producing `$1115` instead of `x115`. The loop in `replaceFunction` never pushes the unused second digit back into the literal output.【src/stdlib.js†L500-L509】

   **Implementation notes:** Adjust the `$`-sequence parser so an oversized two-digit index falls back to the single-digit capture followed by the literal second digit, and ensure cases like `$1A` append the trailing literal text. Add a regression (`stringReplaceTwoDigitBackreference.io`) covering `$11` concatenations and `$1A`.

7. **`built-ins/String/prototype/replace/S15.5.4.11_A5_T1`**
   **Spec excerpt (ES3 §15.10.2.1 & §15.10.2.8):**
   > A State ... stores the start and end of each capturing parenthesis. The backreference \1 retrieves the substring captured by the first group for each iteration.【docs/specs/ECMA-262 3.md†L6835-L6840】【docs/specs/ECMA-262 3.md†L6875-L6904】

   **NuXJS diagnosis:** The backreference quantifier branch generated by `compileRegExp` fails to iterate over the captured span when the pattern includes `\1*`, so `/^(a+)\1*,\1+$/` never matches and the replacement leaves the input unchanged.【src/stdlib.js†L1374-L1389】

   **Implementation notes:** Instrument the `case '\\'` path to ensure the quantified backreference advances `p` when the referenced capture has non-zero length. Tighten the generated guard around `stepSize = c(n+1) - c(n)` so zero-length matches terminate but positive-length captures allow repetition. Add an `.io` regression that checks `"aaaaaaaaaa,aaaaaaaaaaaaaaa".replace(/^(a+)\1*,\1+$/, "$1") === "aaaaa"`.
