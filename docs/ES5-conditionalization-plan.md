# ES5 conditionalization plan

The following tasks track ES5-specific changes that need wrapping in `#if (NUXJS_ES5)` blocks so that the code matches upstream `main` when the flag is disabled.

- [x] Global constants `GET_STRING` and `SET_STRING` in `NuXJS.cpp`.
- [x] Object-literal accessor parsing in `Compiler::objectInitialiser`.
- [x] `Support::defineProperty` accessor branch guarded by `NUXJS_ES5`.
- [x] `Object` overloads using `const String*` and `Processor&` plus accessor logic inside `getProperty`/`setProperty`.
- [x] Additional `setOwnProperty` overloads for `JSObject`, `JSArray`, `LazyJSObject`, `Error`, and `Arguments`.
- [x] Accessor infrastructure: `ACCESSOR_FLAG` enum value, `Accessor` class definition, and related property-handling code.
- [x] Strict-mode infrastructure: `Code::strict` field with `isStrict`/`setStrict` methods and propagation through `Runtime::compileEvalCode`, `Processor::enterEvalCode`, and `Processor::isCurrentStrict`.
- [x] Strict-mode parser restrictions for `eval`/`arguments`, `with`, `delete`, and duplicate parameters.
 - [x] New opcodes `ADD_GETTER_OP` and `ADD_SETTER_OP` plus extended `OpcodeInfo` flags.
 - [x] Accessor-aware `Property` helpers (assignment operator and `get()` implementation).
 - [x] Changes to `Arguments` and `FunctionScope` for strict-mode argument object detachment.
 - [x] Evaluate remaining diffs to ensure no unguarded ES5 behavior remains.
 - [x] Build scripts perform ES3 and ES5 double build and test when `NUXJS_TEST_ES5_VARIANTS=1`.
