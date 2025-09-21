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

- [ ] `tests/todo/regExpExecNestedCaptures.io`
  > "The **|** regular expression operator separates two alternatives. The pattern first tries to match the left *Alternative* … If choices in the left *Alternative* are exhausted, the right *Disjunction* is tried instead of the left *Alternative*. Any capturing parentheses inside a portion of the pattern skipped by **|** produce **undefined** values instead of strings."【F:docs/specs/ECMA-262 3.md†L6654-L6662】
  - **Observed behaviour:** Our backtracking engine emits code that walks each branch of `compileDisjunction` in order and keeps whichever captures are produced by the first branch that makes the whole alternative succeed. Against `((1)|(12))((3)|(23))`, the first branch chooses `"1"`, the second branch falls back from `(3)` to `(23)`, and capture 4 therefore holds `"23"`. The transcript expects the outer group to report `"3"`, so it is assuming a different capture selection strategy than the current compiler implements.【F:tests/todo/regExpExecNestedCaptures.io†L1-L14】【F:src/stdlib.js†L1502-L1522】【F:docs/specs/ECMA-262 3.md†L6654-L6662】

- [ ] `tests/todo/regExpExecUndefinedVariable.io`
  > "Variables are created when the execution scope is entered. … Variables are initialised to **undefined** when created. A variable with an Initialiser is assigned the value of its AssignmentExpression when the VariableStatement is executed, not when the variable is created."【F:docs/specs/ECMA-262 3.md†L2995-L2998】
  - **Observed behaviour:** `test.pika` runs NuXJS in interactive mode and feeds each `>` section up to the next blank line. That means `var r = …exec(x)` is compiled and executed before the later `var x;` declaration block is ever submitted, so the engine throws `ReferenceError` for `x` and subsequent reads fail. When the same script is run as one unit (or the declaration is moved into the first block) the transcript succeeds.【F:tests/todo/regExpExecUndefinedVariable.io†L1-L8】【F:tools/test.pika†L70-L112】【F:tools/NuXJSREPL.cpp†L566-L636】【F:docs/specs/ECMA-262 3.md†L2995-L2998】

- [ ] `tests/todo/regExpExecValueOfObject.io`
  > "RegExp.prototype.exec(string)… Let *S* be the value of ToString(*string*)."【F:docs/specs/ECMA-262 3.md†L7237-L7248】
  > "The operator ToString … If the input type is Object: Call ToPrimitive(input argument, hint String). Call ToString(Result(1))."【F:docs/specs/ECMA-262 3.md†L1672-L1680】
  - **Observed behaviour:** The Kleene-star expression runs through `compileDisjunction` left-to-right. Once the engine commits to the `"aa"` and `"ba"` alternatives, the remaining `"ac"` suffix cannot be matched and the loop stops, returning the prefix `"aaba"`. The spec requires `exec` to coerce objects via `ToString`, so the transcript expects the `valueOf` result `"aabaac"` to feed the matcher and produce a full-string capture. NuXJS never reaches the custom `valueOf`, so the loop runs against `[object Object]` and stops early.【F:tests/todo/regExpExecValueOfObject.io†L1-L4】【F:src/stdlib.js†L1502-L1522】【F:docs/specs/ECMA-262 3.md†L7237-L7248】【F:docs/specs/ECMA-262 3.md†L1672-L1680】

- [ ] `tests/todo/stringReplaceThrowingValueOf.io`
  > "Otherwise, let *newstring* denote the result of converting *replaceValue* to a string."【F:docs/specs/ECMA-262 3.md†L5030-L5034】
  > "When the [[DefaultValue]] method of *O* is called with hint String … Call the [[Get]] method … "toString" … If Result is a primitive value, return it. … Call … "valueOf" … If Result is a primitive value, return Result."【F:docs/specs/ECMA-262 3.md†L1384-L1397】
  - **Observed behaviour:** `String.prototype.replace` calls `str(replacementValue)` once before building the replacement function. `str` in turn uses `support.toPrimitiveString`, which prefers `toString` and never reaches the custom `valueOf`, so the `Error("Y")` is swallowed and the `catch` block never runs.【F:tests/todo/stringReplaceThrowingValueOf.io†L1-L3】【F:src/stdlib.js†L111-L136】【F:src/stdlib.js†L486-L547】【F:docs/specs/ECMA-262 3.md†L5030-L5034】【F:docs/specs/ECMA-262 3.md†L1384-L1397】
  - **Next steps:** Allow the replacer to be converted with the spec’s `ToString` (which falls back to `valueOf` only when `toString` returns a non-primitive) so the error surfaces.

- [ ] `tests/todo/stringReplaceUndefinedThis.io`
  > "Let *string* denote the result of converting the **this** value to a string."【F:docs/specs/ECMA-262 3.md†L5015-L5022】
  > "The operator ToString converts its argument … If the input type is Undefined, result "undefined"."【F:docs/specs/ECMA-262 3.md†L1672-L1679】
  - **Observed behaviour:** This is the intentional behaviour documented in the ES3 failure log: `support.callWithArgs` swaps in the global object whenever the caller supplies `undefined`, so `String.prototype.replace` ends up stringifying `[object Object]` instead of `"undefined"`. The harness therefore observes `[object Object]` instead of the expected `unDefineD`.【F:tests/todo/stringReplaceUndefinedThis.io†L1-L3】【F:docs/notes/ES3TestFailures.md†L58-L62】【F:docs/specs/ECMA-262 3.md†L5015-L5022】【F:docs/specs/ECMA-262 3.md†L1672-L1679】

- [ ] `tests/todo/validArrayLengths.io`
  > "If *P* is "length", … Compute ToUint32(*V*). If Result is not equal to ToNumber(*V*), throw a RangeError exception. For every integer *k* … delete that property. Set the value of property *P* of *A* to Result."【F:docs/specs/ECMA-262 3.md†L4789-L4805】
  - **Observed behaviour:** The array setter coerces the right-hand side via `Value::toDouble` and rejects anything that fails a `rawLength != coercedLength` check. Objects, `null`, `undefined`, and non-integer strings therefore trigger `RangeError` instead of going through the ES3 `ToUint32` algorithm that would produce `0`, `0`, and truncated lengths.【F:tests/todo/validArrayLengths.io†L1-L16】【F:src/NuXJS.cpp†L748-L763】【F:src/NuXJS.cpp†L1748-L1754】【F:docs/specs/ECMA-262 3.md†L4789-L4805】

- [ ] `tests/unconforming/cantAssignObjectToArrayLength.io`
  > "If *P* is "length", … Compute ToUint32(*V*). If Result is not equal to ToNumber(*V*), throw a RangeError exception. For every integer *k* … delete that property. Set the value of property *P* of *A* to Result."【F:docs/specs/ECMA-262 3.md†L4789-L4805】
  - **Observed behaviour:** This script exercises the same setter logic as `validArrayLengths.io`. Assigning an object with a `valueOf` hook to `a.length` runs through `Value::toDouble`, which immediately returns `NaN` for objects and throws `RangeError`. Because the exception aborts the earlier section that initialises `a`, the later bracket assignment sees `a` as undefined. The expected behaviour is to call `valueOf`, coerce the resulting primitive, and update `length` accordingly.【F:tests/unconforming/cantAssignObjectToArrayLength.io†L1-L14】【F:src/NuXJS.cpp†L748-L763】【F:src/NuXJS.cpp†L1748-L1754】【F:docs/specs/ECMA-262 3.md†L4789-L4805】
