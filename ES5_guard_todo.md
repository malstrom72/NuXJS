# ES5 Guard TODO

Detailed plan to wrap ES5 differences with `#if (NUXJS_ES5)`. Check off tasks as they are completed.

> **Rule:** If any build or test fails, roll back to the last working commit and fix the issue before committing again.
> Only run the variant-specific builds: `timeout 600 ./build.sh es3` and `timeout 600 ./build.sh es5`.
> Skip the combined `./build.sh` run.

## Baseline
- [x] Ensure the working tree is clean: `git status --short`
- [x] Run baseline tests for both variants:
			- `timeout 600 ./build.sh es3`
			- `timeout 600 ./build.sh es5`
			- Latest run: both variants passed on current commit

## Header guards
- [x] Wrap `compileEvalCode` strict parameter and add ES3 overload
- [x] Guard accessor infrastructure (`ACCESSOR_FLAG`, `class Accessor`, `Property` helpers`)
- [x] Guard `Code` strict flag and accessors
- Tests:
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`

## Source guards
1. Object literal getters/setters (DONE)
		- [x] Guard `GET_STRING` and `SET_STRING` constants
		- [x] Guard `ADD_GETTER_OP` / `ADD_SETTER_OP` and runtime dispatch
		- [x] Guard object literal parsing in `objectInitialiser()`
		- Tests:
				- `timeout 600 ./build.sh es3`
				- `timeout 600 ./build.sh es5`
2. `compileEvalCode` strict-mode overload (DONE)
		- [x] Guard eval call sites and implementations
		- Tests:
				- `timeout 600 ./build.sh es3`
				- `timeout 600 ./build.sh es5`
3. Accessor property handling
				- [x] Guard `ACCESSOR_FLAG` constant in `NuXJS.h`
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
				- [x] Guard `class Accessor` and related `Property` helpers in `NuXJS.h`
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
				- [x] Guard `Object::getProperty` / `setProperty` overloads and interpreter opcodes
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
								- [x] Guard `Object::setOwnProperty` string-key overload
																- `timeout 600 ./build.sh es3`
																- `timeout 600 ./build.sh es5`
								- [x] Guard runtime class helpers
																- [x] `JSObject::setOwnProperty` string-key overload
																- [x] `LazyJSObject::setOwnProperty` string-key overload
																- [x] `JSArray::setOwnProperty` string-key overload
																- [x] `Error::setOwnProperty` string-key overload
																- [x] `Arguments::setOwnProperty` string-key overload
- [x] `Arguments` owner linkage
 - [x] Guard conditional allocation in `FunctionScope::getDynamicVars`
- [x] `FunctionScope` strict-mode argument handling
- Tests:
- `timeout 600 ./build.sh es3`
- `timeout 600 ./build.sh es5`
- Latest run: both variants passed on current commit
4. Strict mode parser checks
								- [x] Guard `"use strict"` directive detection
								- [x] Guard strict-mode syntax errors:
																- `Illegal use of eval or arguments`
																- `Deleting identifier in strict code`
																- `"with" is not allowed in strict code`
																- `Duplicate parameter name not allowed in strict code`
								- [x] Guard `Processor::isCurrentStrict` and related eval call sites
								- Tests:
																- `timeout 600 ./build.sh es3`
																- `timeout 600 ./build.sh es5`
5. Bound function support
- [x] Guard `BoundFunction` type and `bind` helper
- [x] Guard registration of `support.bind` in the support function table
- Tests:
- `timeout 600 ./build.sh es3`
- `timeout 600 ./build.sh es5`
6. Runtime strict-mode enforcement
- [x] Regenerated diff shows no remaining unguarded strict-mode differences
   1. Guard `Function::getConstructTarget` and its use in `Processor::newOperation` (DONE)
- [x] Wrap declaration and definition with `#if (NUXJS_ES5)`
- [x] Guard call site in `Processor::newOperation`
- Tests:
- `timeout 600 ./build.sh es3`
- `timeout 600 ./build.sh es5`
2. Guard strict variable writes in `Processor::innerRun` (DONE)
- [x] Wrap `WRITE_NAMED_OP` and `WRITE_NAMED_POP_OP` strict checks
- Tests:
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
3. Guard strict-state handling in `Processor::enter` and `enterEvalCode`
- [x] Restore original `enterEvalCode` "local" parameter when `NUXJS_ES5` is off
- [x] Guard `isolate` flag and strict-state propagation
- [x] Conditionalize strict-state arguments and assignments
- Tests:
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
4. Guard `Processor::EvalScope` strict isolation
- [x] Wrap added members and overridden methods with `#if (NUXJS_ES5)`
- Tests:
								- `timeout 600 ./build.sh es3`
								- `timeout 600 ./build.sh es5`
## Build scripts
- [x] Verify `build.sh` and `build.cmd` pass `-DNUXJS_ES5` correctly
- [x] Ensure `NUXJS_ES5` defaults to `1` when unspecified
- [x] In `tools/stdlibToCpp.pika`, gate `STDLIB_ES5_JS` with `#if (!defined(NUXJS_ES5) || NUXJS_ES5)` so generated `stdlibJS.cpp` works without including `NuXJS.h`

## Final validation
- [x] Compare the ES3 build output with `main`
- [x] Run full test suite:
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`
## Diff blocks to verify
- [x] `GET_STRING`/`SET_STRING` constants (`ES51_vs_main_NuXJS.diff`: lines ~1-20)
- [x] String-key property helpers like `Object::setOwnProperty` and `Object::getProperty` (`ES51_vs_main_NuXJS.diff`: lines ~40-110)
- [x] Accessor-aware `Object::setProperty` and runtime class overrides (`ES51_vs_main_NuXJS.diff`: lines ~110-170)
- [x] Interpreter opcode additions `ADD_GETTER_OP` and `ADD_SETTER_OP` (`ES51_vs_main_NuXJS.diff`: lines ~300-330)
- [x] `Processor::enterEvalCode` overload and `isCurrentStrict` helper (`ES51_vs_main_NuXJS.diff`: lines ~330-380)
- [x] `BoundFunction` type, `support.bind` helper, and `Function::getConstructTarget` (`ES51_vs_main_NuXJS.diff`: lines ~740-840)
