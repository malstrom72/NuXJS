# Eager stack-string capture exploration

This note captures what we observed while reviewing the NuXJS sources with the goal of formatting stack traces directly at throw time. The intent is to document the concrete work that would have to move around in the runtime so the next investigation starts from shared facts rather than restating the earlier thread.

## 1. What the current helpers do

1. `Processor::collectStackFrames` (src/NuXJS.cpp, lines 2260-2286) walks the interpreter frames, skips entries that do not have source tables, and records the `returnIP` so we do not double count the current instruction. Each captured frame stores the function name and resolved `SourceLocation` in a temporary `std::vector`.
2. `buildStackTraceText` (src/NuXJS.cpp, lines 2212-2250) formats the captured frames straight into a Node-style string. There is no intermediate `StackTrace` object anymore—the helper writes the final string directly from the iterator.
3. `Processor::ensureErrorStack` (src/NuXJS.cpp, lines 2671-2726) runs whenever we construct or rethrow an `Error`. It checks whether `.stack` already contains a string, collects frames if needed, calls the formatter once, and writes the resulting string onto the property. If the walk produced metadata, it also populates `fileName`, `lineNumber`, and `columnNumber` directly from the top frame.
4. `Processor::throwVirtualException` (src/NuXJS.cpp, lines 2729-2780) fires whenever control leaves the VM because of an exception. After calling `ensureErrorStack`, it simply reuses the stored string and propagates the top-frame metadata into the native `ScriptException` wrapper so C++ callers can report the error without re-entering JS.
5. `Compiler` assigns each `Code` object a base line index while compiling nested functions so that `lookupSourceLocation` can report source lines relative to the original script instead of the isolated function body.

The important detail is that the walking logic, the Node-style formatter, and the property population live in one place. Native helpers only decide *when* to request the capture.

## 2. What changes if we generate the string eagerly

Switching to a string-only model removes the legacy `StackTrace` cache while keeping the observable behaviour intact. The VM still has to:

* Walk the VM stack and resolve source locations so the `at file:line:column` entries match the Node layout. We now centralise that in `collectStackFrames`.
* Decide which frames to omit (native throw helpers, internal trampoline functions, async continuations) so that the formatted output aligns with the observable behaviour today. Those decisions currently live next to the walker.
* Populate the metadata properties (`fileName`, `lineNumber`, `columnNumber`) that debuggers and the regression suite expect on every error object using the same frame iterator that produced the string.
* Provide the formatted stack to both the JS-visible `Error` instance *and* the `ScriptException` wrapper that crosses the C++ boundary. The shared coordination point is now the cached string plus the throw-site metadata we derived while formatting it.

In other words, the runtime still performs the same work; the question is whether we do it once in a shared helper or repeat the logic in every throw path. The eager approach keeps the single helper while discarding the structured cache entirely.

## 3. Where the duplicated effort would appear

The code already shows two distinct consumers for the stack data:

* `ensureErrorStack` must assign the Node-style string to `.stack` on the JS object before the exception escapes.
* `throwVirtualException` must hand the native host both the formatted string and the resolved `SourceLocation` so tools like the `.io` regression harness and `NuXJSTest` can display precise diagnostics.

Because both steps happen on every throw, generating the final string eagerly inside `ensureErrorStack` means we either:

1. Build the string once, store it on the error object, and teach `throwVirtualException` to reuse it when constructing the `ScriptException`. That replaces the old `StackTrace` cache with a cached string and immediate metadata derived from the initial walk, or
2. Walk and format the stack twice—once for the JS properties and once for the host exception—because each call site currently asks for the information independently.

The second option is what we refer to as “duplicated work”: two full stack walks, two sets of allocations, and two rounds of property bookkeeping for the same throw event. The implementation now uses the first option and shifts the shared state to the cached string and throw-site metadata that we compute during the first walk.

## 4. Open questions for an eager-string prototype

If we prototype the eager approach, the code review raised a few concrete items to track:

* **Stack walker location.** The old `StackTrace::capture` helper is gone; the walker now lives inside `collectStackFrames`. Any future compatibility layer that still expects structured frames will need to translate from the transient vector.
* **`ScriptException` metadata.** Native callers (see `tools/NuXJSTest.cpp`, lines 814-999) now consult the stored string and `SourceLocation` directly. Tests that previously diffed frame lists should migrate to the cached text and metadata fields.
* **Cross-language rethrows.** When C++ catches a `ScriptException` and rethrows a JS `Error`, we carry the eager string along so we do not produce a second, slightly different stack trace. The rethrow path must continue to respect the cached string and avoid formatting work a second time.

Documenting these questions now gives us a checklist for any follow-up experiment. If a later measurement shows that eagerly building the string once is a net win, we can switch, but we should do so with a clear plan for the duplicated consumers above.

## 5. Next steps

* Confirm the eager string path serves both JS and native hosts without rewalking the stack. The regression suite now includes `.io` coverage for direct throws, built-in rethrows, and TypeError paths to verify `.stack` is populated immediately.
* Instrument the build to measure how often `.stack` is observed, how many frames we capture, and how many times an exception crosses the C++ boundary. Those numbers will tell us whether the shared string cache stays simpler *in practice*.
* Continue updating this document with any findings so that future reviews can compare the options on data rather than conjecture.
