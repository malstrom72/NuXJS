# Branch Differences: `work` vs `upstream/main`

This report summarizes the behavioral and structural differences between the local `work` branch and `upstream/main`, focusing on `src/NuXJS.cpp`, `src/NuXJS.h`, and `src/stdlib.js`.

## `src/NuXJS.cpp`

### Array Index and Length Semantics
* `Value::toArrayIndex` now only accepts canonical decimal indices: booleans no longer map to slots, empty strings and digit strings with leading zeroes are rejected, and the parser enforces the `< 2^32 − 1` bound so callers like `String::getOwnProperty` immediately drop non-canonical keys.【F:src/NuXJS.cpp†L777-L810】【F:src/NuXJS.cpp†L1027-L1042】
* `JSArray::setOwnProperty` validates assignments to `length` by coercing the incoming value to a number, rejecting NaN, negatives, or non-integer doubles before updating, and ensuring any fractional component triggers a `RangeError`.【F:src/NuXJS.cpp†L1756-L1779】

### Compiler Emission Updates
* Assignment handling emits `TYPEOF_NAMED_OP` or `READ_LOCAL_OP` before performing a write, surfacing reference errors for unresolved identifiers and ensuring locals are initialized.【F:src/NuXJS.cpp†L3700-L3729】

### Runtime Behavior Adjustments
* The array `length` coercion logic ensures dense vectors are sliced before delegating to the generic setter when attributes prevent simple writes.【F:src/NuXJS.cpp†L1756-L1779】
* `FunctionPrototypeFunction::construct` now throws a `TypeError` when invoked with `new`, aligning `Function.prototype` with spec expectations that it is not constructible.【F:src/NuXJS.cpp†L4685-L4688】

## `src/NuXJS.h`

* The opcode list now aligns with upstream again; no extra guard opcodes are present after reverting the evaluation-order experiment.【F:src/NuXJS.h†L1520-L1560】


## `src/stdlib.js`

### Primitive Conversion Helpers
* `objectToPrimitive` now calls candidate `valueOf`/`toString` methods with an explicit receiver and returns as soon as a primitive is observed, throwing only after both accessors fail—tightening compliance with ES3 conversion order.【F:src/stdlib.js†L111-L122】

### String Replacement Semantics
* `String.prototype.replace` has been refactored to build the replacement dispatch function separately, correctly handling multi-digit capture references, and to reuse the helper for both RegExp and string search cases while respecting callable replacements.【F:src/stdlib.js†L486-L548】

### Array Method Corrections
* `pop`, `push`, and `shift` now coerce `length` through numeric conversion that rejects `NaN`, negative, or infinite values, ensuring index truncation matches ES3 rules and throwing on attempts to grow an array whose length is `Infinity`.【F:src/stdlib.js†L656-L705】
* `Array.prototype.toLocaleString` iterates elements, calling each value’s own `toLocaleString` when present and building the comma-separated result explicitly, instead of delegating to the generic `Object` version.【F:src/stdlib.js†L786-L796】

### Date Handling and Time Clipping
* `checkDateClass` now rejects direct use of the shared `Date` prototype and wrapper objects lacking an internal `value`, tightening guardrails for Date methods.【F:src/stdlib.js†L829-L838】
* `timeClip` preserves `+0` by normalizing `int(z)` while still rejecting out-of-range magnitudes.【F:src/stdlib.js†L853-L857】
* `makeDateTime` now treats optional parameters that are explicitly passed as `undefined` as supplied inputs, so the `ToNumber` coercion yields `NaN` instead of defaulting to zero. That `NaN` propagates through `MakeDate`/`TimeClip`, causing the Date constructor to return an invalid time when callers provide `undefined` for later arguments.【F:src/stdlib.js†L906-L922】

### Regular Expression and Parsing Tweaks
* `regExpExecMethod` now coerces the input argument with `str()` before execution, ensuring non-string inputs are handled consistently.【F:src/stdlib.js†L1544-L1551】
* `parseInt` recognizes both lowercase and uppercase hexadecimal prefixes when auto-detecting base 16 for strings starting with `0x`/`0X`.【F:src/stdlib.js†L1612-L1631】

### Math and Error Objects
* `Math.pow` explicitly coerces both arguments to numbers and now returns `NaN` for `|x| == 1` with non-finite exponents, avoiding implementation-specific infinities.【F:src/stdlib.js†L1652-L1666】
* `createErrorConstructor` only defines the `message` property when one is supplied and `defineProperties` now sets each error prototype’s `name` via descriptors, keeping accessor metadata coherent.【F:src/stdlib.js†L1675-L1694】

### JSON Reviver and Spacing Logic
* The indentation and reviver helper functions in `JSON.stringify`/`JSON.parse` retain their previous behavior but have been structurally reformatted, maintaining functionality while improving clarity for nested helper definitions.【F:src/stdlib.js†L1717-L1795】【F:src/stdlib.js†L1797-L1829】

## Summary

Collectively, the branch strengthens language compliance for property access, array length handling, and native library behavior. These changes align runtime checks and standard library methods more closely with ECMAScript 3 expectations, and ensure the Date constructor propagates explicit `undefined` parameters to `NaN` just like the spec.【F:src/stdlib.js†L906-L922】
