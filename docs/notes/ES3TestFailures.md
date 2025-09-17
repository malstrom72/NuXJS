# ES3 Test262 Failures Analysis

_Updated after verifying `fails` on September 17, 2024._

Running the ES3 portion of Test262 currently leaves 34 tests failing. Optional URI helpers (`decodeURI`, `encodeURI`, and their component variants) remain excluded, as do suites tagged `bad_test` or `not_es3`. The intentionally unconforming regression test `unconforming/readOnlyNumericProps` also stays out of these counts.

| Feature | Spec Clause | Failures |
| --- | --- | ---:|
| Array | §15.4 | 6 |
| Date | §15.9 | 2 |
| Error | §15.11 | 0 |
| Function | §15.3 | 1 |
| Object | §15.2 | 2 |
| RegExp | §15.10 | 16 |
| String | §15.5 | 7 |

Each subsection below lists the outstanding failures, quotes the relevant ECMA-262 3rd edition clauses, and documents what the NuXJS sources are doing today. File paths refer to the checked-in sources in this repository so that fixes can be planned concretely.

### Array (6)

1. **`built-ins/Array/prototype/pop/S15.4.4.6_A4_T2`**  
   **Spec excerpt (ES3 §15.4.4.6):**
   > 6. Call ToString(Result(2)–1).  
   > 7. Call the [[Get]] method of this object with argument Result(6).  
   > 8. Call the [[Delete]] method of this object with argument Result(6).  
   > 9. Call the [[Put]] method of this object with arguments "length" and (Result(2)–1).
   
   **NuXJS diagnosis:** `Array.prototype.pop` lives in `src/stdlib.js` (around line 608). The implementation simply reads the element at `--len`, assigns it to `v`, and then writes `this.length = len`. When the method is borrowed for a plain object (the Test262 scenario) the write to `length` does not delete the numeric property, so the inherited value never reappears.  
   **Implementation notes:** Update `pop` so that when `len > 0` it explicitly calls `delete this[len]` (or `if (len in this) { v = this[len]; delete this[len]; }`) before storing the shortened length. The change only needs to touch `src/stdlib.js`.

2. **`built-ins/Array/prototype/push/S15.4.4.7_A2_T2`**  
   **Spec excerpt (ES3 §15.4.4.7 & §15.4.5.1):**
   > 1. Call the [[Get]] method of this object with argument "length".  
   > 2. Let *n* be the result of calling ToUint32(Result(1)).  
   > 3. Get the next argument …; if there are no more arguments, go to step 7.  
   > 4. Call the [[Put]] method … with arguments ToString(*n*) and Result(3).  
   > …  
   > §15.4.5.1 Step 13: If ToUint32(*V*) is not equal to ToNumber(*V*), throw a RangeError exception.
   
   **NuXJS diagnosis:** The implementation at `src/stdlib.js` line 618 computes `offset = uint32(this.length)` and never checks the original numeric value. When `length` is `Infinity` the helper returns `0`, the push writes at index `0`, and the array shrinks instead of throwing.  
   **Implementation notes:** Capture the raw numeric length (`var raw = +this.length;`) before coercion, compute `offset = uint32(raw);`, and compare `offset` with `raw`. If they differ, throw a `RangeError` via the existing `rangeError` helper. This guard goes in `src/stdlib.js`.

3. **`built-ins/Array/prototype/shift/S15.4.4.9_A3_T3`**  
   **Spec excerpt (ES3 §15.4.4.9):**
   > 1. Call the [[Get]] method of this object with argument "length".  
   > 2. Call ToUint32(Result(1)).  
   > 3. If Result(2) is not zero, go to step 6.  
   > 4. Call the [[Put]] method of this object with arguments "length" and Result(2).  
   > 5. Return undefined.
   
   **NuXJS diagnosis:** In `src/stdlib.js` the current body reads `if (len = uint32(this.length)) { ... }` and therefore treats negative or non-integral lengths as large positive values. The Test262 case with `length = -4294967294` shifts elements instead of returning `undefined`.  
   **Implementation notes:** Read `var raw = +this.length; var len = uint32(raw);` and, when `len === 0` or `raw <= 0` or the two values differ, immediately write `this.length = len; return undefined;`. The check belongs at the top of the function in `src/stdlib.js`.

4. **`built-ins/Array/prototype/shift/S15.4.4.9_A4_T2`**  
   **Spec excerpt (ES3 §15.4.4.9 steps 15–19):**
   > 15. Call the [[Delete]] method of this object with argument Result(10).  
   > …  
   > 18. Call the [[Delete]] method of this object with argument ToString(Result(2)–1).  
   > 19. Call the [[Put]] method of this object with arguments "length" and (Result(2)–1).
   
   **NuXJS diagnosis:** The same `shift` implementation assumes setting `this.length = len` deletes trailing elements. That is true for actual arrays but not for borrowed invocations on generic objects, so property `1` survives and hides the prototype value.  
   **Implementation notes:** After the element-moving loop, call `delete this[len];` (or delete inside the loop when a slot is moved). This ensures prototype values become visible. Edit `src/stdlib.js`.

5. **`built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1`**  
   **Spec excerpt (ES3 §15.4.4.3):**
   > 1. Call the [[Get]] method of this object with argument "length".  
   > …  
   > 6. Call the [[Get]] method of this object with argument "0".  
   > 7. If Result(6) is undefined or null, use the empty string; otherwise, call ToObject(Result(6)).toLocaleString().
   
   **NuXJS diagnosis:** `Array.prototype.toLocaleString` in `src/stdlib.js` is currently aliased to `Object.prototype.toLocaleString`, so element-specific `toLocaleString` methods never run.  
   **Implementation notes:** Replace the alias with the ES3 loop: iterate `k` from `0` to `length - 1`, fetch each element via `this[k]`, and when the value is neither `undefined` nor `null` call `ToObject(value).toLocaleString()` before concatenating. All of this work happens in `src/stdlib.js`.

6. **`built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1`**  
   **Spec excerpt:** same as item 5, steps 9–14 emphasise using `[[Get]]` so inherited indices participate.  
   **NuXJS diagnosis:** Because the implementation delegates to `Object.prototype.toLocaleString`, it neither iterates numeric indices nor consults inherited properties, so prototype elements never execute their locale hooks.  
   **Implementation notes:** The fix from item 5 (explicit iteration with `HasProperty`/`[[Get]]`) simultaneously resolves this case.

### Date (2)

7. **`built-ins/Date/TimeClip_negative_zero`**  
   **Spec excerpt (ES3 §15.9.1.14):**
   > Return an implementation-dependent choice of either ToInteger(Result(2)) or ToInteger(Result(2)) + (+0). (Adding a positive zero converts −0 to +0.)
   
   **NuXJS diagnosis:** `timeClip` in `src/stdlib.js` is currently `return (!$isFinite(z) || abs(z) > 8.64e15 ? $NaN : int(z) + 0);`. In practice `int(z)` returns `-0` and the `+ 0` is not normalising the sign, so `new Date(-0).getTime()` yields `-0`.  
   **Implementation notes:** Store the truncated value in a local (for example `var clipped = int(z);`) and explicitly return `clipped === 0 ? 0 : clipped;`. This makes the positive-zero branch obvious and fixes the observable behaviour.

8. **`built-ins/Date/prototype/setFullYear/15.9.5.40_1`**  
   **Spec excerpt (ES3 §15.9.5):**
   > None of these functions are generic; a TypeError exception is thrown if the this value is not an object for which the value of the internal [[Class]] property is "Date".
   
   **NuXJS diagnosis:** `setFullYear` in `src/stdlib.js` ultimately calls `setDateValue(this, …)` which only checks `$getInternalProperty(this, "class") === "Date"`. The prototype object is a `GenericWrapper` tagged "Date", so the method happily mutates it instead of throwing.  
   **Implementation notes:** Strengthen `setDateValue` (also in `src/stdlib.js`) to require that the receiver is an actual instance (e.g. reject when `this === support.prototypes.Date` or when `$getInternalProperty(this, "value")` is `undefined`). Throw `typeError("this is not a Date object")` in that branch.

### Function (1)

9. **`built-ins/Function/prototype/S15.3.4_A5`**  
   **Spec excerpt (ES3 §15.3):**
   > None of the built-in functions described in this section shall implement the internal [[Construct]] method unless otherwise specified.
   
   **NuXJS diagnosis:** `Runtime::FunctionPrototypeFunction` (defined in `src/NuXJS.cpp` around line 4600) inherits the default `Function::construct`, so `new Function.prototype()` succeeds and returns an object.  
   **Implementation notes:** Override `FunctionPrototypeFunction::construct` to throw a `TypeError` (mirroring the behaviour in `SeparateConstructorFunction`) so attempts to construct `Function.prototype` fail as required.

### Object (2)

10. **`built-ins/Object/defineProperty/15.2.3.6-4-127`** and **`15.2.3.6-4-128`**  
    **Spec excerpt (ES3 §15.4.5.1 steps 12–15):**
    > 12. Compute ToUint32(*V*).  
    > 13. If Result(12) is not equal to ToNumber(*V*), throw a RangeError exception.  
    > 14. … delete own properties with indexes ≥ Result(12).  
    > 15. Set the value of property *P* of *A* to Result(12).
    
    **NuXJS diagnosis:** In `JSArray::setOwnProperty` (`src/NuXJS.cpp` line ~1700) the fast path calls `v.toArrayIndex(newLength)`. That helper only accepts numeric and string inputs, so booleans (`false` and `true`) trigger the RangeError that Test262 observes.  
    **Implementation notes:** Replace the `toArrayIndex` check with a call that performs ToNumber/ToUint32 faithfully: e.g. `double raw = v.toDouble(); UInt32 coerced; if (!Value(raw).toArrayIndex(coerced) || static_cast<double>(coerced) != raw) { ... }`. After coercion, reuse the existing shrink logic.

### RegExp (16)

11. **`built-ins/RegExp/S15.10.2.8_A3_T15`**  
    **Spec excerpt (ES3 §15.10.2.1):**
    > A State is an ordered pair (*endIndex*, *captures*) where *captures* is an internal array of *NCapturingParens* values. … The *n*th element of *captures* is either a string … or undefined if the *n*th set … hasn't been reached yet.
    
    **NuXJS diagnosis:** Deeply nested capture groups exhaust the compiler limit in `Compiler::optionalExpression`. The constant `MAX_NESTED_EXPRESSION_DEPTH` (defined in `src/NuXJS.cpp` at line 3693) is 64, so compiling the 200-group pattern throws `RangeError: Internal compiler limitations reached…`.  
    **Implementation notes:** Raise `MAX_NESTED_EXPRESSION_DEPTH` (and the associated safety checks) high enough to cover the Test262 input, or refactor the regex compiler so it counts parenthesis depth separately from general expression nesting.

12. **`built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2` through `…_A1_T21`**  
    **Spec excerpt (ES3 §15.10.6.2 & §9.8):**
    > 1. Let *S* be the value of ToString(*string*).  
    > …  
    > For Boolean, Number, and String object arguments, the ToString conversion must unwrap the underlying primitive value.
    
    **NuXJS diagnosis:** All of the failing cases share the same root cause: the helper `str` in `src/stdlib.js` (`function str(o) { return '' + (isPrimitive(o) ? o : support.toPrimitiveString(o)) }`) does not actually unwrap wrapper objects. In practice `support.toPrimitiveString(o)` returns `'[object Number]'`, `'[object Boolean]'`, or `'[object String]'`. As a result, `/2|12/.exec(new Number(1.012))` searches the literal string `"[object Number]"` (producing match "je" at index 3), `/ll|l/.exec(null)` operates on `"[object Null]"`, and so on. The incorrect coercion also shows up in the capture array—for example `r.input` becomes `"[object String]"` in the nested capture test.  
    **Implementation notes:** Rework `str` in `src/stdlib.js` to recognise NuXJS wrapper objects explicitly: fetch `$getInternalProperty(o, "class")` and, for known wrappers (`"String"`, `"Number"`, `"Boolean"`), read their internal `"value"` slot before producing the string. This ensures RegExp input, capture substrings, and `input`/`index` metadata line up with the ES3 expectations.

### String (7)

13. **`built-ins/String/prototype/replace/S15.5.4.11_A12`**  
    **Spec excerpt (ES3 §15.5.4.11):**
    > Let *string* denote the result of converting the this value to a string.
    
    **NuXJS diagnosis:** `String.prototype.replace.call(undefined, 'd', 'D')` currently returns `[object Object]`. This comes from the same `str` helper—`str(this)` evaluates to `"[object Object]"` instead of `"undefined"`.  
    **Implementation notes:** Fixing `str` (see item 12) resolves the receiver coercion. Once the helper is correct, the existing concatenation logic produces `"unDefineD"` as required.

14. **`built-ins/String/prototype/replace/S15.5.4.11_A1_T12`**  
    **Spec excerpt (§15.5.4.11 & §9.8):**
    > Otherwise, let *newstring* denote the result of converting *replaceValue* to a string.
    
    **NuXJS diagnosis:** When the replacement object only defines `valueOf` (and it throws), the exception is swallowed and the method returns `[object Object]`. The current implementation only calls `toString` in `objectToPrimitive`, so `valueOf` is never consulted.  
    **Implementation notes:** Update `objectToPrimitive` in `src/stdlib.js` so that when `toString` returns a non-primitive it falls back to `valueOf`. Propagate any exception instead of continuing.

15. **`built-ins/String/prototype/replace/S15.5.4.11_A1_T11`**  
    **NuXJS diagnosis:** This test verifies the `toString` path. Once `objectToPrimitive` propagates thrown exceptions (see item 14) the behaviour matches the spec.

16. **`built-ins/String/prototype/replace/S15.5.4.11_A3_T1`**, **`…_A3_T2`**, **`…_A3_T3`**  
    **Spec excerpt (§15.5.4.11 substitution patterns):**
    > The sequence "$" followed by one or two decimal digits *nn* (0 < *nn* ≤ *NCaptures*) is replaced by the *nn*th captured substring.
    
    **NuXJS diagnosis:** The parser inside `replace` treats `$11` as a literal instead of capture 1 followed by `"1"`, so concatenated strings such as `"$11" + "15"` produce `$1115` instead of `x115`. The switch statement in the replacement helper only considers two digits when the resulting number fits within the capture count; otherwise it falls back to `$` + digit without pushing the extra literal character back into the output.  
    **Implementation notes:** Adjust the replacement parser (in `src/stdlib.js` inside the `replace` closure) so that when a two-digit reference is too large it emits the first digit’s capture and then appends the second digit as literal text. Also ensure `$1A` and similar cases append the literal suffix.

17. **`built-ins/String/prototype/replace/S15.5.4.11_A5_T1`**  
    **Spec excerpt (§15.10.2.1 & §15.10.2.10):**
    > An escape sequence of the form "\" followed by a nonzero decimal number *n* matches the result of the *n*th set of capturing parentheses.
    
    **NuXJS diagnosis:** The backreference handling in the regex replacement path reads the raw capture slots produced by `regExpExecMethod`. Because those slots currently hold substrings from `"[object String]"` (see item 12) the replacement leaves the original text untouched. Once the `str` coercion is fixed, the correct captures (`"a"` for `\1`) become available and the replacement reduces `"aa,a"` to `"a"`.  
    **Implementation notes:** No additional work beyond the `str` fix is required here.

