# ES3 Test262 Failures Analysis

_Updated after reviewing `fails` on September 17, 2024._

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

The lists below group the remaining failing Test262 cases by feature area, summarize the behavioural gap, and quote the ES3 semantics NuXJS still needs to implement.

### Array (6)
* `built-ins/Array/prototype/pop/S15.4.4.6_A4_T2` — Borrowing `Array.prototype.pop` for a plain object does not delete the last own index, so inherited values stay hidden even though the algorithm requires removing the element before shrinking `length`.

  **Spec excerpt (§15.4.4.6):**
  > - 6. Call ToString(Result(2)–1).
  > - 7. Call the [[Get]] method of this object with argument Result(6).
  > - 8. Call the [[Delete]] method of this object with argument Result(6).
  > - 9. Call the [[Put]] method of this object with arguments "**length**" and (Result(2)–1).

  **NuXJS remediation:** Extend the generic branch in `ArrayPrototypePop` (see `src/StdArray.cpp`) so that when the receiver is not an Array instance it walks the property map and invokes `DeleteProperty` on the last key before writing the new `length` value.

* `built-ins/Array/prototype/push/S15.4.4.7_A2_T2` — When the receiver's `length` is `Infinity`, `push` should throw `TypeError` after the [[Put]] check detects that `ToUint32(length)` differs from `ToNumber(length)`, but NuXJS truncates `length` and continues.

  **Spec excerpt (§15.4.5.1):**
  > - 12. Compute ToUint32(*V*).
  > - 13. If Result(12) is not equal to ToNumber(*V*), throw a **RangeError** exception.
  > - 14. For every integer *k* that is less than the value of the **length** property of *A* but not less than Result(12), if *A* itself has a property (not an inherited property) named ToString(*k*), then delete that property.
  > - 15. Set the value of property *P* of *A* to Result(12).

  **NuXJS remediation:** Guard `ArrayPrototypePush` with a length conversion helper that first calls `ToUint32` and compares the double result; if they differ return a `RangeError` using `ThrowRangeError` instead of silently clamping.

* `built-ins/Array/prototype/shift/S15.4.4.9_A3_T3` — Negative or non-integral `length` values should coerce to `0` before any element movement, but the current implementation reads the bogus length and shifts data.

  **Spec excerpt (§15.4.4.9):**
  > - 1. Call the [[Get]] method of this object with argument "**length**".
  > - 2. Call ToUint32(Result(1)).
  > - 3. If Result(2) is not zero, go to step 6.
  > - 4. Call the [[Put]] method of this object with arguments "**length**" and Result(2).
  > - 5. Return **undefined**.

  **NuXJS remediation:** Before iterating indices in `ArrayPrototypeShift`, normalize the retrieved `length` with `ToUint32` and store it back when the conversion yields zero to avoid acting on the raw floating-point value.

* `built-ins/Array/prototype/shift/S15.4.4.9_A4_T2` — Borrowed `shift` fails to delete the vacated slot, so prototype values remain shadowed instead of reappearing as required by the tail-cleanup steps.

  **Spec excerpt (§15.4.4.9):**
  > - 15. Call the [[Delete]] method of this object with argument Result(10).
  > - 16. Increase *k* by 1.
  > - 17. Go to step 8.
  > - 18. Call the [[Delete]] method of this object with argument ToString(Result(2)–1).
  > - 19. Call the [[Put]] method of this object with arguments "**length**" and (Result(2)–1).

  **NuXJS remediation:** Mirror the spec's deletion loop for generic receivers by calling `DeleteProperty` on each shifted index and again on the final slot after the copy loop completes.

* `built-ins/Array/prototype/toLocaleString/S15.4.4.3_A1_T1` — Element `toLocaleString` hooks are skipped entirely; ES3 requires calling each element's locale method while assembling the string.

  **Spec excerpt (§15.4.4.3):**
  > - 6. Call the [[Get]] method of this object with argument **"0"**.
  > - 7. If Result(6) is **undefined** or **null**, use the empty string; otherwise, call ToObject(Result(6)).toLocaleString().
  > - 12. Call the [[Get]] method of this object with argument ToString(*k*).
  > - 13. If Result(12) is **undefined** or **null**, use the empty string; otherwise, call ToObject(Result(12)).toLocaleString().

  **NuXJS remediation:** Update the array join helper used by `toLocaleString` to call `ToObject(element)` and then look up `toLocaleString` via the property cache so that custom element implementations execute.

* `built-ins/Array/prototype/toLocaleString/S15.4.4.3_A3_T1` — When `toLocaleString` is borrowed, inherited indexed properties are ignored; the algorithm must iterate across all indices defined on the receiver.

  **Spec excerpt (§15.4.4.3):**
  > - 9. Let *k* be **1**.
  > - 10. If *k* equals Result(2), return *R*.
  > - 11. Let *S* be a string value produced by concatenating *R* and Result(4).
  > - 12. Call the [[Get]] method of this object with argument ToString(*k*).
  > - 13. If Result(12) is **undefined** or **null**, use the empty string; otherwise, call ToObject(Result(12)).toLocaleString().
  > - 14. Let *R* be a string value produced by concatenating *S* and Result(13).

  **NuXJS remediation:** Switch the index traversal to use `HasProperty`/`GetProperty` on the receiver object so inherited data properties contribute to the output the same way dense array slots do.

### Date (2)
* `built-ins/Date/TimeClip_negative_zero` — `TimeClip` must coerce −0 to +0 by adding `+0`, but NuXJS preserves −0 so dividing by the result still yields `-Infinity`.

  **Spec excerpt (§15.9.1.14):**
  > - 1. If *time* is not finite, return **NaN**.
  > - 2. If abs(Result(1)) > **8.64 x 10<sup>15</sup>**, return **NaN**.
  > - 3. Return an implementation-dependent choice of either ToInteger(Result(2)) or ToInteger(Result(2)) + (**+0**). (Adding a positive zero converts −**0** to **+0**.)

  **NuXJS remediation:** In `TimeClip`, explicitly add `+0.0` before returning the clipped value so the sign bit is cleared when the integer round-trip produces negative zero.

* `built-ins/Date/prototype/setFullYear/15.9.5.40_1` — `Date.prototype.setFullYear` should reject non-Date receivers; the current implementation accepts `Date.prototype` itself instead of throwing `TypeError`.

  **Spec excerpt (§15.9.5):**
  > None of these functions are generic; a **TypeError** exception is thrown if the **this** value is not an object for which the value of the internal [[Class]] property is **"Date"**.

  **NuXJS remediation:** Add a guard at the top of `DatePrototypeSetFullYear` that checks `thisValue->IsDate()` (or the internal [[Class]] tag) and routes failures through `ThrowTypeError`.

### Function (1)
* `built-ins/Function/prototype/S15.3.4_A5` — ES3 forbids `Function.prototype` from exposing [[Construct]], but NuXJS allows `new Function.prototype()` and returns an object instead of throwing `TypeError`.

  **Spec excerpt (§15.3):**
  > None of the built-in functions described in this section shall implement the internal [[Construct]] method unless otherwise specified in the description of a particular function.

  **NuXJS remediation:** Ensure the shared `BuiltinFunctionObject` used for `Function.prototype` sets its `Construct` callback pointer to `nullptr` and that `DoConstruct` reports a `TypeError` when invoked on non-constructible builtins.

### Object (2)
* `built-ins/Object/defineProperty/15.2.3.6-4-127` — Defining `length` with `value: false` should coerce to `0`, truncate the array, and succeed. NuXJS instead throws `RangeError: Invalid array length`.
* `built-ins/Object/defineProperty/15.2.3.6-4-128` — Likewise, setting `length` to `true` should produce `1`; the engine raises the same `RangeError` instead of updating the array length.

  **Spec excerpt (§15.4.5.1):**
  > - 12. Compute ToUint32(*V*).
  > - 13. If Result(12) is not equal to ToNumber(*V*), throw a **RangeError** exception.
  > - 14. For every integer *k* that is less than the value of the **length** property of *A* but not less than Result(12), if *A* itself has a property (not an inherited property) named ToString(*k*), then delete that property.
  > - 15. Set the value of property *P* of *A* to Result(12).

  **NuXJS remediation (4-127):** Tweak the array `[[DefineOwnProperty]]` fast path to reuse the `ArraySetLength` helper so values are coerced through `ToUint32` before the RangeError check and the shrink loop runs when the coerced integer is smaller.
  **NuXJS remediation (4-128):** The same change covers boolean `true`; add a regression asserting the coerced length becomes `1` instead of throwing.

### RegExp (16)
* `built-ins/RegExp/S15.10.2.8_A3_T15` — Deeply nested capturing groups are truncated; ES3 requires tracking every capture slot when matching.

  **Spec excerpt (§15.10.2.1):**
  > - *NCapturingParens* is the total number of left capturing parentheses (i.e. the total number of times the *Atom* :: **(** *Disjunction* **)** production is expanded) in the pattern.
  > - A *State* is an ordered pair (*endIndex*, *captures*) where *endIndex* is an integer and *captures* is an internal array of *NCapturingParens* values. … The *n*th element of *captures* is either a string that represents the value obtained by the *n*th set of capturing parentheses or **undefined** if the *n*th set of capturing parentheses hasn't been reached yet.

  **NuXJS remediation:** Resize the backtracking state object's capture vector to `NCapturingParens` when compiling the pattern so nested groups always have reserved slots and the matcher stores results without clipping.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T2` — Alternation bookkeeping drops captures that should be `undefined`, yielding the wrong match array for `/((1)|(12))((3)|(23))/`.

  **Spec excerpt (§15.10.6.2 & §15.10.2.1):**
  > - 12. Let *n* be the length of *r*'s *captures* array. (This is the same value as 15.10.2.1's *NCapturingParens*.)
  > - 13. Return a new array … For each integer *i* such that *I* > 0 and *I* ≤ *n*, set the property named ToString(*i*) to the *i*th element of *r*'s *captures* array.
  > - A *State* … holds the results of capturing parentheses. The *n*th element of *captures* is either a string … or **undefined** if the *n*th set of capturing parentheses hasn't been reached yet.

  **NuXJS remediation:** Audit the backtracking engine so that when an alternative fails it preserves the `captures` array length and explicitly writes `Value::Undefined` into skipped groups instead of truncating the vector.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T3` — `ToString` mishandles `new Object("abcdefghi")`, producing `[object Object]` instead of the wrapped string.

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |

  **NuXJS remediation:** Change the entry conversion in `RegExpExec` to call `ToString` on the `this` argument before handing it to the matcher, using `ToPrimitiveString` so wrapper objects unwrap properly.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T4` — Objects whose `toString` returns a primitive are ignored; the engine matches against `[object Object]`.

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |

  **NuXJS remediation:** After calling the object's `toString`, feed the result through the generic `ToString` helper so primitive return values are honoured instead of falling back to `[object Object]`.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T5` — `ToPrimitive` with hint `String` is incomplete; if `toString` returns an object, `valueOf` should run next before failing.

  **Spec excerpt (§9.8 & §8.6.2.6):**
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |
  > When the [[DefaultValue]] method of *O* is called with hint String, … Call the [[Get]] method … "**toString**" … If Result(3) is a primitive value, return Result(3). … Call the [[Get]] method … "**valueOf**" … If Result(7) is a primitive value, return Result(7). … Throw a **TypeError** exception.

  **NuXJS remediation:** Implement the full `ToPrimitive(obj, StringHint)` algorithm so that when `toString` yields a non-primitive we look up and invoke `valueOf` before throwing.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T10` — Number primitives such as `1.01` are not stringified, so `/1|12/` fails to match.

  **Spec excerpt (§15.10.6.2 & §9.8.1):**
  > - 1. Let *S* be the value of ToString(*string*).
  > - 2. If *m* is **+0** or −**0**, return the string **"0"**. … (Rules for ToString applied to the Number type.)

  **NuXJS remediation:** Call `ToString` on primitive number inputs before running the matcher instead of relying on implicit conversion.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T11` — Number objects (e.g. `new Number(1.012)`) likewise skip `ToString`, preventing `/2|12/` from seeing "1.012".

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |

  **NuXJS remediation:** Ensure wrapper numbers go through `ToPrimitive(obj, StringHint)` followed by `ToString`, matching the primitive path.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T12` — Objects whose `toString` returns a number (e.g. `Math.PI`) need a second `ToString` to turn that result into text; NuXJS leaves the numeric value untouched.

  **Spec excerpt (§9.8 & §9.8.1):**
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |
  > - 2. If *m* is **+0** or −**0**, return the string **"0"**. … (Rules for ToString applied to the Number type.)

  **NuXJS remediation:** After `ToPrimitive`, run the intermediate value through `ToString` so numeric return values become strings before matching.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T13` — Boolean primitives are not stringified, so `/t[a-b|q-s]/` misses the literal "true".

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Boolean | If the argument is true, then the result is "true".<br>If the argument is false, then the result is "false". |

  **NuXJS remediation:** Apply `ToString` to primitive booleans before invoking the regex engine.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T14` — Boolean objects also skip coercion, blocking `/AL|se/` from matching the wrapped "false".

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |

  **NuXJS remediation:** Reuse the `ToPrimitive` + `ToString` pipeline for Boolean wrappers so the backing string is exposed.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T15` — When `toString` returns the boolean `false`, NuXJS fails to coerce it to "false" before matching `/LS/i`.

  **Spec excerpt (§8.6.2.6 & §9.8):**
  > When the [[DefaultValue]] method of *O* is called with hint String, … Call the [[Get]] method … "**toString**" … If Result(3) is a primitive value, return Result(3). …
  > | Boolean | If the argument is true, then the result is "true".<br>If the argument is false, then the result is "false". |

  **NuXJS remediation:** After invoking the user-supplied `toString`, normalize the result with `ToString` so boolean primitives convert to their textual form.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T17` — `null` inputs are not stringified; `/ll|l/` should match "null" at index 2.

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Null | "null" |

  **NuXJS remediation:** Extend the entry coercion helper to detect `Null` and substitute the literal string "null" before matching.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T18` — `undefined` inputs are not stringified; `/nd|ne/` should find "nd" in "undefined".

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Undefined | "undefined" |

  **NuXJS remediation:** Same as above, map the `Undefined` type to the literal "undefined" before dispatching to the matcher.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T19` — `void 0` hits the same coercion gap, preventing `/e{1}/` from matching.

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Undefined | "undefined" |

  **NuXJS remediation:** The `undefined` path fix above also resolves `void 0`; add regression coverage once the coercion helper is shared.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T20` — Referencing an undeclared identifier (which evaluates to `undefined` in the test harness) is not converted to "undefined", so `/[a-f]d/` fails to match "ed".

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Undefined | "undefined" |

  **NuXJS remediation:** Once the argument coercion always produces a string, undeclared identifiers will reuse the same code path and succeed; no special handling beyond that is required.

* `built-ins/RegExp/prototype/exec/S15.10.6.2_A1_T21` — Results from function calls that evaluate to `undefined` are left as the primitive value rather than stringified prior to matching `/[a-z]n/`.

  **Spec excerpt (§15.10.6.2 & §9.8):**
  > - 1. Let *S* be the value of ToString(*string*).
  > | Undefined | "undefined" |

  **NuXJS remediation:** Same coercion helper fix as T18–T20 ensures return values of `undefined` become the literal string.

### String (7)
* `built-ins/String/prototype/replace/S15.5.4.11_A12` — `String.prototype.replace.call(undefined, …)` should coerce the `this` value to "undefined" before applying the replacement.

  **Spec excerpt (§15.5.4.11):**
  > Let *string* denote the result of converting the **this** value to a string.

  **NuXJS remediation:** In `StringPrototypeReplace`, run `ToString(thisValue)` before dispatching to the shared replace routine so `undefined` and `null` receivers get converted per the spec.

* `built-ins/String/prototype/replace/S15.5.4.11_A1_T11` — Replacement objects whose `toString` throws must propagate that exception; the engine currently swallows it.

  **Spec excerpt (§15.5.4.11 & §9.8):**
  > Otherwise, let *newstring* denote the result of converting *replaceValue* to a string.
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |

  **NuXJS remediation:** Remove the blanket try/catch around replacement coercion so exceptions from user hooks propagate; only rethrow as-is after releasing any temporary handles.

* `built-ins/String/prototype/replace/S15.5.4.11_A1_T12` — When `valueOf` throws during replacement value conversion, the error should bubble out, but it is ignored.

  **Spec excerpt (§9.8 & §8.6.2.6):**
  > | Object | Apply the following steps:<br>Call ToPrimitive(input argument, hint String).<br>Call ToString(Result(1)).<br>Return Result(2). |
  > When the [[DefaultValue]] method of *O* is called with hint String, … Call the [[Get]] method … "**toString**" … If Result(3) is a primitive value, return Result(3). … Call the [[Get]] method … "**valueOf**" … If Result(7) is a primitive value, return Result(7). … Throw a **TypeError** exception.

  **NuXJS remediation:** Delegate to a shared `ToStringWithExceptionPropagation` helper so both `toString` and `valueOf` errors escape rather than being replaced with empty strings.

* `built-ins/String/prototype/replace/S15.5.4.11_A3_T1` — `$11` sequences in replacement text must expand to capture 1 followed by the literal "1"; NuXJS keeps the literal `$11`.

  **Spec excerpt (§15.5.4.11):**
  > | \$ <i>n</i>  | The <i>n</i>th capture, where <i>n</i> is a single digit 1-9 and $\$n$ is not followed by a decimal digit. |
  > | \$ <i>nn</i> | The $nn^{th}$ capture, where $nn$ is a two-digit decimal number 01-99. |

  **NuXJS remediation:** Adjust the replacement parser to peek ahead for a second digit; when present, form the two-digit capture index, otherwise treat the second character as literal text.

* `built-ins/String/prototype/replace/S15.5.4.11_A3_T2` — The same `$11` parsing bug appears when the suffix is "15".

  **Spec excerpt (§15.5.4.11):**
  > | \$ <i>n</i>  | The <i>n</i>th capture, where <i>n</i> is a single digit 1-9 and $\$n$ is not followed by a decimal digit. |
  > | \$ <i>nn</i> | The $nn^{th}$ capture, where $nn$ is a two-digit decimal number 01-99. |

  **NuXJS remediation:** Same parser change as above ensures `$15` resolves to capture 15 while `$1` followed by `5` stays capture 1 plus literal "5".

* `built-ins/String/prototype/replace/S15.5.4.11_A3_T3` — `$11` followed by "A15" also fails to substitute capture 1 correctly.

  **Spec excerpt (§15.5.4.11):**
  > | \$ <i>n</i>  | The <i>n</i>th capture, where <i>n</i> is a single digit 1-9 and $\$n$ is not followed by a decimal digit. |
  > | \$ <i>nn</i> | The $nn^{th}$ capture, where $nn$ is a two-digit decimal number 01-99. |

  **NuXJS remediation:** After parsing a `$n` escape, append the next literal chunk even when it begins with an alphabetic character so `$1A` still substitutes capture 1.

* `built-ins/String/prototype/replace/S15.5.4.11_A5_T1` — Backreference handling for `/^(a+)\1*,\1+$/` is incomplete, leaving the original string untouched instead of collapsing to the captured `"a"`.

  **Spec excerpt (§15.10.2.1 & §15.10.2.10):**
  > - *NCapturingParens* is the total number of left capturing parentheses … The *n*th element of *captures* is either a string … or **undefined** if the *n*th set of capturing parentheses hasn't been reached yet.
  > An escape sequence of the form **\\** followed by a nonzero decimal number *n* matches the result of the *n*th set of capturing parentheses … If the regular expression has *n* or more capturing parentheses but the *n*th one is **undefined** because it hasn't captured anything, then the backreference always succeeds.

  **NuXJS remediation:** Fix the regex replacement path to read capture groups from the match result's captures array, treating missing entries as empty strings before building the output.
