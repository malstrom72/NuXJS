# ES5.1 Implementation Roadmap

## Overview
NuXJS today is a portable C++03 engine that fully implements ECMAScript 3 with a few ES5 conveniences such as JSON support and indexed string access. Custom property getters and setters are not yet available and `Object.defineProperty` only handles data properties. Built‑in library objects are written directly in JavaScript and omit modern helpers like `Object.assign` or `Array.prototype.map`. The repository already contains a broad test suite, including `tests/from262` for conformance.

All ES5.1 work should be driven by regression tests. Whenever a roadmap item lands, reference its verifying `.io` file in this document.

## Roadmap to ES5.1

### Object model & descriptors
	- Extend the internal property representation to track attributes (`[[Writable]]`, `[[Enumerable]]`, `[[Configurable]]`) and accessor pairs.
       - `src/NuXJS.h` defines `Object::Table::Bucket`; expand the union to hold either a `Value` or a `{ get, set }` pair and add an `ACCESSOR_FLAG` bit.
       - Update `Object::getProperty` and `Object::setProperty` in `src/NuXJS.cpp` so that accessor buckets surface the getter or setter function while respecting attribute bits during writes and deletes.
               - `GET_PROPERTY_OP` in `Processor` already delegates to `Object::getProperty`; when an `ACCESSOR_FLAG` bucket is found, the getter function replaces the original value and the processor invokes it via its standard `invokeFunction` path with the object as `this`, leaving the call result on the stack.
               - `SET_PROPERTY_OP` similarly uses `Object::setProperty`; when an accessor exists, the processor calls the setter through `invokeFunction` with the provided value and keeps the caller's value as the final result.
- Implement full `Object.defineProperty`, `Object.defineProperties`, `Object.getOwnPropertyDescriptor`, and `Object.create` in both the C++ core and `src/stdlib.js`.
- Replace the legacy `support.defineProperty(o, name, value, readOnly, dontEnum, dontDelete)` with a `PropertyDescriptor` structure that can carry `value`, `get`, `set`, and attribute flags.
- The runtime helper in `src/NuXJS.cpp` should validate descriptor combinations and install either a data or accessor property in the object's hash table.
- Expose enumeration helpers like `Object.keys` and `Object.getOwnPropertyNames`.
- `src/stdlib.js` lacks these utilities today; adding them requires a runtime hook that can iterate over `Table::Bucket` entries regardless of enumerability.
- Implement an iterator in `src/NuXJS.cpp` that surfaces property names and attribute flags so the JavaScript shims can filter appropriately.
	- Add support for accessor syntax (`get`/`set` in object literals) and function prototype attributes.
- Extend the parser to recognize `get name(){}` and `set name(v){}` tokens and emit descriptor objects for property creation.
- Bootstrapping of built‑ins in `src/stdlib.js` can then define getters on prototypes, e.g. for `Function.prototype.name`.

### Strict mode
- Detect strict directives and propagate mode.
    - Add a `bool strict` member to `Code` in `src/NuXJS.h`. *(Implemented; `tests/regression/strictThisBinding.io`)*
    - In `Compiler::compile` and `compileFunction` (`src/NuXJS.cpp`), scan the directive prologue for "use strict" and set `code->strict`. *(Implemented; `tests/regression/strictThisBinding.io`)*
- Enforce identifier restrictions and parameter checks.
   - Update `Compiler::identifier` so `eval` and `arguments` trigger a syntax error when the current scope is strict. *(Implemented; `tests/regression/strictEvalArgsBinding.io`)*
   - During parameter list parsing, reject duplicate names in strict functions. *(Implemented; `tests/regression/strictDuplicateParam.io`)*
- Preserve `undefined` for unbound `this` values.
    - Modify `Processor::enter` to skip substituting the global object when `code->strict` is set. *(Implemented; `tests/regression/strictThisBinding.io`)*
- Reject `with` statements in strict code.
    - Have `Compiler::withStatement` test the active scope’s `strict` flag and emit a syntax error if encountered. *(Implemented; `tests/regression/strictWithStatement.io`)*
- Propagate strict mode through `eval` and isolate its environment. *(Implemented; `tests/regression/strictEvalScope.io`)*
    - Pass the caller’s strict flag to `CALL_EVAL_OP` and down to `Runtime::compileEvalCode` and `Processor::enterEvalCode`. *(Implemented; `tests/regression/strictEvalScope.io`)*
    - When strict, compile eval code with a fresh variable environment. *(Implemented; `tests/regression/strictEvalScope.io`)*
- Tighten `delete` semantics.
    - If `delete` targets a simple identifier in strict mode, emit a syntax error instead of `DELETE_NAMED_OP`. *(Implemented; `tests/regression/strictDeleteIdentifier.io`)*
- Implement strict arguments-object behavior. *(Implemented; `tests/regression/strictArgumentsObject.io`)*
    - Introduce a non-mapped `ArgumentsObject` variant and construct it in `FunctionScope` when `code->strict`. *(Implemented; `tests/regression/strictArgumentsObject.io`)*
    - Ensure `arguments` does not alias parameters. *(Implemented; `tests/regression/strictArgumentsObject.io`)*

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
	- `String.prototype.trim` implemented (`tests/regression/stringTrim.io`).
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
- Add coverage in `tests/regression` for accessor edge cases, strict‑mode violations, and bound function behavior before shipping any change.

### Documentation & tooling
- Revise compatibility notes and TypeScript guidance to reflect ES5.1 support.
- Expand `docs/notes/ECMAScript Compatibility Notes.md` once features land and document any intentional deviations.
- Update examples and `lib.NuXJS.d.ts` to expose new APIs and maintain TypeScript type safety.
- Regenerate declaration files so that editors pick up getters/setters and newly added methods.
- Refresh `docs/NuXJS Documentation.md` once features land.
- The "Partial ES5 features" table currently lists the arguments object as ES3-mapped and `Object.defineProperty` as data-only; rewrite these notes after the new behavior ships.
