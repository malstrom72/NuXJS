# Exception Diagnostics Implementation Milestones

- [x] **Milestone 1 – Preserve JavaScript source identity through compilation**
  - [x] Extend `class Code` in `src/NuXJS.h` with `const String* fileName`, delta-encoded `Vector<UInt32> opcodeOffsets`, and cached `Vector<UInt32> lineStartOffsets`; update `Code::Code` and `Code::gcMarkReferences` in `src/NuXJS.cpp` to initialize/mark them.
  - [x] Set `code->fileName` inside `Runtime::compileGlobalCode` (`src/NuXJS.cpp:5154-5181`) and `Runtime::compileEvalCode` (`src/NuXJS.cpp:5204-5227`) so every compiled script has a name (`"<eval>"` for eval).
  - [x] Propagate filenames to nested functions in `Compiler::functionDefinition` (`src/NuXJS.cpp:4550-4598`) and capture source offsets from `Compiler::CodeSection::emit` via a new `recordSourceLocation` helper.
  - [x] Implement `Code::lookupSourceLocation(UInt32 instructionIndex, SourceLocation& out)` that resolves `instructionIndex` to `(file, offset, line, column)` using the stored tables.
  - [x] _Completion requires a successful `timeout 180 ./build.sh` run._

- [x] **Milestone 2 – Snapshot interpreter frames only when exceptions escape**
  - [x] Introduce `struct SourceLocation` and `struct StackTrace` (GC-managed) in `src/NuXJS.h` plus supporting vectors for captured frames.
  - [x] Teach `Processor::throwVirtualException` (`src/NuXJS.cpp`) to call a new `captureStackTrace` helper before `reset()` when `firstCatcher == 0`; the helper walks `Processor::Frame::previousFrame`, computes opcode indices from `(ip - code->getCodeWords())`, and queries `Code::lookupSourceLocation`.
  - [x] Guarantee zero steady-state overhead by short-circuiting when `code->getFileName() == 0` or metadata vectors are empty, and keep the caught-exception branch untouched.
  - [x] _Completion requires a successful `timeout 180 ./build.sh` run._

- [x] **Milestone 3 – Surface file, line, column, and canonical stacks on observable exceptions**
  - [x] Extend `ScriptException` in `src/NuXJS.h`/`src/NuXJS.cpp` with metadata fields, new constructors, and accessors (`getFileName()`, `getLineNumber()`, `getStackTrace()`), plus a formatter that emits the `ErrorName: message\n    at …` layout.
  - [x] Update both overloads of `ScriptException::throwError` to pass `nullptr` metadata while keeping the current signatures available to callers.
  - [x] When the thrown value is an `Error`, set non-enumerable `fileName`, `lineNumber`, and `stack` properties inside `Processor::throwVirtualException` using `Error::setOwnProperty`, caching the formatted stack string on the object.
  - [x] Ensure `CompilationError` copies `ScriptException` metadata so parse-time failures match runtime exceptions.
  - [x] _Completion requires a successful `timeout 180 ./build.sh` run._

- [x] **Milestone 4 – Update host APIs, documentation, and regression coverage**
  - [x] Add regression JS in `tests/regression/` that exercises nested throws and validates `error.stack` plus `fileName/lineNumber` via the CLI harness.
  - [x] Refresh embedding guidance (e.g., `examples/`, `docs/`) to demonstrate `ScriptException::formatStackTrace()` and filename accessors for native hosts.
  - [x] Run `benchmarks/` smoke tests to confirm there is no steady-state regression and capture numbers in the release notes.
  - [x] _Completion requires a successful `timeout 180 ./build.sh` run._
