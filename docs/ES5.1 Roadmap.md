# ES5.1 Implementation Roadmap

## Overview
NuXJS today is a portable C++03 engine that fully implements ECMAScript 3 with a few ES5 conveniences such as JSON support and indexed string access. Custom property getters and setters are not yet available and `Object.defineProperty` only handles data properties. Built‑in library objects are written directly in JavaScript and omit modern helpers like `Object.assign` or `Array.prototype.map`. The repository already contains a broad test suite, including `tests/from262` for conformance.

## Roadmap to ES5.1

### Object model & descriptors
- Extend the internal property representation to track attributes (`[[Writable]]`, `[[Enumerable]]`, `[[Configurable]]`) and accessor pairs.
  - `src/NuXJS.h` defines `Object::Table::Bucket`; expand the union to hold either a `Value` or a `{ get, set }` pair and add an `ACCESSOR_FLAG` bit.
  - Update `Object::getProperty` and `Object::setProperty` in `src/NuXJS.cpp` to invoke the accessor functions when the flag is present and to respect attribute bits during writes and deletes.
- Implement full `Object.defineProperty`, `Object.defineProperties`, `Object.getOwnPropertyDescriptor`, and `Object.create` in both the C++ core and `src/stdlib.js`.
  - Replace the legacy `support.defineProperty(o, name, value, readOnly, dontEnum, dontDelete)` with a `PropertyDescriptor` structure that can carry `value`, `get`, `set`, and attribute flags.
  - The runtime helper in `src/NuXJS.cpp` should validate descriptor combinations and install either a data or accessor property in the object's hash table.
- Add support for accessor syntax (`get`/`set` in object literals) and function prototype attributes.
  - Extend the parser to recognize `get name(){}` and `set name(v){}` tokens and emit descriptor objects for property creation.
  - Bootstrapping of built‑ins in `src/stdlib.js` can then define getters on prototypes, e.g. for `Function.prototype.name`.

### Strict mode
- Recognize `"use strict"` directives and enforce ES5.1 restrictions: no `with`, restricted identifiers (`eval`, `arguments`), strict `this` binding, and stricter `delete` semantics.
  - The parser must scan directive prologues and record a strict flag on each function or script node.
  - `Processor` instructions that create functions or run `eval` need to consult this flag to reject illegal syntax and to set `this` to `undefined` on plain calls.
- Ensure strict-mode evaluation for `eval` and function bodies with separate variable environments.
  - `Runtime::eval` and function invocation should instantiate distinct environment records when strict, preventing arguments/parameters aliasing and updating `delete` behavior.

### Arguments object & function semantics
- Implement ES5.1 arguments-object behavior (decoupled mapping, `Object.getOwnPropertyDescriptor` support).
  - Introduce an `ArgumentsObject` class that can either map indices to parameters or, in strict mode, hold a copy without parameter aliases.
  - `Object.getOwnPropertyDescriptor` on arguments must expose `length`, `callee`, and indexed properties with correct attributes.
- Provide `Function.prototype.bind` and ensure correct `.name`, `.length`, and `toString` outputs.
  - Implement `bind` in `src/stdlib.js`; the resulting bound functions require a C++ backing type to store the target, bound `this`, and partial arguments while exposing an adjusted `length` and `name`.
  - Revise function serialization so that `Function.prototype.toString` reconstructs source code for bound and native functions.

### Array & string methods
- Add ES5.1 array iteration utilities: `forEach`, `map`, `filter`, `some`, `every`, `reduce`, `reduceRight`, `indexOf`, `lastIndexOf`.
  - These are pure library additions to `src/stdlib.js`; each helper must follow the spec's callback invocation pattern and handle sparse arrays via `Object` property checks rather than simple loops.
- Implement string utilities like `trim`, `trimLeft`, `trimRight`, and JSON-related `toJSON` helpers.
  - Extend the string section in `src/stdlib.js` with whitespace tables identical to the spec and expose `String.prototype.trim*` methods.
  - Add `Date.prototype.toJSON` and `Number.prototype.toJSON` wrappers that call the internal `toISOString`/conversion paths.

### Object immutability controls
- Support `Object.preventExtensions`, `Object.seal`, `Object.freeze`, and related predicates (`isExtensible`, `isSealed`, `isFrozen`).
  - Add an `extensible` flag to the base `Object` class and teach `setProperty`/`setOwnProperty` to honor it, returning false when extensions are blocked.
  - Implement helpers in `src/stdlib.js` that iterate over `Object.getOwnPropertyNames` descriptors and toggle `[[Configurable]]`/`[[Writable]]` bits as required by `seal` and `freeze`.

### Date and Number extras
- Finish remaining ES5.1 Date features such as `toISOString`, `toJSON`, and `now`.
  - `src/stdlib.js` already exposes many Date methods; add a native-backed `Date.now()` that calls `support.getCurrentTime` and a spec‑compliant `toISOString` implementation in JavaScript.
- Add Number and Math helpers (`isNaN`, `isFinite` refinements, `parseInt`/`parseFloat` alignment).
  - Refine `support.isNaN`/`isFinite` semantics and expose `Number.isNaN` and `Number.isFinite` shims.
  - Ensure `parseInt` and `parseFloat` follow ES5.1 whitespace trimming rules and radix handling; update the `Math` object with any missing constants.

### Parser/VM robustness
- Update grammar to allow reserved words as property keys and recognize accessor definitions.
  - Expand the lexical grammar in `src/Parser.cpp` to treat keywords as identifiers in object literals and hook into the new accessor creation path.
- Revisit bytecode generation for new features and enforce ES5.1 evaluation order.
  - The compiler in `src/NuXJS.cpp` must emit bytecode for accessors, strict arguments, and `bind` calls while guaranteeing left‑to‑right evaluation as mandated by ES5.1.

### Testing & conformance
- Expand the existing `tests/from262` set with ES5.1 cases from Test262.
  - Import the ES5.1 section of Test262 and hook them into the `tests/from262` runner so failures can be tracked.
- Introduce regression tests for each new feature and run the full suite (`timeout 180 ./build.sh`) during development.
  - Add unit tests that cover accessor edge cases, strict‑mode violations, and bound function behavior before shipping any change.

### Documentation & tooling
- Revise compatibility notes and TypeScript guidance to reflect ES5.1 support.
  - Expand `docs/notes/ECMAScript Compatibility Notes.md` once features land and document any intentional deviations.
- Update examples and `lib.NuXJS.d.ts` to expose new APIs and maintain TypeScript type safety.
  - Regenerate declaration files so that editors pick up getters/setters and newly added methods.
