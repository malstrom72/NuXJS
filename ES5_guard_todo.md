# ES5 Guard TODO

Complete one step at a time; run tests after each step.

## Step 1 – Object literal getters/setters (DONE)
	- [x] Guard `GET_STRING` and `SET_STRING` constants.
	- [x] Guard `ADD_GETTER_OP` / `ADD_SETTER_OP` and runtime dispatch.
	- [x] Guard object literal parsing in `objectInitialiser()`.
	- Tests:
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`

## Step 2 – `compileEvalCode` strict-mode overload (DONE)
	- [x] Add ES5 overload in `NuXJS.h` and retain ES3 signature.
	- [x] Split `Runtime::compileEvalCode` and guard call sites.
	- Tests:
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`

## Step 3 – Accessor property handling
	- [ ] Guard accessor infrastructure in `NuXJS.h` (`ACCESSOR_FLAG`, `class Accessor`, `Property` helpers`).
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`
	- [ ] Guard `Object::getProperty` / `setProperty` overloads and interpreter opcodes.
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`
	- [ ] Guard accessor-aware runtime classes (`JSObject`, `LazyJSObject`, `JSArray`, `Error`, `Arguments`).
		- `timeout 600 ./build.sh es3`
		- `timeout 600 ./build.sh es5`

## Step 4 – Final validation
	- [ ] Ensure `build.sh` and `build.cmd` handle `-DNUXJS_ES5` correctly.
	- [ ] Run combined build to validate both variants:
		- `timeout 600 ./build.sh`
