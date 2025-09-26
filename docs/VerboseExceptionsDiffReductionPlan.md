# NuXJS Verbose Exceptions – Inline Diff Reduction Plan

This roadmap focuses on shrinking the **inline** code that lives behind
`#if (NUXJS_VERBOSE_EXCEPTIONS)` inside `NuXJS.cpp` and `NuXJS.h`. The goal is
that the verbose build adds as little extra source as possible **without**
moving logic to helper translation units.

## Checklist roadmap
- [x] **Measure the current inline footprint.**
- [x] Diff `NuXJS.cpp` and `NuXJS.h` against `main` and record every guarded
  block, its size in lines, and which runtime phase it touches.
- [x] Tag each block with the user-facing value it provides so we can delete or
  merge redundant helpers.

| File | Guarded block range | Lines | Runtime phase | Notes |
| --- | --- | ---: | --- | --- |
| `NuXJS.cpp` | 194-199 | 4 | Boot | Builds verbose-only `kVerboseOptions` flag wiring. |
|  | 1598-1612 | 13 | Parser | Verbose parser diagnostics helpers. |
|  | 1621-1623 | 1 | Parser | Parser guard for verbose tracing toggle. |
|  | 1637-1675 | 37 | Parser | Parser error-string enrichment helpers. |
|  | 2177-2252 | 74 | Runtime | `ScriptException` verbose constructor logic. |
|  | 2257-2261 | 3 | Runtime | Verbose metadata stub. |
|  | 2270-2273 | 2 | Runtime | Verbose metadata accessor glue. |
|  | 2275-2277 | 1 | Runtime | Verbose metadata accessor glue. |
|  | 2280-2337 | 56 | Runtime | Verbose stack capture helpers. |
|  | 2623-2728 | 104 | Runtime | Verbose throw helpers and stack emitters. |
|  | 3074-3085 | 10 | Runtime | Verbose metadata reuse inside executor. |
|  | 3256-3258 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3273-3277 | 3 | Runtime | Verbose inline guard for debugger branch. |
|  | 3284-3288 | 3 | Runtime | Verbose inline guard for debugger branch. |
|  | 3301-3303 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3305-3310 | 4 | Runtime | Verbose inline guard for debugger branch. |
|  | 3318-3324 | 5 | Runtime | Verbose inline guard for debugger branch. |
|  | 3327-3329 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3334-3336 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3338-3340 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3348-3350 | 1 | Runtime | Verbose inline guard for debugger branch. |
|  | 3359-3363 | 3 | Runtime | Verbose inline guard for debugger branch. |
|  | 3439-3463 | 23 | Runtime | Verbose handler formatting for host callbacks. |
|  | 4099-4101 | 1 | Runtime | Verbose inline guard for host callback glue. |
|  | 4898-4905 | 6 | Runtime | Verbose inline guard for REPL scaffolding. |
|  | 4928-4949 | 20 | Runtime | Verbose inline guard for REPL stack printing. |
|  | 5533-5535 | 1 | Runtime | Verbose inline guard for test harness glue. |
|  | 5545-5547 | 1 | Runtime | Verbose inline guard for test harness glue. |
| `NuXJS.h` | 822-824 | 1 | Boot | Verbose configuration flag. |
|  | 843-848 | 4 | Parser | Verbose parser signature. |
|  | 861-865 | 3 | Parser | Verbose parser signature. |
|  | 877-879 | 1 | Parser | Verbose parser signature. |
|  | 1231-1271 | 39 | Runtime | Verbose `ScriptException` data payload. |
|  | 1273-1275 | 1 | Runtime | Verbose accessor stub. |
|  | 1280-1284 | 3 | Runtime | Verbose accessor stub. |
|  | 1287-1295 | 7 | Runtime | Verbose accessor stub. |
|  | 1298-1304 | 5 | Runtime | Verbose accessor stub. |
|  | 1306-1309 | 2 | Runtime | Verbose accessor stub. |
|  | 1697-1699 | 1 | Runtime | Verbose metadata toggle. |
|  | 1756-1758 | 1 | Runtime | Verbose metadata toggle. |
|  | 1808-1812 | 3 | Runtime | Verbose metadata toggle. |
|  | 1814-1818 | 3 | Runtime | Verbose metadata toggle. |
|  | 1822-1824 | 1 | Runtime | Verbose metadata toggle. |
|  | 1910-1912 | 1 | Runtime | Verbose metadata toggle. |
|  | 1926-1928 | 1 | Runtime | Verbose metadata toggle. |
|  | 1944-1951 | 6 | Runtime | Verbose metadata toggle. |

Baseline totals: 381 guarded lines in `NuXJS.cpp`, 83 guarded lines in `NuXJS.h` (464 combined).

Current totals after consolidating `CodeSection::emit` and trimming inline guard
logic: 351 guarded lines in `NuXJS.cpp`, 79 guarded lines in `NuXJS.h` (430
combined).

Current totals after sharing the runtime throw helpers and catch plumbing
between verbose and non-verbose builds: 353 guarded lines in `NuXJS.cpp`, 94
guarded lines in `NuXJS.h` (447 combined). *(Measured by counting lines nested
under `#if (NUXJS_VERBOSE_EXCEPTIONS)` in each file; totals grew slightly
because the shared declarations now live outside the guards while their
implementations still reference the verbose structures.)*

Current totals after centralizing `ScriptException` metadata updates and
reusing them from `Processor::throwVirtualException`: 320 guarded lines in
`NuXJS.cpp`, 79 guarded lines in `NuXJS.h` (399 combined).

Current totals after inlining verbose metadata capture (removing the GC-backed
`StackTrace` helper and caching formatted stacks directly on the exception):
300 guarded lines in `NuXJS.cpp`, 60 guarded lines in `NuXJS.h` (360 combined).

Current totals after letting `VerboseExceptionMetadata` own its `SourceLocation`
and dropping the duplicate `ScriptException::throwLocation` field: 285 guarded
lines in `NuXJS.cpp`, 52 guarded lines in `NuXJS.h` (337 combined).

Current totals after removing the `hasStack` field, relying on the shared
location fallback, and switching stack-number formatting to `std::to_string`:
284 guarded lines in `NuXJS.cpp`, 68 guarded lines in `NuXJS.h` (352 combined).

Current totals after factoring shared verbose-source checks and location
formatting helpers into `NuXJS.cpp` and dropping the metadata `clear()` helper:
271 guarded lines in `NuXJS.cpp`, 46 guarded lines in `NuXJS.h` (317 combined).

Current totals after storing captured frames and formatting verbose stacks on
demand from a shared helper: 282 guarded lines in `NuXJS.cpp`, 54 guarded lines
in `NuXJS.h` (336 combined).

- [x] **Strip redundant helpers in place.**
- [x] Convert verbose-only helper functions into shared utilities that already
  exist in the same file, wrapping them in a single `#if` branch rather than
  duplicating bodies. *(Example: `Compiler::CodeSection::emit` now uses a shared
  signature with internal guards instead of maintaining duplicate definitions.)*
- [x] Collapse the verbose `ScriptException` metadata initialization into a
  shared helper so both the constructor and `Processor::throwVirtualException`
  reuse the same short block instead of maintaining parallel assignments.
- [x] Replace bespoke string/metadata assemblers with calls to the existing
  formatting helpers that non-verbose builds already use.
- [x] Delete dead declarations in `NuXJS.h` that only forward to verbose
  implementations when the functionality can be achieved by extending the
  existing non-verbose signatures.

- [x] **Collapse guard density.**
- [x] Prefer extending an existing code path with short `if (verbose)` clauses
  over wrapping entire duplicate functions in `#if`/`#endif` so the diff is a
  handful of lines instead of full redefinitions.
- [x] When a branch truly needs verbose-only work, keep the guarded payload to
  a short lambda or `switch` arm that fits on ~5 statements.

- [x] **Reuse metadata structures without relocating them.**
- [x] Audit verbose-only structs/classes declared in `NuXJS.h` and either
  delete them or merge their fields into the existing exception objects so
  no parallel hierarchies remain.
- [x] Push transient data (formatted stack strings, source snippets) to be
  computed on demand, letting us remove cached buffers that bloat the inline
  diff.

- [x] **Keep docs and metrics honest.**
- [x] Record the before/after guarded line counts directly in this file after
  each refactor so the impact is visible without chasing other includes.
- [x] Track any helpers that still feel verbose-heavy and note follow-up
  actions before merging. *(Parser diagnostics at lines 1637-1675 remain the
  largest guarded block; a follow-up can inline more of that logic once the
  runtime changes settle.)*

## Success metrics
- [ ] Total lines inside `#if (NUXJS_VERBOSE_EXCEPTIONS)` across `NuXJS.cpp` and
      `NuXJS.h` stay under the agreed ceiling (e.g., 500 LOC).
- [ ] No verbose functionality requires additional `.h`/`.cpp` files—the feature
      lives entirely inside the primary translation unit and header.
- [ ] Every change in verbose mode either replaces an existing line or adds a
      net of fewer than ~10 lines for the feature.
