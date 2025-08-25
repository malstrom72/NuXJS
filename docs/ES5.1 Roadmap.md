# ES5.1 Implementation Roadmap

## Overview
NuXJS today is a portable C++03 engine that fully implements ECMAScript 3 with a few ES5 conveniences such as JSON support and indexed string access. Custom property getters and setters are not yet available and `Object.defineProperty` only handles data properties. Built‑in library objects are written directly in JavaScript and omit modern helpers like `Object.assign` or `Array.prototype.map`. The repository already contains a broad test suite, including `tests/from262` for conformance.

## Roadmap to ES5.1

### Object model & descriptors
- Extend the internal property representation to track attributes (`[[Writable]]`, `[[Enumerable]]`, `[[Configurable]]`) and accessor pairs.
- Implement full `Object.defineProperty`, `Object.defineProperties`, `Object.getOwnPropertyDescriptor`, and `Object.create` in both the C++ core and `src/stdlib.js`.
- Add support for accessor syntax (`get`/`set` in object literals) and function prototype attributes.

### Strict mode
- Recognize `"use strict"` directives and enforce ES5.1 restrictions: no `with`, restricted identifiers (`eval`, `arguments`), strict `this` binding, and stricter `delete` semantics.
- Ensure strict-mode evaluation for `eval` and function bodies with separate variable environments.

### Arguments object & function semantics
- Implement ES5.1 arguments-object behavior (decoupled mapping, `Object.getOwnPropertyDescriptor` support).
- Provide `Function.prototype.bind` and ensure correct `.name`, `.length`, and `toString` outputs.

### Array & string methods
- Add ES5.1 array iteration utilities: `forEach`, `map`, `filter`, `some`, `every`, `reduce`, `reduceRight`, `indexOf`, `lastIndexOf`.
- Implement string utilities like `trim`, `trimLeft`, `trimRight`, and JSON-related `toJSON` helpers.

### Object immutability controls
- Support `Object.preventExtensions`, `Object.seal`, `Object.freeze`, and related predicates (`isExtensible`, `isSealed`, `isFrozen`).

### Date and Number extras
- Finish remaining ES5.1 Date features such as `toISOString`, `toJSON`, and `now`.
- Add Number and Math helpers (`isNaN`, `isFinite` refinements, `parseInt`/`parseFloat` alignment).

### Parser/VM robustness
- Update grammar to allow reserved words as property keys and recognize accessor definitions.
- Revisit bytecode generation for new features and enforce ES5.1 evaluation order.

### Testing & conformance
- Expand the existing `tests/from262` set with ES5.1 cases from Test262.
- Introduce regression tests for each new feature and run the full suite (`timeout 180 ./build.sh`) during development.

### Documentation & tooling
- Revise compatibility notes and TypeScript guidance to reflect ES5.1 support.
- Update examples and `lib.NuXJS.d.ts` to expose new APIs and maintain TypeScript type safety.
