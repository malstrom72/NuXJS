# ES3 Test262 Failures Analysis

_Updated after re-running the targeted `fails` bucket on September 17, 2025._

The `fails` manifest now lists seven ES3 Test262 cases across the String built-ins.【F:fails†L1-L41】

| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Object | §15.2, §15.4.5.1 | 0 |
| RegExp | §15.10 | 0 |
| String | §15.5.4.11 | 7 |

Each subsection quotes the relevant ECMA-262 3rd edition requirements and summarises the current NuXJS behaviour. Every fix should ship with a focused regression `.io` test alongside the code change.

### Recently Resolved

1. **`built-ins/Array/prototype/push/S15.4.4.7_A3`** and **`…_A4_T2`**  
   `Array.prototype.push` now appends elements before revalidating `length`, allowing the setter to raise the mandated `RangeError` while leaving inserted data visible and permitting borrowed calls on plain objects to extend past `2^32−1`. Focused regressions capture both the array overflow and the generic-object growth scenarios.【F:src/stdlib.js†L655-L668】【F:tests/regression/arrayPushLengthRangeError.io†L1-L8】【F:tests/regression/arrayPushBorrowedLengthOverflow.io†L1-L8】

2. **`built-ins/Function/prototype/S15.3.4_A5`**  
   `Runtime::FunctionPrototypeFunction::construct` now raises a `TypeError`, preventing `new Function.prototype()` from creating objects and matching ES3's prohibition on a `[[Construct]]` hook. A regression script asserts the thrown error and message.【F:src/NuXJS.cpp†L4607-L4624】【F:tests/regression/functionPrototypeNotConstructable.io†L1-L9】

3. **`built-ins/Object/defineProperty/15.2.3.6-4-127`** and **`built-ins/Object/defineProperty/15.2.3.6-4-128`**
   `JSArray::setOwnProperty` now routes `length` updates through `ToNumber`/`ToUint32` coercions so boolean values shrink or grow arrays instead of raising `RangeError`, with regression coverage for both `false` and `true` inputs.【F:src/NuXJS.cpp†L1696-L1715】【F:tests/regression/definePropertyLengthBooleanFalse.io†L1-L5】【F:tests/regression/definePropertyLengthBooleanTrue.io†L1-L5】

4. **`built-ins/RegExp/S15.10.2.8_A3_T15`**
   The parser's nesting budget has been lifted to 512 expressions, allowing 200-parenthesis patterns to compile and execute; a regression script confirms the capture array survives compilation and matching.【F:src/NuXJS.cpp†L3706-L3717】【F:tests/regression/regExpNestedCaptureCompilation.io†L1-L16】

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
