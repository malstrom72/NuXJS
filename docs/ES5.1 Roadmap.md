# ES5.1 Implementation Roadmap

## Overview
NuXJS today is a portable C++03 engine that fully implements ECMAScript 3 while steadily growing ES5.1 support. JSON, indexed string access, custom property getters/setters, and full `Object.defineProperty` semantics are available. Built‑in library objects are written directly in JavaScript and still omit certain helpers such as `Object.assign`. The repository already contains a broad test suite, including `tests/from262` for conformance.

All ES5.1 work should be driven by regression tests. Whenever a roadmap item lands, reference its verifying `.io` file in this document. ES5‑specific regression tests live in `tests/es5`.

For faster iteration during development you can build and test only the beta target by passing `beta` to `build.sh`/`build.cmd` (for example, `./build.sh es5 native beta`), but ensure the full build succeeds before committing.
Always run the complete build and test sequence before committing:

```
timeout 600 ./build.sh
```

The build is finished only when the output includes the line:

```
=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===
```

If this message is missing, the build did not complete.

## Current Status

- [x] Build toggle: ES5.1 features are guarded by the `NUXJS_ES5` macro. Select the variant by passing
  `es5`, `es3`, or `both` to `build.sh`/`build.cmd` (`both` is the default). The build scripts set
  `NUXJS_ES5` accordingly.
 - [x] Test suite (with ES5.1 enabled): all ES5.1 tests pass (`tests/es5/functionBind.io`).

## Roadmap to ES5.1

### Object model & descriptors
		- [x] Extend the internal property representation to track attributes (`[[Writable]]`, `[[Enumerable]]`, `[[Configurable]]`) and accessor pairs.
		   - [x] `src/NuXJS.h` defines `Object::Table::Bucket`; expand the union to hold either a `Value` or a `{ get, set }` pair and add an `ACCESSOR_FLAG` bit.
		   - [x] Update `Object::getProperty` and `Object::setProperty` in `src/NuXJS.cpp` so that accessor buckets surface the getter or setter function while respecting attribute bits during writes and deletes.
						   - [x] `GET_PROPERTY_OP` in `Processor` already delegates to `Object::getProperty`; when an `ACCESSOR_FLAG` bucket is found, the getter function replaces the original value and the processor invokes it via its standard `invokeFunction` path with the object as `this`, leaving the call result on the stack. (`tests/es5/getterSetterProperties.io`)
						   - [x] `SET_PROPERTY_OP` similarly uses `Object::setProperty`; when an accessor exists, the processor calls the setter through `invokeFunction` with the provided value and keeps the caller's value as the final result. (`tests/es5/getterSetterProperties.io`)
- [x] Implement full `Object.defineProperty`, `Object.defineProperties`, `Object.getOwnPropertyDescriptor`, and `Object.create` in both the C++ core and `src/stdlib.js`. (`tests/es5/objectCreateDefineProperties.io`, `tests/es5/objectGetOwnPropertyDescriptor.io`)
	- [x] `Object.defineProperty` supports data and accessor descriptors in `src/stdlib.js`.
		- [x] `Object.defineProperties` implemented in `src/stdlib.js` (tests/es5/objectCreateDefineProperties.io).
- [x] `Object.create` implemented in `src/stdlib.js` (tests/es5/objectCreateDefineProperties.io, tests/es5/objectCreateNullProto.io).
		- [x] `Object.getOwnPropertyDescriptor` implemented in `src/stdlib.js` (`tests/es5/objectGetOwnPropertyDescriptor.io`).
- [x] Replace the legacy `support.defineProperty(o, name, value, readOnly, dontEnum, dontDelete)` with a `PropertyDescriptor` structure that can carry `value`, `get`, `set`, and attribute flags. (`tests/es5/objectDefinePropertyDescriptorStruct.io`)
- [x] The runtime helper in `src/NuXJS.cpp` validates descriptor combinations and installs either a data or accessor property in the object's hash table.
- [x] Expose enumeration helpers like `Object.keys` and `Object.getOwnPropertyNames`.
				- [x] `Object.keys` implemented in `src/stdlib.js` (`tests/es5/objectKeys.io`).
								- [x] `Object.getOwnPropertyNames` implemented (`tests/es5/objectGetOwnPropertyNames.io`).
				- [x] Add support for accessor syntax (`get`/`set` in object literals) (`tests/es5/getterSetterProperties.io`).
- [x] Add function prototype attributes. (`tests/es5/functionPrototypeAttributes.io`)
- [x] Ensure `Object.defineProperty`, `Object.defineProperties`, `Object.create`, and `Object.keys` are not constructable. *(Implemented; `tests/stdlib/checkAllPrototypes.io`)*
- [x] Extend the parser to recognize `get name(){}` and `set name(v){}` tokens and emit descriptor objects for property creation. (`tests/es5/getterSetterProperties.io`)
 - [x] Bootstrapping of built‑ins in `src/stdlib.js` can then define getters on prototypes, e.g. for `Function.prototype.name`. (`tests/es5/functionPrototypeNameGetter.io`)

### Strict mode
- [x] Detect strict directives and propagate mode.
	- [x] Add a `bool strict` member to `Code` in `src/NuXJS.h`. *(Implemented; `tests/es5/strictThisBinding.io`)*
   - [x] In `Compiler::compile` and `compileFunction` (`src/NuXJS.cpp`), scan the directive prologue by walking the leading string literals before any other token. A literal whose contents are exactly `use strict` (10 characters, case‑sensitive) toggles `code->strict`. *(Implemented; `tests/es5/strictThisBinding.io`)*
- [x] Enforce identifier restrictions and parameter checks.
   - [x] Update `Compiler::identifier` so `eval` and `arguments` trigger a syntax error when the current scope is strict. *(Implemented; `tests/es5/strictEvalArgsBinding.io`)*
   - [x] During parameter list parsing, reject duplicate names in strict functions. *(Implemented; `tests/es5/strictDuplicateParam.io`)*
- [x] Preserve `undefined` for unbound `this` values.
	- [x] Modify `Processor::enter` to skip substituting the global object when `code->strict` is set. *(Implemented; `tests/es5/strictThisBinding.io`)*
- [x] Reject `with` statements in strict code.
	- [x] Have `Compiler::withStatement` test the active scope’s `strict` flag and emit a syntax error if encountered. *(Implemented; `tests/es5/strictWithStatement.io`)*
- [x] Propagate strict mode through `eval` and isolate its environment. *(Implemented; `tests/es5/strictEvalScope.io`)*
	- [x] Pass the caller’s strict flag to `CALL_EVAL_OP` and down to `Runtime::compileEvalCode` and `Processor::enterEvalCode`. *(Implemented; `tests/es5/strictEvalScope.io`)*
	- [x] When strict, compile eval code with a fresh variable environment. *(Implemented; `tests/es5/strictEvalScope.io`)*
- [x] Tighten `delete` semantics.
	- [x] If `delete` targets a simple identifier in strict mode, emit a syntax error instead of `DELETE_NAMED_OP`. *(Implemented; `tests/es5/strictDeleteIdentifier.io`)*
- [x] Disallow implicit global variable creation.
   - [x] When strict code assigns to an undeclared identifier, raise a `ReferenceError` rather than defining a global property. *(Implemented; `tests/es5/strictImplicitGlobal.io`)*
- [x] Implement strict arguments-object behavior. *(Implemented; `tests/es5/strictArgumentsObject.io`)*
	- [x] Introduce a non-mapped `ArgumentsObject` variant and construct it in `FunctionScope` when `code->strict`. *(Implemented; `tests/es5/strictArgumentsObject.io`)*
	- [x] Ensure `arguments` does not alias parameters. *(Implemented; `tests/es5/strictArgumentsObject.io`)*

### Arguments object & function semantics
- [ ] Implement ES5.1 arguments-object behavior (decoupled mapping, `Object.getOwnPropertyDescriptor` support).
		- [ ] Introduce an `ArgumentsObject` class that can either map indices to parameters or, in strict mode, hold a copy without parameter aliases.
                - [x] `Object.getOwnPropertyDescriptor` on arguments exposes `length`, `callee`, and indexed properties with correct attributes. (`tests/es5/argumentsDescriptor.io`)
 - [x] Provide `Function.prototype.bind` and ensure correct `.name`, `.length`, and `toString` outputs.
	- [x] Implemented via runtime `support.bind` helper producing `BoundFunction` with correct constructor behavior and partial application semantics (`tests/es5/functionBind.io`).
	- [x] Optional: consider `bound` function `.name` as `"bound " + target.name` (`tests/es5/functionBind.io`).

### Spec compliance fixes
- [ ] Align ES5 semantics that differ from the current engine implementation.
	- [x] Permit `for...in` on `null` or `undefined` to yield an empty iteration instead of throwing.  *(see `docs/notes/ECMAScript Compatibility Notes.md`)*
		- [x] Make user-defined functions' `prototype` properties non-enumerable and adjust `name`/`length` attributes to match ES5.1. (`tests/es5/functionPrototypeNonEnum.io`)
		- [x] Update `Object.prototype.toString` so `arguments` objects report `[object Arguments]` and enumerate indexed slots during `for...in`. (`tests/es5/argumentsToStringEnum.io`)
		- [x] Add regression tests for each behaviour in `tests/es5`.

### Array & string methods
- [x] Add ES5.1 array iteration utilities: `forEach`, `map`, `filter`, `some`, `every`, `reduce`, `reduceRight`, `indexOf`, `lastIndexOf`.
- [x] These are pure library additions to `src/stdlib.js`; each helper must follow the spec's callback invocation pattern and handle sparse arrays via `Object` property checks rather than simple loops.
- [x] `Array.prototype.indexOf` and `Array.prototype.lastIndexOf` implemented (`tests/es5/arrayIndexOf.io`).
- [x] `Array.prototype.forEach` implemented (`tests/es5/arrayForEach.io`).
- [x] `Array.prototype.map` and `Array.prototype.filter` implemented (`tests/es5/arrayMapFilter.io`).
- [x] `Array.prototype.some` and `Array.prototype.every` implemented (`tests/es5/arraySomeEvery.io`).
- [x] `Array.prototype.reduce` and `Array.prototype.reduceRight` implemented (`tests/es5/arrayReduce.io`).
- [x] Implement string utilities like `trim`, `trimLeft`, and `trimRight`.
	- [x] Extend the string section in `src/stdlib.js` with whitespace tables identical to the spec and expose `String.prototype.trim*` methods.
	- [x] `String.prototype.trim` implemented (`tests/es5/stringTrim.io`).
	- [x] `String.prototype.trimLeft` and `trimRight` implemented (`tests/es5/stringTrimLeftRight.io`).
- [x] Implement JSON-related `toJSON` helpers.
	   - [x] Add `Date.prototype.toJSON` wrapper that calls the internal `toISOString` path.
	   - [x] Add `Number.prototype.toJSON` wrapper that calls the internal conversion path (`tests/es5/numberToJSON.io`).
	   - [x] Add `String.prototype.toJSON` wrapper returning the primitive string (`tests/es5/stringBooleanToJSON.io`).
	   - [x] Add `Boolean.prototype.toJSON` wrapper returning the primitive boolean (`tests/es5/stringBooleanToJSON.io`).

### Object immutability controls
 - [x] Support `Object.preventExtensions`, `Object.seal`, `Object.freeze`, and related predicates (`isExtensible`, `isSealed`, `isFrozen`).
- [x] Add an `extensible` flag to the base `Object` class and teach `setProperty`/`setOwnProperty` to honor it, returning false when extensions are blocked.
- [x] Implement `Object.preventExtensions` and `Object.isExtensible` helpers (`tests/es5/objectPreventExtensions.io`).
 - [x] Implement helpers in `src/stdlib.js` that iterate over `Object.getOwnPropertyNames` descriptors and toggle `[[Configurable]]`/`[[Writable]]` bits as required by `seal` and `freeze`. (`tests/es5/objectSealFreeze.io`)

### Date and Number extras
- [x] Finish remaining ES5.1 Date features such as `toISOString`, `toJSON`, and `now`.
 - [x] `Date.now` implemented using `support.getCurrentTime` (`tests/es5/dateNow.io`).
 - [x] `Date.prototype.toISOString` and `Date.prototype.toJSON` implemented (`tests/es5/dateToISOStringJSON.io`).
- [x] Add Number and Math helpers (`isNaN`, `isFinite` refinements, `parseInt`/`parseFloat` alignment).
- [x] Refine `support.isNaN`/`isFinite` semantics and expose `Number.isNaN` and `Number.isFinite` shims. *(tests/es5/numberIsFiniteIsNaN.io)*
- [x] Ensure `parseInt` and `parseFloat` follow ES5.1 whitespace trimming rules and radix handling; update the `Math` object with any missing constants. (`tests/es5/parseIntFloatWhitespace.io`)

### Parser/VM robustness
- [ ] Update grammar to allow reserved words as property keys and recognize accessor definitions.
	- [ ] Expand the lexical grammar in `src/Parser.cpp` to treat keywords as identifiers in object literals and hook into the new accessor creation path.
- [ ] Revisit bytecode generation for new features and enforce ES5.1 evaluation order.
	- [ ] The compiler in `src/NuXJS.cpp` must emit bytecode for accessors, strict arguments, and `bind` calls while guaranteeing left‑to‑right evaluation as mandated by ES5.1.

### Testing & conformance
- [ ] Expand the existing `tests/from262` set with ES5.1 cases from Test262.
- [ ] Import the ES5.1 section of Test262 and hook them into the `tests/from262` runner so failures can be tracked.
- [ ] Introduce regression tests for each new feature and run the full suite (`timeout 180 ./build.sh`) during development.
 - [ ] Add coverage in `tests/es5` for accessor edge cases, strict‑mode violations, and bound function behavior before shipping any change.

### Documentation & tooling
- [ ] Revise compatibility notes and TypeScript guidance to reflect ES5.1 support.
- [ ] Expand `docs/notes/ECMAScript Compatibility Notes.md` once features land and document any intentional deviations.
- [ ] Update examples and `lib.NuXJS.d.ts` to expose new APIs and maintain TypeScript type safety.
- [ ] Regenerate declaration files so that editors pick up getters/setters and newly added methods.
- [ ] Refresh `docs/NuXJS Documentation.md` once features land.
- [ ] The "Partial ES5 features" table currently lists the arguments object as ES3-mapped and `Object.defineProperty` as data-only; rewrite these notes after the new behavior ships.
