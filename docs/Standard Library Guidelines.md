# Standard Library Guidelines

The standard library lives in `src/stdlib.js`. After editing it, run `./build.sh` to regenerate `src/stdlibJS.cpp` and execute the regression tests.

## Formatting and style
- Follow repository formatting rules: tabs for indentation, braces on the same line and a 120-character limit.
- Add identifiers that must survive minification to the `@preserve` block at the top of `src/stdlib.js`.

## Engine interaction
- Interact with the engine only through the injected `support` object, using helpers like `defineProperty`, `callWithArgs` and `getInternalProperty`.
- Use `defineProperties` to apply `readOnly`, `dontEnum` and `dontDelete` attributes consistently.

## Avoid global objects
- Do not rely on global constructors or methods because user code may reassign them.
- Use the `$`-prefixed helpers or functions on `support` instead of global versions (for example `$charCodeAt`, `$isNaN`).

## Unconstructable methods
- Wrap functions that must not be invoked with `new` using `unconstructable` (an alias for `support.distinctConstructor`).
- This removes their `.prototype` property and throws a `TypeError` when construction is attempted.

## Language constraints
- Target ECMAScript 3 semantics.
- Avoid engine limitations such as custom getters/setters, non-ES3 evaluation order and unsupported regular expression features.
