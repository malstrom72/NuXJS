# Source Code Unit Refactor Plan

## Background
- `Code` currently stores the script `String`, optional file name, and `lineStartOffsets` inline (under `NUXJS_VERBOSE_EXCEPTIONS`). The compiler fills `lineStartOffsets` with byte offsets relative to the current parse window so `Code::lookupSourceLocation()` can translate `opcodeOffsets` back to line/column pairs.
- `Compiler` tracks the active source window via raw pointers (`b`, `p`, `e`) and keeps a `lineScanOffset` cursor while it appends to `code->lineStartOffsets`. Nested function compilation reuses the outer compiler's absolute pointers to approximate the correct base line.
- Offsets inside `CodeSection::emit()` are stored relative to the section's local begin pointer even though we later concatenate sections into the final `code->opcodeOffsets` vector.

## Goals
1. Introduce a dedicated `SourceCodeUnit` GC item that owns the source `String`, file name, and compact line-start table, plus a helper to map byte offsets to line/column.
2. Ensure every compilation creates (or reuses) a `SourceCodeUnit`, and pass the desired file name (`<anonymous>`, `<eval>`, etc.) into the `Compiler` up front. Outline the constructors/factories we will rely on (e.g. helpers for anonymous, eval, and explicit filenames) so each call site can select the correct label consistently.
3. Update `Code`, `Compiler`, and runtime helpers to consult the `SourceCodeUnit` instead of embedding source metadata directly. Remove `Code::lineStartOffsets` entirely.
4. Guarantee `opcodeOffsets` are measured against the associated `SourceCodeUnit` so tracebacks remain accurate after section concatenation.

## Milestone 1 – Define the `SourceCodeUnit` GC object
- [x] Declare `class SourceCodeUnit : public GCItem` in `src/NuXJS.h` near the existing `Code` definition, and implement its methods in `src/NuXJS.cpp`.
  - [x] Fields: `const String* source`, `const String* fileName`, and (under `#if NUXJS_VERBOSE_EXCEPTIONS`) `Vector<UInt32> lineStartOffsets` seeded with zero so column math works immediately.
  - [x] Provide minimal accessors: `const String* getSource() const`, `void setSource(const String*)`, `const String* getFileName() const`, and `void setFileName(const String*)`. The file name defaults to `ANONYMOUS_SCRIPT_STRING` when unset.
  - [x] Add newline tracking helpers that mirror the current compiler logic without altering caller responsibilities: `void beginLineScan()` clears the optional table and pushes zero when verbose exceptions are enabled, `void recordLineProgress(const Char* basePtr, UInt32 fromOffset, UInt32 toOffset)` appends offsets for each detected newline, and both functions become no-ops when the feature flag is disabled.
  - [x] Implement `bool computeLineColumn(UInt32 offset, int& line, int& column) const` using `std::upper_bound` over `lineStartOffsets`; return `false` when verbose data is unavailable so callers can fall back to their legacy approximations.
  - [x] Override `gcMarkReferences` to mark `source` and `fileName`.
  - [x] Provide static helpers such as `SourceCodeUnit::createWithName(Runtime&, const String* source, const String* name)`, `createAnonymous(Runtime&, const String* source)`, and `createEval(Runtime&, const String* source)` so the compiler sites in later milestones have explicit construction entry points.
- [x] Keep the rest of the system compiling by leaving all `Code` and `Compiler` call sites untouched; temporary adapters (e.g. factory functions that simply wrap existing `String*` values) ensure the new file compiles even before consumers switch over.
- [x] ✅ `timeout 180 ./build.sh`

## Milestone 2 – Attach `SourceCodeUnit` to `Code`
- [x] Add a `SourceCodeUnit* sourceUnit` member to `Code`, initialized to `0`, while retaining the existing `const String* source` slot so closures or runtime-created functions can still carry bespoke sources during the transition.
- [x] Expose `SourceCodeUnit* getSourceUnit() const` and ensure `Code::getSource()` first consults the unit before falling back to the legacy pointer. Keep the source-unit pointer write-once by wiring it through the constructor and dedicated initialization helpers—no generic `setSourceUnit()` mutator is needed.
- [x] Remove `fileName`, `lineStartOffsets`, and any line-number base fields from `Code`; line metadata now lives exclusively in the unit under `NUXJS_VERBOSE_EXCEPTIONS`.
- [x] Update the constructor to drop the legacy `lineStartOffsets.push(0)` block and to accept an optional `SourceCodeUnit*` parameter used during code creation.
- [x] Adjust `gcMarkReferences` to mark both `sourceUnit` and the retained `source` pointer.
- [x] Update `lookupSourceLocation()` to rely on the unit for file/line/column data, replacing today’s early-outs with internal `NUX_ASSERT(sourceUnit)` checks so missing metadata is treated as a bug rather than silently ignored.
- [x] Bridge the gap by keeping the old helper methods (e.g. `getFileName()`) temporarily delegating to the unit while we migrate call sites in later milestones.
- [x] ✅ `timeout 180 ./build.sh`

## Milestone 3 – Thread the unit through the compiler
- [x] Extend the `Compiler` constructor signature to accept a `SourceCodeUnit*` (store it in a new `sourceUnit` member). Every call site will supply a freshly allocated instance (see Milestone 4).
- [x] Inside the constructor, assign the supplied unit to the target `Code` (if not already set) and store the provided file name directly in the unit. Keep `baseLineNumber` on the compiler object; the unit remains agnostic to per-compilation offsets.
- [x] Replace `Compiler`’s newline scanning helpers so they delegate to `SourceCodeUnit::recordLineProgress()` while continuing to append monotonically for nested functions; nested compilers inherit the parent’s absolute offsets without clearing the accumulated table.
- [x] Update `getStopPosition()` and similar helpers to ask the unit for filename and line/column data instead of peeking at removed `Code` fields.
- [x] When building a function’s source `String` at the end of `compileFunction()`, call `sourceUnit->setSource(...)` instead of writing to `code->source` directly.
- [x] Maintain compatibility by leaving any still-migrating runtime helpers in place (they continue to consult `Code::getSource()` which now bridges through the unit).
- [x] ✅ `timeout 180 ./build.sh`

## Milestone 4 – Create source units at every compilation site
- [x] `Runtime::compileGlobalCode`: allocate a unit via `SourceCodeUnit::createWithName(runtime, &source, filenameOrAnonymous)` before building the compiler and thread it through the new constructor.
- [x] `Runtime::compileEvalCode`: allocate a unit via `createEval` (tagged with `&EVAL_CODE_STRING` and the incoming expression `String*`). Cache the `Code` together with its unit so repeated eval lookups reuse the existing metadata.
- [x] `Runtime::compileFunction` built-in: allocate a unit with `<anonymous>` as file name (via `createAnonymous`) before constructing the compiler.
- [x] `Compiler::functionDefinition` (nested functions): pass the parent’s unit to the nested compiler so nested functions append directly to the shared line table. When computing the nested `baseLineNumber`, keep it on the nested compiler instance; the unit itself remains agnostic to base lines.
- [x] Ensure each of these pathways wires the unit into the new `Code` constructor so opcode offsets remain anchored to the correct unit.
- [x] Remove temporary adapters introduced in Milestone 1 once all call sites are updated.
- [x] ✅ `timeout 180 ./build.sh`

## Milestone 5 – Update consumers of source metadata
- [x] `JSFunction::toString()` should call `code->getSource()` which now prefers the unit but falls back to the direct `Code::source` pointer for legacy cases.
- [x] `Processor::collectStackFrames()` and other traceback helpers must fetch filenames and line info through `SourceCodeUnit`. Guard against null units so we retain the previous early-out behavior when metadata is intentionally missing.
- [x] `CompilationError` and any other place calling `code->getLineNumberBase()`/`setLineNumberBase()` should migrate to asking the compiler or `SourceCodeUnit` as appropriate; ensure nested function setup writes base lines to the compiler rather than a unit field.
- [x] Sweep the codebase for references to `code->lineStartOffsets` or direct line metadata and replace them with unit-based lookups.
- [x] ✅ `timeout 180 ./build.sh`

## Milestone 6 – Housekeeping & validation
- [x] Delete any lingering transitional helpers and confirm conditional compilation (`NUXJS_VERBOSE_EXCEPTIONS`, `NUXJS_RLE_OFFSETS`) still wraps the opcode-offset logic correctly.
- [x] Verify `opcodeOffsetRuns`/`opcodeOffsets` continue to store offsets produced by `recordSourceOffset()` (now sourced from the unit), so they remain aligned with the unit’s byte offsets.
- [x] Refresh comments and documentation to note that opcode offsets are measured against the owning `SourceCodeUnit` and that `Code::source` mirrors the unit for full-script code objects.
- [x] ✅ `timeout 180 ./build.sh`
