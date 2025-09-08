# ECMAScript Deviations and Extensions

This document lists differences between NuXJS and the ECMAScript 3 standard along with a summary of later features that the engine supports.

## ES3 Deviations

- In non-strict code, `\0` is interpreted as a null character even if digits follow (octal escapes are not supported). In strict code, octal escape sequences such as `\1` or `\0` followed by digits are rejected.
- Unicode line separator (`\u2028`) and paragraph separator (`\u2029`) are treated as linefeeds. The non‑breaking space (`\u00A0`) and zero‑width no‑break space (`\uFEFF`) count as white space, and the format-control characters (`\u200C`, `\u200D`) are discarded. No other Unicode "space separator" characters are recognised.
- Implicit `valueOf` and `toString` conversions may happen earlier than specified. For example, `v[o]++` only calls `toString()` once.
- Octal (`0o`) and binary (`0b`) prefixes are not understood when converting strings to numbers.
- Assignments evaluate the right-hand side before resolving the reference on the left-hand side.
- Property access may convert the property key before converting the base object.
- The lookahead operators `?=` and `?!` in regular expressions behave like ES5 assertions and cannot be quantified as in ES3.
- Case-insensitive ranges in regular expressions and zero-length captures inside repeats may not perfectly match other engines.
- A semicolon is required after `do ... while` statements.
- Creating a numeric property on an object can shadow a read-only numeric property in the prototype chain.
- Additional corner cases are covered by the tests under `tests/unconforming`.
- Assigning an object to an array's `length` property is unsupported.
- Recursive grammar constructs such as deep object literals and nested functions are limited to 64 levels to avoid stack overflow.

## Later Features

### ES5 methods

- `Array.isArray`
- `Object.prototype.hasOwnProperty`
- `Object.prototype.isPrototypeOf`
- `Object.getPrototypeOf`
- `Object.defineProperty`
- `Object.getOwnPropertyDescriptor`
- `Object.getOwnPropertyNames`
- `Object.create`
- `Object.keys`
- `Object.keys` enumerates string indices and throws a `TypeError` for `null` or `undefined` inputs.
- `Object.preventExtensions`
- `Object.isExtensible`
- `Object.seal`
- `Object.freeze`
- `Object.isSealed`
- `Object.isFrozen`
- `Number.isFinite`
- `Number.isNaN`
- `Number.prototype.toJSON`
- `String.prototype.toJSON`
- `String.prototype.trim`
- `String.prototype.trimLeft`
- `String.prototype.trimRight`
- `Boolean.prototype.toJSON`
- `Date.prototype.toJSON`
- `JSON.parse`
- `JSON.stringify`

### Additional behaviour

- String objects allow indexed access to individual characters.
- `eval()` distinguishes between direct and indirect calls; indirect calls execute in the global scope.
- `Object.preventExtensions`, `Object.seal`, and `Object.freeze` throw a `TypeError` when called on non-objects. `Object.isSealed` and `Object.isFrozen` return `true` for primitive arguments while `Object.isExtensible` returns `false`.
- `String.prototype.match` returns `null` for global patterns with no match and always uses the built-in `RegExp.prototype.exec`.
- `Array.prototype.splice` with a single argument deletes the rest of the array (ES6 behaviour).
- Many `Date` object features from ES5 are implemented.
- `Date.parse` validates ISO 8601 strings and returns `NaN` for invalid input.
- `Date.prototype.toJSON` calls the object's own `toISOString` method and returns `null` for non‑finite time values.
- `Date.prototype.toISOString` requires a `Date` receiver and throws a `RangeError` for non‑finite time values.
- `JSON.parse` supports a reviver function to transform parsed values or prune properties.
- `JSON.stringify` accepts replacer functions/arrays and a space argument for formatted output.
- Regular expression flags cannot contain Unicode escape sequences.
- `RegExp.prototype` is itself a `RegExp` instance, and the `\s` character class also matches the zero‑width no‑break space (`\uFEFF`).
- Unicode format control characters are preserved in source text.
- Regular expression literals produce distinct objects, reject invalid patterns during parsing, and allow unescaped `/` within character classes.
- ES5 builds expose `Function.prototype.caller` and `.arguments` as throwing accessors. In strict code, `arguments.callee`
  and `arguments.caller` also raise a `TypeError`.
- Non-strict `arguments` objects omit the legacy `caller` property.
- `Object.getPrototypeOf` throws a `TypeError` when called on non-object values.
- `Function.prototype.apply` accepts generic array-like objects.
- Function `name` properties are read-only but configurable.
- Global constants `NaN`, `Infinity`, and `undefined` are non-writable and non-configurable.
 - `Object.defineProperty` and `Object.defineProperties` throw a `TypeError` when the target is not an object.
 - `Object.defineProperty` throws a `TypeError` if the property cannot be defined, such as on non‑extensible objects.
 - `Object.getOwnPropertyNames` throws a `TypeError` when called on non-object values.

### ECMAScript oddities

NuXJS also handles several subtle parts of the standard that are easy to miss:

- **Hidden `ToObject` on every property access.** The spec converts primitive
  bases to objects before retrieving a property. Strings would therefore need a
  wrapper object for every indexed read. The engine uses _shallow_ string
  wrappers so indexing does not allocate, while method calls still turn `this`
  into a full `String` object as required.

- **`catch (x)` really is its own scope.** A catch clause introduces a new
  declarative environment that shadows outer bindings and must be visible to
  `eval`. NuXJS creates a transient `CatchScope` at run time so dynamic code
  inside the block sees the correct variable.

- **Built-ins can distinguish call vs construct.** Native functions may have
  separate `[[Call]]` and `[[Construct]]` paths. User-defined functions cannot
  emulate this because they share one body. Built-ins in `stdlib.js` use
  `support.distinctConstructor` to implement behaviours like `String` where the
  result differs when invoked with `new`.

These quirks are implemented so programs observe the same semantics as they
would in compliant engines.
