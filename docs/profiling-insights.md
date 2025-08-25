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
- `bigObject.js`: Heap management (`Heap::gc`, `GCList::deleteAll`) and property enumeration (`StringListEnumerator::nextPropertyName`) dominate runtime.
- `buildStringNaive.js`: Naive concatenation spends over 60% of time in `StringListEnumerator::nextPropertyName` and significant time marking table entries.
- `buildStringBuffered.js`: Even with buffering, property enumeration and frequent heap calculations (`Heap::calcPoolIndex`, `Processor::innerRun`) remain hot.

Across benchmarks, interpreter dispatch, memory allocation/garbage collection, and string or hash-table operations are recurring bottlenecks.

## Engine Comparison

Benchmark results (lower is better) from an external comparison suite:

| Benchmark | NuXJS | Duktape | QuickJS |
|-----------|------:|-------:|--------:|
| bigArray.js | 961 | 1400 | 981 |
| bigObject.js | 2378 | 1840 | 1003 |
| buildStringBuffered.js | 294 | 383 | 252 |
| buildStringNaive.js | 319 | 109 | 44 |
| chess_bm.js | 4458 | 5649 | 1661 |
| regexp.js | 3380 | 386 | 219 |
| string_bm_2.js | 761 | 753 | 223 |
| ... | ... | ... | ... |

These numbers show NuXJS generally lags behind QuickJS and often Duktape on string handling (`buildStringNaive.js`, `regexp.js`) and object-heavy workloads (`bigObject.js`).
