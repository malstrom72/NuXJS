# Profiling and Optimization Findings

## Profiling Overview

NuXJS was built with `-pg` and profiled with gprof across several benchmarks.

## Benchmark Hotspots

- `gc_bm_1.js`: Garbage collection dominates, with ~20% of time freeing objects (`GCList::deleteAll`).
- `regexp.js`: Frequent allocations trigger cleanup (`GCList::deleteAll` 27%), followed by dispatch (`Processor::innerRun` 11%) and heap allocation (`Heap::allocate` 10%).
- `hash_bm_1.js`: Interpreter dispatch (`Processor::innerRun` 17%), table lookups (`Table::find` 15%), and hashing (`String::calcHash` 9%) are primary costs.
- `string_bm_2.js`: Dispatch leads (13%), while property access and table searches consume ~9%.
- `recursion_bm_1.js`: Call overhead is prominent with dispatch (17%) and stack operations (`Processor::push`, `Processor::pop2push1`).
- `for_loop_bm_1.js`: `Processor::innerRun` accounts for ~64% of runtime, with notable overhead from number conversions (`Value::toDouble`) and stack manipulation (`Processor::push`).
- `math_bm_1.js`: Dispatch remains heavy (~44%), followed by `Value::toDouble`, `Processor::pop2push1`, and allocation/GC routines.

Across benchmarks, interpreter dispatch, memory allocation/garbage collection, and string or hash-table operations are recurring bottlenecks.

## Low-Hanging Optimization Ideas

- Streamline garbage-collector cleanup by reducing time spent in `GCList::deleteAll`.
- Cut dispatch overhead in `Processor::innerRun`, potentially via direct threading or other interpreter-loop optimizations.
- Improve hash-table lookups and string hashing to shrink time in `Table::find` and `String::calcHash`.
- Minimize stack manipulation in tight loops or recursion to lessen work in `Processor::push` and `Processor::pop2push1`.
