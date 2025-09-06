# ECMAScript Deviations and Extensions

This document lists differences between NuXJS and the ECMAScript 3 standard along with a summary of later features that the engine supports.

## ES3 Deviations

- `\0` is interpreted as a null character even if digits follow (octal escapes are not supported).
- Unicode line separator (`\u2028`) and paragraph separator (`\u2029`) are treated as linefeeds. The non‑breaking space (`\u00A0`) counts as white space, but the zero‑width no‑break space (`\uFEFF`) does not. No other Unicode "space separator" characters are recognised.
- Implicit `valueOf` and `toString` conversions may happen earlier than specified. For example, `v[o]++` only calls `toString()` once.
- Octal (`0o`) and binary (`0b`) prefixes are not understood when converting strings to numbers.
- When the identifier of a `catch` clause is called as a function, its `this` value becomes the global object.
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
- `Boolean.prototype.toJSON`
- `JSON.parse`
- `JSON.stringify`

### Additional behaviour

- String objects allow indexed access to individual characters.
- `eval()` distinguishes between direct and indirect calls.
- `String.prototype.match` returns `null` for global patterns with no match and always uses the built-in `RegExp.prototype.exec`.
- `Array.prototype.splice` with a single argument deletes the rest of the array (ES6 behaviour).
- Many `Date` object features from ES5 are implemented.
- Regular expression flags cannot contain Unicode escape sequences.
- Unicode format control characters are preserved in source text.
- ES5 builds expose `Function.prototype.caller` and `.arguments` as throwing accessors. In strict code, `arguments.callee`
  and `arguments.caller` also raise a `TypeError`.

### Unsupported ES5 features

NuXJS still follows ES3 semantics for several constructs that changed in ES5:

- Function `name` is writable and `length` cannot be deleted.

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
