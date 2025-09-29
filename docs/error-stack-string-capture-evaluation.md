# Eager stack-string capture exploration

This note captures what we observed while reviewing the NuXJS sources with the goal of formatting stack traces directly at throw time. The intent is to document the concrete work that would have to move around in the runtime so the next investigation starts from shared facts rather than restating the earlier thread.

## 1. What the current helpers do

1. `Processor::captureStackTrace` (src/NuXJS.cpp, lines 2610-2661) walks the interpreter frames, skips entries that do not have source tables, and records the `returnIP` so we do not double count the current instruction. Each captured frame stores the `Code` pointer, function name, and resolved `SourceLocation` in a `StackTrace` object.
2. `Processor::ensureErrorStack` (src/NuXJS.cpp, lines 2663-2740) is invoked whenever we construct or rethrow an `Error`. It checks whether `.stack` is already initialised, requests a stack trace if needed, formats it through `formatStackTraceString`, and writes the resulting string onto the property. If the trace contained location metadata, it also populates `fileName`, `lineNumber`, and `columnNumber`.
3. `Processor::throwVirtualException` (src/NuXJS.cpp, lines 2709-2774) runs whenever control leaves the VM because of an exception. After calling `ensureErrorStack`, it captures the same `StackTrace` again, formats the string for the `ScriptException` wrapper, and copies the metadata into the native exception object so C++ callers can report the error without re-entering JS.

The important detail is that the walking logic, the Node-style formatter, and the property population live in one place. Native helpers only decide *when* to request the capture.

## 2. What changes if we generate the string eagerly

Switching to a string-only model would not remove the need for the steps above; it would simply move them into the call sites. The VM would still have to:

* Walk the VM stack and resolve source locations so the `at file:line:column` entries match the Node layout. We currently centralise that in `captureStackTrace`.
* Decide which frames to omit (native throw helpers, internal trampoline functions, async continuations) so that the formatted output aligns with the observable behaviour today. Those decisions currently live next to the walker.
* Populate the metadata properties (`fileName`, `lineNumber`, `columnNumber`) that debuggers and the regression suite expect on every error object.
* Provide the formatted stack to both the JS-visible `Error` instance *and* the `ScriptException` wrapper that crosses the C++ boundary. Without the shared `StackTrace` object, the two consumers need to coordinate manually.

In other words, the runtime still performs the same work; the question is whether we do it once in a shared helper or repeat the logic in every throw path.

## 3. Where the duplicated effort would appear

The code already shows two distinct consumers for the stack data:

* `ensureErrorStack` must assign the Node-style string to `.stack` on the JS object before the exception escapes.
* `throwVirtualException` must hand the native host both the formatted string and the resolved `SourceLocation` so tools like the `.io` regression harness and `NuXJSTest` can display precise diagnostics.

Because both steps happen on every throw, generating the final string eagerly inside `ensureErrorStack` means we either:

1. Build the string once, store it somewhere, and teach `throwVirtualException` to reuse it when constructing the `ScriptException`. That replaces the current `StackTrace` cache with a different ad-hoc cache, or
2. Walk and format the stack twice—once for the JS properties and once for the host exception—because each call site currently asks for the information independently.

The second option is what we refer to as “duplicated work”: two full stack walks, two sets of allocations, and two rounds of property bookkeeping for the same throw event. The first option shifts the shared state from a structured object to a second string cache that still needs invalidation rules when the error is rethrown or augmented.

## 4. Open questions for an eager-string prototype

If we prototype the eager approach, the code review raised a few concrete items to track:

* **Stack walker location.** Should we delete `StackTrace::capture` entirely, or teach it to format the string directly while still returning structured frames for hosts that need them? The `.io` tests currently assert on `error.stackFrames`, so removing the structure means extending the compatibility layer.
* **`ScriptException` metadata.** Native callers (see `tools/NuXJSTest.cpp`, lines 61-133) expect to inspect the structured frame list. If we only keep the string, we need a replacement for `ScriptException::initializeMetadata` so those tests can still diff exact file/line pairs.
* **Cross-language rethrows.** When C++ catches a `ScriptException` and rethrows a JS `Error`, we would need to carry the eager string along so we do not produce a second, slightly different stack trace. The current implementation does this by reusing the stored `StackTrace` pointer.

Documenting these questions now gives us a checklist for any follow-up experiment. If a later measurement shows that eagerly building the string once is a net win, we can switch, but we should do so with a clear plan for the duplicated consumers above.

## 5. Next steps

* Keep the existing `StackTrace` cache until we have a prototype that demonstrates the eager path can serve both JS and native hosts without rewalking the stack.
* If we pursue the prototype, instrument the build to measure how often `.stack` is observed, how many frames we capture, and how many times an exception crosses the C++ boundary. Those numbers will tell us whether a string-only cache is simpler *in practice*.
* Update this document with any findings so that future reviews can compare the options on data rather than conjecture.
