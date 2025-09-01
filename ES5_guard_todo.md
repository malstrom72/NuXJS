# ES5 Guard TODO

Detailed plan to wrap ES5 differences with `#if (NUXJS_ES5)`. Check off tasks as they are completed.

> **Rule:** If any build or test fails, roll back to the last working commit and fix the issue before committing again.

## Baseline
- [x] Ensure the working tree is clean: `git status --short`
- [x] Run baseline tests for both variants:
			- `timeout 600 ./build.sh es3`
			- `timeout 600 ./build.sh es5`

## Header guards
- [x] Wrap `compileEvalCode` strict parameter and add ES3 overload
- [x] Guard accessor infrastructure (`ACCESSOR_FLAG`, `class Accessor`, `Property` helpers`)
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
- [x] `FunctionScope` strict-mode argument handling
- Tests:
- `timeout 600 ./build.sh es3`
- `timeout 600 ./build.sh es5`
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
## Build scripts
- [x] Verify `build.sh` and `build.cmd` pass `-DNUXJS_ES5` correctly
- [x] Run combined build to validate both variants: `timeout 600 ./build.sh`

## Final validation
- [ ] Compare the ES3 build output with `main`
- [x] Run full test suite:
- `timeout 600 ./build.sh es3`
- `timeout 600 ./build.sh es5`
