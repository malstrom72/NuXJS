# ES5 Guard TODO

- **Important:** `timeout 600 ./build.sh es3` and `timeout 600 ./build.sh es5` must run to completion. If either build is interrupted or fails, roll back to the last working commit and fix before committing.

## Completed
- Guarded `Runtime::compileEvalCode` so ES3 builds keep the single-argument signature.
- Wrapped `BoundFunction` and `support.bind` so ES3 builds skip bound-function infrastructure.
- Guarded object literal getter/setter parsing and opcodes.
- Fixed unguarded object-literal parsing so ES3 builds match upstream.

- Guarded string-key property helpers and processor-based property access.
- Removed redundant nested `#if (NUXJS_ES5)` around `JSObject::setOwnProperty` declaration.
- Guarded `Code` strict flag and `Processor` strict-entry paths (enter/enterEvalCode/EvalScope).
- Guarded strict variable writes in `Processor::innerRun`.
- Guarded `Arguments` owner linkage and `FunctionScope` dynamic variable allocation, and restored ES3 property operations and `this` handling.
- Guarded strict reserved-name check in `Compiler::identifier` so ES3 builds return the hashed string directly.
- Guarded runtime `defineProperty` helper so ES3 builds ignore accessor pairs.
- Guarded `ACCESSOR_FLAG`, `Accessor` class, and `Property` helper so ES3 builds omit accessor infrastructure.
- Guarded standard library initialization so ES3 builds call `eval` with one argument and ES5 builds supply the extra library snippet.
- Wrapped `Support` friend declarations in core headers so ES3 builds retain the original encapsulation.

## Remaining
- Guard remaining diffs noted in `tools/diffs/whitespace_ignored_diff_from_main.patch` with `#if (NUXJS_ES5)`.

