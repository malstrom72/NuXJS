# ECMAScript Deviations and Extensions

This document lists differences between NuXJScript and the ECMAScript 3 standard along with a summary of later features that the engine supports.

## ES3 Deviations

- `\0` is interpreted as a null character even if digits follow (octal escapes are not supported).
- Unicode line separator (`\u2028`) and paragraph separator (`\u2029`) are treated as linefeeds. The non‑breaking space (`\u00A0`) counts as white space, but the zero‑width no‑break space (`\uFEFF`) does not. No other Unicode "space separator" characters are recognised.
- Custom property getters and setters are not implemented.
- Implicit `valueOf` and `toString` conversions may happen earlier than specified. For example, `v[o]++` only calls `toString()` once.
- Octal (`0o`) and binary (`0b`) prefixes are not understood when converting strings to numbers.
- The `arguments` object follows ES3 mapping semantics; changing element attributes does not fully emulate the ES5 behaviour.
- Every created function has a writable, enumerable, and configurable `name` property.
- Evaluation order of member expressions follows the ES3 order (object and arguments are evaluated before selecting the member).
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
- `Object.defineProperty` (data properties only)
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
