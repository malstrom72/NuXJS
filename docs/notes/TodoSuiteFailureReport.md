# Todo Suite Failure Tracking

The expanded `test.pika` sweep currently stops on the following transcripts. Tick each checkbox once the runtime behaviour matches the expected transcript.【3027fd†L1-L4】

- [x] `tests/todo/arrayIndexTooLarge.io`
  > "A property name *P* (in the form of a string value) is an *array index* if and only if ToString(ToUint32(*P*)) is equal to *P* and ToUint32(*P*) is not equal to 2^32−1. … Specifically, whenever a property is added whose name is an array index, the **length** property is changed, if necessary, to be one more than the numeric value of that array index."【F:docs/specs/ECMA-262 3.md†L4308-L4318】
  - **Observed behaviour:** Assigning to `a["4294967296"]` should create an ordinary property and leave `length` at zero. NuXJS first runs the string through `Value::toArrayIndex`, which parses the full 32-bit value into an unsigned integer and silently wraps past `2^32` via `parseUnsignedInt`. The wrapped `0` index is then treated as a dense element write, bumping `length` to `1`.【F:tests/todo/arrayIndexTooLarge.io†L1-L9】【F:src/NuXJS.cpp†L777-L800】【F:src/NuXJS.cpp†L303-L312】
  - **Resolution:** `Value::toArrayIndex` now rejects decimal strings that would overflow `Uint32` (including `4294967295` and `4294967296`), so oversized keys stay as ordinary properties without bumping `length`.【F:src/NuXJS.cpp†L777-L807】

- [x] `tests/todo/dateYearMonthUndefined.io`
  > "If *date* is supplied use ToNumber(*date*); else use **1**. If *hours* is supplied use ToNumber(*hours*); else use **0**. If *minutes* is supplied use ToNumber(*minutes*); else use **0**. If *seconds* is supplied use ToNumber(*seconds*); else use **0**. If *ms* is supplied use ToNumber(*ms*); else use **0**."【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Observed behaviour:** The constructor forwards all arguments through `makeDateTime`, where every optional field is eagerly coerced with unary `+`. Passing `undefined` therefore yields `NaN`, the helper bails out, and `isNaN(new Date(...))` becomes `true`. The spec expects missing values to default to `0`, so the helper needs an explicit `undefined` check rather than treating the parameter as “supplied”.【F:tests/todo/dateYearMonthUndefined.io†L1-L3】【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Resolution:** `makeDateTime` now ignores `undefined` arguments and falls back to the ES3 defaults (month `0`, date `1`), so `new Date(1970, undefined)` returns the expected epoch date.【F:src/stdlib.js†L906-L920】

- [x] `tests/todo/dateYearMonthDateUndefined.io`
  > "If *date* is supplied use ToNumber(*date*); else use **1**. If *hours* is supplied use ToNumber(*hours*); else use **0**. If *minutes* is supplied use ToNumber(*minutes*); else use **0**. If *seconds* is supplied use ToNumber(*seconds*); else use **0**. If *ms* is supplied use ToNumber(*ms*); else use **0**."【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Observed behaviour:** Identical to the previous case: the third parameter is seen as `NaN` instead of using the default day of `1`, so the resulting time clip yields `NaN` rather than `0`.【F:tests/todo/dateYearMonthDateUndefined.io†L1-L3】【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Resolution:** `makeDateTime` now recognises `undefined` dates and substitutes the default day, restoring a finite timestamp for the transcript.【F:src/stdlib.js†L906-L920】

- [x] `tests/todo/dateYearMonthDateHoursUndefined.io`
  > "If *date* is supplied use ToNumber(*date*); else use **1**. If *hours* is supplied use ToNumber(*hours*); else use **0**. If *minutes* is supplied use ToNumber(*minutes*); else use **0**. If *seconds* is supplied use ToNumber(*seconds*); else use **0**. If *ms* is supplied use ToNumber(*ms*); else use **0**."【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Observed behaviour:** Again, the fourth slot runs through `+hours`, hits `NaN`, and fails before the default hour of `0` can be applied.【F:tests/todo/dateYearMonthDateHoursUndefined.io†L1-L3】【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Resolution:** The helper skips coercion for `undefined` hours and uses the default of `0`, allowing the constructor to produce midnight as required.【F:src/stdlib.js†L906-L920】

- [x] `tests/todo/dateYearMonthDateHoursMinutesUndefined.io`
  > "If *date* is supplied use ToNumber(*date*); else use **1**. If *hours* is supplied use ToNumber(*hours*); else use **0**. If *minutes* is supplied use ToNumber(*minutes*); else use **0**. If *seconds* is supplied use ToNumber(*seconds*); else use **0**. If *ms* is supplied use ToNumber(*ms*); else use **0**."【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Observed behaviour:** The minutes parameter follows the same `+minutes` path and ends up as `NaN`, so the constructor produces an invalid time instead of normalising to midnight.【F:tests/todo/dateYearMonthDateHoursMinutesUndefined.io†L1-L3】【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Resolution:** Minutes set to `undefined` now fall back to zero during date construction, matching the expected transcript.【F:src/stdlib.js†L906-L920】

- [x] `tests/todo/dateYearMonthDateHoursMinutesSecondsUndefined.io`
  > "If *date* is supplied use ToNumber(*date*); else use **1**. If *hours* is supplied use ToNumber(*hours*); else use **0**. If *minutes* is supplied use ToNumber(*minutes*); else use **0**. If *seconds* is supplied use ToNumber(*seconds*); else use **0**. If *ms* is supplied use ToNumber(*ms*); else use **0**."【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Observed behaviour:** The seconds argument also goes through the unconditional `+seconds` coercion, tripping the `NaN` guard and returning an invalid date where the transcript expects `false`.【F:tests/todo/dateYearMonthDateHoursMinutesSecondsUndefined.io†L1-L3】【F:docs/specs/ECMA-262 3.md†L6063-L6076】
  - **Resolution:** `makeDateTime` now preserves the default `0` when seconds (or later parameters) are `undefined`, so the constructor no longer returns `NaN`.【F:src/stdlib.js†L906-L920】

- [x] `tests/todo/regExpDeepCaptures.io`
  > "*NCapturingParens* is the total number of left capturing parentheses … in the pattern. … A *State* is an ordered pair (*endIndex*, *captures*) where *captures* is an internal array of *NCapturingParens* values."【F:docs/specs/ECMA-262 3.md†L6611-L6619】
  - **Observed behaviour:** The generated pattern nests 200 capturing parentheses. The compiler keeps a running `nestCounter` and aborts once it reaches the hard-coded `MAX_NESTED_EXPRESSION_DEPTH` of 64, so the run fails with “Internal compiler limitations reached” instead of returning 201 captures.【F:tests/todo/regExpDeepCaptures.io†L1-L5】【F:src/NuXJS.cpp†L3750-L3759】
  - **Resolution:** Raised `MAX_NESTED_EXPRESSION_DEPTH` to 512 so the dynamically generated RegExp helpers can introduce hundreds of nested groups without tripping the compiler guard.【F:src/NuXJS.cpp†L3771-L3779】

- [x] `tests/todo/regExpExecNestedCaptures.io`
  > "The **|** regular expression operator separates two alternatives. The pattern first tries to match the left *Alternative* … If choices in the left *Alternative* are exhausted, the right *Disjunction* is tried instead of the left *Alternative*. Any capturing parentheses inside a portion of the pattern skipped by **|** produce **undefined** values instead of strings. Thus, for example, `/((a)|(ab))((c)|(bc))/.exec("abc")` returns `["abc", "a", "a", undefined, "bc", undefined, "bc"]`."【F:docs/specs/ECMA-262 3.md†L6654-L6672】
  - **Observed behaviour:** NuXJS already follows the ES3 disjunction semantics. Matching `((1)|(12))((3)|(23))` against `"123"` yields captures `["123", "1", "1", undefined, "23", undefined, "23"]`, which lines up with the spec’s worked example. The todo transcript incorrectly expected capture 4 to be `"3"`, contradicting the normative illustration.【F:tests/todo/regExpExecNestedCaptures.io†L1-L14】【F:src/stdlib.js†L1502-L1522】【F:docs/specs/ECMA-262 3.md†L6654-L6672】
  - **Resolution:** Update the `.io` transcript so the expected value for `r[4]` is `"23"`, matching both NuXJS’s behaviour and the ES3 reference result. The test now passes without touching the RegExp compiler.【F:tests/todo/regExpExecNestedCaptures.io†L8-L13】

- [x] `tests/todo/regExpExecUndefinedVariable.io`
  > "Variables are created when the execution scope is entered. … Variables are initialised to **undefined** when created. A variable with an Initialiser is assigned the value of its AssignmentExpression when the VariableStatement is executed, not when the variable is created."【F:docs/specs/ECMA-262 3.md†L2995-L2998】
  - **Observed behaviour:** `test.pika` runs NuXJS in interactive mode and feeds each `>` section up to the next blank line. That means `var r = …exec(x)` is compiled and executed before the later `var x;` declaration block is ever submitted, so the engine throws `ReferenceError` for `x` and subsequent reads fail. When the same script is run as one unit (or the declaration is moved into the first block) the transcript succeeds.【F:tests/todo/regExpExecUndefinedVariable.io†L1-L8】【F:tools/test.pika†L70-L112】【F:tools/NuXJSREPL.cpp†L566-L636】【F:docs/specs/ECMA-262 3.md†L2995-L2998】
  - **Resolution:** Hoist the `var x;` declaration into the first command block so the interactive harness evaluates the declaration before calling `exec`. The test now exercises `RegExp.prototype.exec` with an explicitly `undefined` subject and observes the expected captures and metadata.【F:tests/todo/regExpExecUndefinedVariable.io†L1-L7】

- [x] `tests/todo/regExpExecValueOfObject.io`
  > "RegExp.prototype.exec(string)… Let *S* be the value of ToString(*string*)."【F:docs/specs/ECMA-262 3.md†L7237-L7248】
  > "The operator ToString … If the input type is Object: Call ToPrimitive(input argument, hint String). Call ToString(Result(1))."【F:docs/specs/ECMA-262 3.md†L1672-L1680】
  > "…returns the array [\"aaba\", \"ba\"] and not any of [\"aabaac\", \"aabaac\"] or [\"aabaac\", \"c\"]."【F:docs/specs/ECMA-262 3.md†L6738-L6755】
  - **Observed behaviour:** NuXJS already calls `ToString` on the subject, triggers the custom `valueOf`, and reports the spec-mandated prefix match `["aaba", "ba"]`. The todo transcript, however, expected the longer `"aabaac"` match, so the check failed even though the runtime obeyed the ES3 choice-point ordering for disjunctions.【F:tests/todo/regExpExecValueOfObject.io†L1-L11】【F:src/stdlib.js†L1502-L1522】【F:docs/specs/ECMA-262 3.md†L6738-L6755】
  - **Resolution:** Update the transcript to assert the `"aaba"` prefix, capture the coerced input via `r.input`, and flag that `valueOf` executed. The revised expectations now line up with ES3 while still demonstrating the object-to-string conversion path.【F:tests/todo/regExpExecValueOfObject.io†L1-L11】

- [x] `tests/todo/stringReplaceThrowingValueOf.io`
  > "Otherwise, let *newstring* denote the result of converting *replaceValue* to a string."【F:docs/specs/ECMA-262 3.md†L5030-L5034】
  > "When the [[DefaultValue]] method of *O* is called with hint String … Call the [[Get]] method … "toString" … If Result is a primitive value, return it. … Call … "valueOf" … If Result is a primitive value, return Result."【F:docs/specs/ECMA-262 3.md†L1384-L1397】
  - **Observed behaviour:** The original todo fed `replace` a plain object with only a throwing `valueOf`, so the spec’s `ToString` conversion stopped at the inherited `Object.prototype.toString` result `"[object Object]"` and never exercised the fallback path.【F:tests/todo/stringReplaceThrowingValueOf.io†L1-L9】【F:src/stdlib.js†L111-L136】【F:src/stdlib.js†L486-L547】【F:docs/specs/ECMA-262 3.md†L5030-L5034】【F:docs/specs/ECMA-262 3.md†L1384-L1397】
  - **Resolution:** Adjust the todo script so `toString` returns a non-primitive object, forcing `ToString` to consult `valueOf` and propagate the thrown `Error("Y")`. The updated transcript now observes the expected failure and passes on NuXJS without engine changes.【F:tests/todo/stringReplaceThrowingValueOf.io†L1-L9】

- [x] `tests/unconforming/stringReplaceUndefinedThis.io`
  > "Let *string* denote the result of converting the **this** value to a string."【F:docs/specs/ECMA-262 3.md†L5015-L5022】
  > "The operator ToString converts its argument … If the input type is Undefined, result "undefined"."【F:docs/specs/ECMA-262 3.md†L1672-L1679】
  - **Observed behaviour:** As documented in the ES3 failure log, `support.callWithArgs` swaps in the global object whenever the caller supplies `undefined`, so `String.prototype.replace` stringifies `[object Object]` rather than `"undefined"`. The unconforming transcript now codifies that divergence by asserting NuXJS's observed output.【F:tests/unconforming/stringReplaceUndefinedThis.io†L1-L6】【F:docs/notes/ES3TestFailures.md†L55-L62】【F:docs/specs/ECMA-262 3.md†L5015-L5022】【F:docs/specs/ECMA-262 3.md†L1672-L1679】
  - **Resolution:** Relocated the script to the `unconforming` suite so the regression harness treats it as a documented deviation, and updated the expectation to match the `[object Object]` stringification NuXJS deliberately preserves.【F:tests/unconforming/stringReplaceUndefinedThis.io†L1-L6】【F:docs/notes/ES3TestFailures.md†L55-L62】

- [x] `tests/todo/validArrayLengths.io`
  > "If *P* is "length", … Compute ToUint32(*V*). If Result is not equal to ToNumber(*V*), throw a RangeError exception. For every integer *k* … delete that property. Set the value of property *P* of *A* to Result."【F:docs/specs/ECMA-262 3.md†L4789-L4805】
  - **Observed behaviour:** The todo still expected a `RangeError` when writing `null` to `length`, even though ES3 maps `null` to the numeric `0` and NuXJS already stores that value without complaint. Only non-integer spellings and `undefined` should trip the guard.【F:tests/todo/validArrayLengths.io†L1-L18】【F:src/NuXJS.cpp†L748-L763】【F:docs/specs/ECMA-262 3.md†L4789-L4805】
  - **Resolution:** Update the transcript to print the coerced `0`, demonstrating that assigning `null` truncates the array while the negative, fractional, and `undefined` branches continue to throw as required.【F:tests/todo/validArrayLengths.io†L1-L20】

- [x] `tests/unconforming/cantAssignObjectToArrayLength.io`
  > "If *P* is "length", … Compute ToUint32(*V*). If Result is not equal to ToNumber(*V*), throw a RangeError exception. For every integer *k* … delete that property. Set the value of property *P* of *A* to Result."【F:docs/specs/ECMA-262 3.md†L4789-L4805】
  - **Observed behaviour:** Assigning an object with a `valueOf` hook to `a.length` runs through `Value::toDouble`, which returns `NaN` for objects and triggers NuXJS's RangeError guard. Because the setter never re-enters user hooks, neither the direct assignment nor the bracket access invokes the supplied `valueOf`, and `a.length` remains zero.【F:tests/unconforming/cantAssignObjectToArrayLength.io†L1-L18】【F:src/NuXJS.cpp†L748-L763】【F:src/NuXJS.cpp†L1748-L1754】
  - **Resolution:** Keep the script in `unconforming` and update the transcript to assert the `RangeError` along with the untouched `valueOf` flags, documenting the accepted deviation without flagging it as a failure.【F:tests/unconforming/cantAssignObjectToArrayLength.io†L1-L18】【F:docs/notes/ES3TestFailures.md†L48-L57】
