# Incremental Garbage Collector Plan

## Convert `Heap::gc` into an incremental API
 - [x] Define `enum class GCPhase { Idle, MarkRoots, MarkNews, Sweep };` in `src/NuXJS.h`.
- [x] Add fields `gcPhase` and `markIt` to `class Heap`.
- [x] Change `Heap::gc` signature to `bool gc(int maxIterations = -1)`.
 - [x] Initialize a new cycle by setting `gcPhase` to `MarkRoots` and `markIt` to the head of `rootList`.
 - [x] Mark root list then `newList`, each step processing up to `maxIterations` objects and moving marked items to `newList`.
 - [x] After marking completes, swap lists and switch `gcPhase` to `Sweep`.
 - [x] Sweep phase: reclaim up to `maxIterations` unreachable nodes from `currentList` using `sweep`.
- [x] After both lists are empty, reset GC state and return `false`; otherwise return `true`.
- [x] Treat `maxIterations == -1` as running until the current phase completes.

## Implement partial `GCList` sweeping
- [x] Replace separate `GCList` deletion helpers with a single `bool sweep(std::size_t maxItems = std::numeric_limits<std::size_t>::max());`.
- [x] Use `sweep` in `src/NuXJS.cpp` to remove up to `maxItems` nodes from the head and return whether nodes remain.
- [x] Call `sweep` with default parameter to clear whole lists where needed.

## Expose incremental GC to the host
- [x] Add `bool Runtime::gc(int maxIterations = -1)` that forwards to `Heap::gc`.
- [x] Add zero-argument `void Runtime::gc()` that loops calling `gc()` with `checkTimeOut()` until the cycle finishes.
- [x] Update `Runtime::autoGC` to invoke the zero-argument `gc()` and let hosts drive further progress via `gc(maxIterations)` while the VM is paused.

## Provide a GC reset mechanism
- [x] Add `void Heap::gcReset()` to splice `newList` back into `currentList`, clear phase information, and null iterators.
- [x] Add `void Runtime::gcReset()` that forwards to the heap reset and ensures the VM is paused if GC was running.
- [x] Document that `gcReset` must be called after aborting GC before starting a new cycle.

## Document step-based garbage collection
- [x] Update `docs/NuXJS Documentation.md` with instructions for incremental GC and the reset API.
- [x] Include an example: `while (runtime.gc(1000)) { /* check timeout or run other VMs */ }`.
- [x] Explain the zero-argument `Runtime::gc()` helper and emphasize that GC must finish before VM execution resumes.

