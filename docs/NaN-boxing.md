# Exploring a NaN-boxed `Value` Representation

## Goal
Investigate how we could make NaN-boxing an optional representation for `Value`, controlled through preprocessor switches, while preserving the existing tagged-union layout as the default build.

## Implementation Plan
- [x] Introduce the `NUXJS_USE_NAN_BOXING` feature flag and wrap the current `Value` definition so the legacy layout remains the default build (see [Compile-time Toggle Strategy](#compile-time-toggle-strategy)).
- [x] Define the NaN-boxed bit layout, tag assignments, and helper constructors that encode/decode the payload (`Value::fromPointer`, `payload()`, etc.) as outlined in [NaN-boxing Concept](#nan-boxing-concept) and [Tag and Payload Design](#tag-and-payload-design).
- [x] Replace direct `type`/`var` reads with inline accessors, updating property bucket storage to keep either the union or raw 64-bit payload depending on the flag (see [API Adjustments Needed](#api-adjustments-needed)).
- [x] Extend the garbage collector integration to use the new helpers for marking pointer payloads, keeping heap alignment guarantees in mind (see [Garbage Collector Integration](#garbage-collector-integration)).
- [x] Update debugging utilities, assertions, and diagnostic helpers so they surface the decoded type under both layouts (see [Debugging and Tooling Considerations](#debugging-and-tooling-considerations)).
- [x] Expand automated coverage by running `./build.sh` with and without the flag and adding targeted regression tests for pointer-heavy scenarios (see [Testing Plan](#testing-plan)).
  - `build.sh` now executes the beta/release matrix once for NaN-boxed builds and once for the legacy layout so CI automatically exercises both.
  - Added `tests/regression/nanBoxingPointerRetention20250215.io` to stress property tables full of pointer payloads across GC cycles.
- [x] Resolve the open questions by gating the feature behind 64-bit hosts, deciding on SMI handling, and benchmarking representative workloads (see [Open Questions & Follow-up](#open-questions--follow-up)).
  - Added a compile-time guard that refuses `NUXJS_USE_NAN_BOXING` builds unless `uintptr_t` is 64 bits so the payload math stays valid on host toolchains.
  - Chose to keep integers encoded as canonical IEEE-754 doubles (no SMI lane) to avoid layout divergences between builds; `encodeNumber` documents the policy for future tuning.
  - Timed representative property-heavy scripts with `time ./output/NuXJS benchmarks/...` and `time ./output/NuXJS_nan benchmarks/...` to capture the current performance delta; the NaN-boxed layout lags the legacy encoding on both hash-table churn and large object creation (see [Benchmark Snapshot](#benchmark-snapshot)).

## Current Layout Summary
- `Value` stores an explicit `Type` discriminator alongside a `Variant` union that contains either primitive payloads or pointers to heap-managed data.【F:src/NuXJS.h†L363-L420】
- Property buckets embed the `Value::Variant` payload directly and cache the tag in a single byte, allowing fast property lookups without heap indirection.【F:src/NuXJS.h†L421-L455】【F:src/NuXJS.cpp†L1405-L1436】
- Conversion helpers and equality operators assume that the discriminant is available without decoding; they switch on `type` and then touch the matching field inside `var` (for example, `toDouble`, `compareStrictly`, and `gcMarkReferences`).【F:src/NuXJS.cpp†L732-L916】【F:src/NuXJS.cpp†L1431-L1466】

## NaN-boxing Concept
- A 64-bit IEEE-754 quiet NaN leaves the payload bits unused for arithmetic. We can reserve specific payload patterns to encode type tags and inline data while treating canonical numeric doubles as themselves.
- A typical layout uses the high 16 bits of a quiet NaN to hold a tag, with the low 48 bits storing either immediate data (booleans, small integers) or a pointer. On x64, heap allocations are pointer-aligned so the low bits are predictable, making pointer tagging feasible.
- NaN-boxing keeps numeric doubles fast (no decoding needed) and shrinks the `Value` footprint to a single 64-bit word, potentially improving cache density and avoiding the extra byte we currently store for `type` in each property bucket.

## Compile-time Toggle Strategy
- Introduce a build flag (for example `NUXJS_USE_NAN_BOXING`) that selects between the current tagged union and a NaN-boxed storage type.
- Wrap the definition of `Type`, `Variant`, and any direct field exposures inside `#if !defined(NUXJS_USE_NAN_BOXING)` to keep the existing implementation untouched when the flag is not defined.
- Under the flag, replace the `type` and `Variant var` members with a single `UInt64 bits;` backed by helper functions that interpret the payload. Constructors become thin wrappers that encode the appropriate tag pattern.
- Provide static inline helpers such as `static Value fromPointer(ValueTag, void*)`, `static bool isPointerTag(ValueTag)`, and `UInt64 payload() const` so that other compilation units do not need to understand the raw encoding.

## Tag and Payload Design
- Reserve one tag (`0x0000`) for canonical doubles so that all non-NaN numbers simply store their IEEE encoding. Special numbers (`+/-inf`, `NaN`) already carry NaN patterns and can be normalized in constructors.
- Assign dedicated tags to the remaining `Value::Type` domain: `undefined`, `null`, `boolean`, `string pointer`, and `object pointer`. Because booleans fit in a single bit, we can dedicate one payload bit for `true/false` and zero-fill the rest.
- The existing `Value::NOT_A_NUMBER` and `Value::INFINITE_NUMBER` constants should continue to work by manufacturing the same bit patterns as ECMAScript expects.

## API Adjustments Needed
- Replace every direct read of `type` or `var.*` with inline accessors (`getType()`, `getNumberUnchecked()`, `getObjectUnchecked()`, etc.) that dispatch appropriately under both layouts. Most callers already go through helper methods like `isNumber()`, `getObject()`, and `toDouble()`, so the refactor is localized to a few hot methods.【F:src/NuXJS.cpp†L732-L916】
- Ensure that `Table::Bucket` stores the raw 64-bit payload when NaN-boxing is active. One approach is to make `Bucket` keep a `ValueStorage` union containing either `Value::Variant` (legacy) or `UInt64 nanBits` (NaN-boxed), guarded by the same `#ifdef`.
- Update `Table::update`, `Table::gcMarkReferences`, and any other friend functions so they use the new helper accessors rather than touching `value.type` or `value.var` directly.【F:src/NuXJS.cpp†L1405-L1466】
- Adjust `Value::TYPE_STRINGS` and comparison helpers to rely on the decoded tag rather than the raw enum. We can still expose the existing `Value::Type` enumeration as a logical tag so that the public API remains unchanged; only its physical storage differs.

## Garbage Collector Integration
- The GC currently examines property buckets and the `Value` union to mark reachable strings and objects. Under NaN-boxing, introduce `Value::needsGCMarking()` and `Value::gcMarkPayload(Heap&)` helpers that unpack pointer payloads based on the encoded tag, and use them from both the generic `gcMark` friend and the hash-table traversal.【F:src/NuXJS.cpp†L1431-L1466】
- Because pointers are stored in the lower 48 bits, ensure that heap allocations maintain the expected alignment and that pointer compression/decompression routines mask out tag bits safely.

## Debugging and Tooling Considerations
- Preserve the existing `#ifndef NDEBUG` guard that initializes `type` to `BAD_TYPE` by setting a recognizable NaN pattern (for example, an impossible tag like `0xFFFF`) in debug builds when the default constructor runs.
- Extend logging and pretty-printers so that `operator<<` and any diagnostic dumps display the decoded type; this prevents regressions when debugging mixed builds.
- Add assertions verifying that `sizeof(Value) == 8` and that `sizeof(Table::Bucket)` decreases or stays constant to catch packing surprises early.

## Testing Plan
- Reuse the existing `./build.sh` integration script; it already exercises both beta and release builds and will automatically compile both code paths when the new flag is toggled. We should run CI with and without `NUXJS_USE_NAN_BOXING` defined to guarantee parity between layouts.
- Introduce targeted unit tests (or scripted regression tests) that allocate objects and strings, mutate property tables, and validate that values survive GC cycles identically under both representations.

## Open Questions & Follow-up
- The compile-time gating and initial benchmark sampling above close out the portability and measurement items, leaving the SMI experiment as a future tuning lever should the cache locality wins outweigh the bit-twiddling cost.

## Benchmark Snapshot

| Benchmark | Legacy `NuXJS` (s) | NaN-boxed `NuXJS` (s) |
| --- | --- | --- |
| `hash_bm_1.js` (3-run avg) | 4.21 | 5.69 |
| `bigObject.js` (2-run avg) | 6.67 | 7.22 |

*Methodology:* each run used the shell `time` builtin to execute the release binaries with output redirected to `/dev/null`. The table records the mean of the runs captured above; raw timings are preserved in the shell transcripts for traceability.
- Confirm that all supported targets are 64-bit; if not, gate the NaN-boxed option behind a `sizeof(void*) == 8` static assertion to avoid undefined behavior on 32-bit builds.
- Evaluate whether we want to special-case small integers (SMIs) inside the NaN payload or keep them as doubles; extra encodings can improve performance but complicate the decoder.
- Benchmark property-heavy workloads under both modes to ensure that the change delivers the intended memory/cache benefits without regressing arithmetic throughput.
