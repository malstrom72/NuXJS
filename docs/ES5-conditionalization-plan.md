# ES5 conditionalization plan

The following tasks track ES5-specific code in `NuXJS.h` and `NuXJS.cpp`
that still needs `#if (NUXJS_ES5)` guards so the codebase matches the
`main` branch when ES5 support is disabled.

## `NuXJS.h`

- [ ] Remove or guard the in-source default definition of `NUXJS_ES5`.
- [ ] Wrap accessor infrastructure:
	- `ACCESSOR_FLAG` constant and forward declaration of `class Accessor`.
	- Additional `setOwnProperty` overloads for `Object`, `JSObject`,
  `JSArray`, `LazyJSObject`, `Error`, and `Arguments`.
	- `Object::getProperty`/`setProperty` variants that take `Processor&`.
	- `Property` helper methods that call getter/setter functions.
	- Definition of the `Accessor` class.
	- New opcodes `ADD_GETTER_OP` and `ADD_SETTER_OP` plus expanded
  `OpcodeInfo`.
- [ ] Guard strict‑mode support:
	- `Code::strict` field with `isStrict`/`setStrict`.
	- `Runtime::compileEvalCode` signature change and
  `Processor::enterEvalCode`/`isCurrentStrict`.
	- `Arguments` owner pointer and friendship with `FunctionScope`.
	- Updates in `FunctionScope` and `Arguments` for detaching the
  arguments object.

## `NuXJS.cpp`

- [ ] Global strings `GET_STRING` and `SET_STRING`.
- [ ] Accessor handling in `Object::getProperty`/`setProperty` and
  `Support::defineProperty`.
- [ ] Extra `setOwnProperty` overloads in `JSObject`, `JSArray`,
  `LazyJSObject`, `Error`, and `Arguments`.
- [ ] Strict‑mode machinery:
	- Initialization of `Code::strict` and propagation through
  `compileEvalCode`, `EvalFunction`, `FunctionScope`,
  `Processor::enter*`, and `THIS_OP` handling.
	- `Processor::EvalScope` isolation for direct strict eval.
	- Parser updates: `use strict` directive, identifier restrictions,
  `with` prohibition, `delete` checks, duplicate parameter errors,
  and object‑literal accessor parsing.
	- Execution changes for `WRITE_NAMED_OP`, `GET_PROPERTY_OP`,
  `SET_PROPERTY_OP`, `SET_PROPERTY_POP_OP`, `ADD_GETTER_OP`,
  `ADD_SETTER_OP`, and argument‑object detachment.
- [ ] Standard library wiring for ES5:
	- Passing `STDLIB_ES5_JS` to the bootstrap routine and forwarding the
  ES5 source through `eval`.

- [ ] Review remaining diffs to ensure all ES5 behaviour is
  conditionalised.
