# Simple Error Stack Capture Plan

## Milestone 1 – One place that formats the stack string
- [x] Move the existing Node-style formatter into a helper that only returns a `String` and never builds a `StackTrace` object.
- [x] Make the helper accept a pre-trimmed frame iterator so callers can skip VM/internal frames before formatting.
- [x] Store the resulting string directly on the `Error` instance as its canonical stack payload.

### Tests
- [x] Add a focused C++ unit that throws from native code, calls the helper once, and verifies the formatted string includes the expected header plus `    at` rows.

## Milestone 2 – Capture the string exactly once per throw
- [x] Call the new helper from every place that constructs or rethrows an `Error`, ensuring we only walk the stack when the object has no string yet.
 - [x] Confirm no legacy alias needs mirroring; `.stack` is the sole property populated during construction.
- [x] Ensure `throwVirtualException` reads the already-stored string instead of re-walking the stack.
- [x] Remove the legacy `StackTrace` data structure and build the stack string directly while walking frames.

### Tests
- [x] Extend the C++ coverage to throw, catch, and rethrow in all C++↔JS combinations, asserting the string never changes.
 - [x] Add `.io` scripts for direct throws, native rethrows, and built-in TypeError paths that confirm `.stack` is populated immediately.

## Milestone 3 – Clean documentation and guardrails
- [x] Update the stack-trace documentation to describe the new eager string path and the absence of the shared `StackTrace` data structure.
- [x] Drop any dead code that previously maintained frame lists or metadata caches.
- [x] Confirm that debugger-facing metadata (filename, line, column) now sources from the stored string or lightweight helpers.

### Tests
- [x] Run `./build.sh` to regenerate documentation artifacts and execute the regression suite, confirming the success banner appears.
