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

- Direct `str` conversion: `str` currently coerces objects via `' '+o`, invoking the object-to-number path. A dedicated opcode could bypass the extra conversion and cut dispatch overhead【F:src/stdlib.js†L130-L131】
- Native `apply`/`call`: `Function.prototype.apply` and `call` are JavaScript wrappers that copy argument arrays before delegating to C++ `callWithArgs`. Implementing them natively would avoid the wrappers and redundant copying【F:src/stdlib.js†L254-L264】【F:src/NuXJS.cpp†L4760-L4784】
- Regular-expression cache: `support.createRegExp` compiles patterns and caches only the generated function, with TODOs about wider caching and eviction. Caching full `RegExp` objects with a size cap would reduce compilation cost and memory churn【F:src/stdlib.js†L1495-L1515】
- String constant lookup: `Runtime::newStringConstantWithHash` compares characters one by one before allocating. A length check followed by a faster byte comparison could shrink time in this routine【F:src/NuXJS.cpp†L5008-L5029】

Reducing time in `GCList::deleteAll`, trimming interpreter dispatch (`Processor::innerRun`), and minimizing stack operations (`Processor::push`, `Processor::pop2push1`) remain broader opportunities for future work.
