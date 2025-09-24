# JavaScript Exception Diagnostics Investigation

## Goals
- Surface the JavaScript filename, line, column, and stack for every uncaught exception that escapes `NuXJS::Processor`.
- Provide diagnostics without adding steady-state interpreter cost: all metadata is produced at compile time and all heap work happens only while unwinding.
- Keep the implementation tight by modifying the minimal set of types that already marshal bytecode, frames, or exception payloads.

## Current pipeline audit (source references)
- **Throw path (`src/NuXJS.cpp:2413-2430`).** `Processor::throwVirtualException` immediately calls `reset()` and throws `ScriptException` when `firstCatcher == 0`, erasing `currentFrame`, `ip`, and `sp` before the host can inspect them.
- **Interpreter frames (`src/NuXJS.h:1559-1586`).** `Processor::Frame` stores the executing `Code`, `returnIP`, scope, and `thisObject`, but no code snapshots them before `reset()` clears the chain.
- **Bytecode container (`src/NuXJS.h:818-870`, `src/NuXJS.cpp:1595-1612`).** `Code` keeps opcode words, constants, names, and the lazily-built `source` string, yet drops the originating filename and exposes no opcode→source lookup table.
- **Compiler emission hook (`src/NuXJS.cpp:2967-3020`).** Every opcode funnels through `Compiler::CodeSection::emit`, giving us a single instrumentation point for recording source offsets without touching the main interpreter loop.
- **Parser location helpers (`src/NuXJS.cpp:4605-4616`).** `Compiler::getStopPosition` already computes `(offset, line, column)` for syntax errors from the same cursor state we need for stack traces.
- **Exception object (`src/NuXJS.h:1209-1232`, `src/NuXJS.cpp:2116-2124`).** `ScriptException` carries only the thrown `Value` and a cached UTF-8 string. Hosts have no structured access to source locations or stack frames.
- **JavaScript `Error` (`src/NuXJS.h:972-1018`).** Errors lazily mirror `name`/`message` but expose no slots for `fileName`, `lineNumber`, or `stack`.

## Detailed implementation plan

### 1. Preserve JavaScript source identity through compilation
1. **Extend `Code` with filename + source map containers.**
   - Add `const String* fileName`, `Vector<UInt32> opcodeOffsets`, and `Vector<UInt32> lineStartOffsets` (for on-demand line/column lookup) to `class Code` in `src/NuXJS.h`.
   - Initialize the new members in `Code::Code` (`src/NuXJS.cpp:1595-1612`) with `0`/empty vectors and ensure `gcMarkReferences` marks `fileName` plus both vectors.
2. **Thread filenames into compilation entry points.**
   - In `Runtime::compileGlobalCode` (`src/NuXJS.cpp:5154-5181`) assign the incoming `filename` to `code->fileName`.
   - In `Runtime::compileEvalCode` (`src/NuXJS.cpp:5204-5227`) set `fileName` to a cached interned string such as `"<eval>"` so eval stack frames still report a source.
   - When `Compiler::functionDefinition` emits nested functions (`src/NuXJS.cpp:4550-4598`), copy the outer `Code`'s `fileName` to the new child `Code` unless the function literal carries its own `source` string.
3. **Capture opcode character offsets while compiling.**
   - Add a lightweight helper (`Compiler::recordSourceLocation`) invoked from `CodeSection::emit` before the instruction is appended.
   - The helper should compute `currentOffset = static_cast<UInt32>(p - b)` using the parser cursor and push it into `code->opcodeOffsets`. Use delta encoding (store `currentOffset - lastOffset`) to minimize size; decoding happens only when formatting diagnostics.
   - Record line starts lazily: when `currentOffset` passes the last cached newline offset, append the new line start index to `code->lineStartOffsets`. This all executes while compiling, keeping runtime cost at zero.
4. **Expose a lookup helper on `Code`.** Implement `Code::lookupSourceLocation(UInt32 instructionIndex, SourceLocation& out)` that:
   - Expands the delta-encoded offset sequence into an absolute offset.
   - Uses `lineStartOffsets` to binary-search the containing line and derive `(line, column)` with constant-time math.
   - Returns `{ fileName, offset, line, column }`, defaulting to `<anonymous>` when metadata is missing (e.g., native host-generated code).

### 2. Snapshot interpreter frames only on exceptional paths
1. **Define a GC-managed stack trace object.**
   - Introduce `struct StackTrace : public GCItem` in `src/NuXJS.h` holding `Vector<FrameEntry>` where each `FrameEntry` contains `const Code* code`, `const CodeWord* ip`, `const String* functionName`, `UInt32 offset`, `int line`, `int column`, and optionally `Object* thisObject`.
   - Provide methods `void appendFrame(const Processor::Frame&, const CodeWord* throwIP)` and `String* format(Heap&) const` for later reuse.
2. **Capture before `reset()`.**
   - Refactor `Processor::throwVirtualException` (`src/NuXJS.cpp:2413-2430`) into two stages:
     1. When `firstCatcher == 0`, call a new `captureStackTrace(exception)` helper that walks `currentFrame` via its `previousFrame` links and appends frames to a freshly allocated `StackTrace` (only when metadata exists). The helper must compute the opcode index with `throwIP = ip - 1` (the faulting instruction), subtracting `code->getCodeWords()`.
     2. Pass the resulting `StackTrace*` and throw-site `SourceLocation` into an updated `ScriptException` constructor before invoking `reset()`.
   - Ensure the helper allocates no vectors when `code->fileName == 0` or `code->opcodeOffsets` is empty so native-only code still stays cheap.
3. **Handle catcher unwinding.** For the caught path (`firstCatcher != 0`), leave behavior untouched to avoid incidental cost. Stack traces are only materialized for uncaught exceptions leaving the VM.

### 3. Surface diagnostics to hosts and JavaScript
1. **Augment `ScriptException`.**
   - Add optional fields (`const StackTrace* trace`, `SourceLocation throwSite`) to the struct definition in `src/NuXJS.h` plus accessors (`getFileName()`, `getLineNumber()`, `getStackTrace()`).
   - Provide a new constructor `ScriptException(Heap&, const Value&, const StackTrace*, const SourceLocation&)` in `src/NuXJS.cpp` that caches the UTF-8 string and stores the metadata pointers (mark them in `gcMarkReferences`).
   - Update both overloads of `ScriptException::throwError` to pass `0` for the metadata so callers who rely on current signatures keep working.
2. **Enrich `Processor::throwVirtualException`.**
   - After capturing the `StackTrace`, detect whether the thrown `Value` is an `Error*` via `value.asError()` and attach:
     - Non-enumerable `fileName` and `lineNumber` properties via `Error::setOwnProperty(..., DONT_ENUM_FLAG | DONT_DELETE_FLAG)`.
     - A cached `stack` string built from `StackTrace::format` that renders `"ErrorName: message\n    at function (file:line:column)"` just like V8/SpiderMonkey.
   - Store the formatted string on the `Error` object to avoid recomputation when script code inspects `error.stack` multiple times.
3. **Expose metadata for non-Error throws.**
   - Add `const char* ScriptException::formatStackTrace()` that lazily allocates and caches the formatted string on demand when `trace != 0`.
   - Provide host-accessible helpers in `Runtime` or a utility header so embedders can grab filenames and lines without reimplementing the formatter.
4. **Compilation errors parity.**
   - When `CompilationError` (`src/NuXJS.h:1828-1836`) wraps a `ScriptException`, copy its `throwSite` so parse-time diagnostics share the same getters.

### 4. Validation and regression coverage
- **Regression harness coverage.** `tests/regression/exceptionDiagnosticsStack.io` flips the `__printExceptionMetadata__` guard before triggering an uncaught `Error`, forcing the CLI to emit `!!!! location`/`!!!! stack` lines just for that script while asserting the canonical `Error: message` header we surface to JavaScript and embedders.
- **Host documentation.** `examples/examples.cpp` now emits the location and formatted stack text alongside the legacy `what()` output so native hosts can see the metadata without reimplementing the formatter.
- **Performance guardrail.** A smoke run of `./output/NuXJS_beta_native benchmarks/minimum.js` completed with the harness reporting `12514` and `52140` microsecond samples, matching the baseline behavior while confirming the metadata plumbing adds no measurable steady-state cost.

## Zero-steady-state-overhead assurances
- All new metadata vectors are filled while compiling; interpreter fetch loops and `Processor::run` remain unchanged.
- Stack traces allocate only when `throwVirtualException` discovers no catcher; the hot-path branch (caught exceptions) performs no extra work.
- Formatting happens lazily on the host boundary, allowing embedders to skip string creation when they only need structured data.

## Work estimate (expanded)
- `Code`/`Compiler` metadata threading: ~180 LOC spanning `src/NuXJS.h`, `src/NuXJS.cpp` (constructor + helpers), and parser emission sites.
- `Processor` stack capture + `StackTrace` GC item: ~140 LOC touching `Processor::throwVirtualException`, new helper functions, and GC marking.
- `ScriptException`/`Error` enrichment + formatting helpers: ~120 LOC across `src/NuXJS.h`, `src/NuXJS.cpp`, and property setup logic.
- Regression tests + docs: ~60 LOC.

All work is localized to `src/NuXJS.{h,cpp}` plus targeted doc/test updates, keeping the change set compact and in line with NuXJS' lightweight style.
