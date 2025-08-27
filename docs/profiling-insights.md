# Profiling and Optimization Findings

## Profiling Overview

NuXJS was built with `-pg` and profiled with gprof across several benchmarks.

## Benchmarking workflow

Before committing any performance change, run the entire benchmark suite and compare results against a baseline.

```bash
# build the runtime
timeout 180 ./build.sh
# capture baseline numbers
tools/benchmark.pika benchmarks output/NuXJS > before.txt
# after making changes, rebuild and rerun
timeout 180 ./build.sh
tools/benchmark.pika benchmarks output/NuXJS > after.txt
# compare results (lower is better)
diff -u before.txt after.txt
```

Each entry shows the median of several runs; the script also prints a **median of all tests** at the end.  **Every per-test median and the overall median must drop** after an optimization. If the new build fails to outperform the baseline, revert the change.


## Benchmark Profiles

### GC sweep optimization results

Running the full benchmark suite with three iterations per test showed the garbage‑collector sweep improvement reduces `gc_bm_1.js` median time from **1.58002 s** to **1.48854 s** while leaving other benchmarks within noise.

### gc_bm_1.js
| % time | Function |
|------:|----------------------------------|
|15.38|NuXJS::Table::gcMarkReferences(NuXJS::Heap&) const|
|9.05|NuXJS::StringListEnumerator::nextPropertyName()|
|7.69|NuXJS::GCList::relinquish(NuXJS::GCItem*)|
|6.79|NuXJS::Processor::innerRun()|
|6.33|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|6.33|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|
|4.07|NuXJS::Heap::gc()|
|3.85|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::~Vector()|
|2.94|NuXJS::String::fromInt(NuXJS::Heap&, int)|
|2.71|NuXJS::Table::lookup(NuXJS::String const*)|


### regexp.js
| % time | Function |
|------:|----------------------------------|
|20.67|NuXJS::Processor::innerRun()|
|15.10|NuXJS::GCList::deleteAll()|
|11.63|NuXJS::StringListEnumerator::nextPropertyName()|
|6.44|NuXJS::Heap::allocate(unsigned long)|
|2.48|NuXJS::Heap::free(void*)|
|2.48|NuXJS::FunctionScope::FunctionScope(NuXJS::GCList&, NuXJS::JSFunction*, unsigned int, NuXJS::Value const*)|
|2.48|NuXJS::Heap::gc()|
|2.23|NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const|
|1.98|NuXJS::GCItem::operator delete(void*)|
|1.86|NuXJS::Heap::drain()|

### hash_bm_1.js
| % time | Function |
|------:|--------------------------------|
|14.08|NuXJS::Processor::innerRun()|
|8.80|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|6.69|NuXJS::String::calcHash() const|
|6.51|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::operator[](long)|
|5.99|NuXJS::Table::lookup(NuXJS::String const*)|
|4.75|NuXJS::Table::Bucket::valueExists() const|
|4.58|NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|4.05|NuXJS::JSObject::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|3.52|NuXJS::JSArray::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|3.35|NuXJS::Value::toDouble() const|

### string_bm_2.js
| % time | Function |
|------:|--------------------------------|
|16.81|NuXJS::StringListEnumerator::nextPropertyName()|
|8.40|NuXJS::GCList::deleteAll()|
|6.72|NuXJS::GCList::claim(NuXJS::GCItem*)|
|4.20|NuXJS::Table::lookup(NuXJS::String const*)|
|3.36|NuXJS::GCList::relinquish(NuXJS::GCItem*)|
|2.52|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::operator[](long)|
|2.52|NuXJS::Table::Bucket::valueExists() const|
|2.52|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|
|2.52|NuXJS::String::calcHash() const|
|2.52|NuXJS::Processor::innerRun()|

### recursion_bm_1.js
| % time | Function |
|------:|--------------------------------|
|22.12|NuXJS::StringListEnumerator::nextPropertyName()|
|17.31|NuXJS::Processor::innerRun()|
|3.53|NuXJS::Heap::calcPoolIndex(unsigned long)|
|3.21|NuXJS::Processor::push(NuXJS::Value const&)|
|2.88|NuXJS::Heap::allocate(unsigned long)|
|2.72|NuXJS::Value::toBool() const|
|2.40|NuXJS::Value::toDouble() const|
|2.08|NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|1.92|operator new(unsigned long, NuXJS::Heap*)|
|1.92|NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const|

### for_loop_bm_1.js
| % time | Function |
|------:|--------------------------------|
|52.50|NuXJS::Processor::innerRun()|
|16.25|NuXJS::Processor::push(NuXJS::Value const&)|
|9.06|NuXJS::Value::toDouble() const|
|7.50|NuXJS::Processor::pop(int)|
|5.62|NuXJS::Value::isLessThan(NuXJS::Value const&) const|
|5.00|NuXJS::Processor::pop2push1(NuXJS::Value const&)|
|2.81|NuXJS::Value::toBool() const|
|0.62|NuXJS::Value::compareStrictly(NuXJS::Value const&) const|
|0.62|NuXJS::Value::isLessThanOrEqualTo(NuXJS::Value const&) const|
|0.00|NuXJS::Vector<NuXJS::Value, 8u>::operator[](long)|

### math_bm_1.js
| % time | Function |
|------:|--------------------------------|
|27.70|NuXJS::Processor::innerRun()|
|8.45|NuXJS::Processor::pop2push1(NuXJS::Value const&)|
|8.11|NuXJS::Value::toDouble() const|
|8.11|NuXJS::Processor::push(NuXJS::Value const&)|
|4.05|NuXJS::Value::toBool() const|
|3.38|NuXJS::StringListEnumerator::nextPropertyName()|
|3.04|NuXJS::Processor::pop(int)|
|2.70|NuXJS::Table::lookup(NuXJS::String const*)|
|2.70|NuXJS::GCList::deleteAll()|
|2.03|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|

### bigObject.js
| % time | Function |
|------:|--------------------------------|
|15.49|NuXJS::GCList::deleteAll()|
|14.13|NuXJS::Heap::gc()|
|13.86|NuXJS::StringListEnumerator::nextPropertyName()|
|5.71|NuXJS::Heap::allocate(unsigned long)|
|5.43|NuXJS::Vector<unsigned short, 8u>::~Vector()|
|5.43|NuXJS::Heap::drain()|
|5.16|NuXJS::Processor::innerRun()|
|3.80|NuXJS::intToString(unsigned short*, int)|
|3.53|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|
|3.26|NuXJS::Heap::free(void*)|

### buildStringNaive.js
| % time | Function |
|------:|--------------------------------|
|69.23|NuXJS::StringListEnumerator::nextPropertyName()|
|8.97|NuXJS::GCList::claim(NuXJS::GCItem*)|
|5.13|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|
|5.13|NuXJS::gcMark(NuXJS::Heap&, NuXJS::Value const&)|
|5.13|bool std::__equal<true>::equal<unsigned short>(unsigned short const*, unsigned short const*)|
|2.56|NuXJS::String::isEqualTo(NuXJS::String const&) const|
|2.56|NuXJS::Table::gcMarkReferences(NuXJS::Heap&) const|
|1.28|NuXJS::GCList::relinquish(NuXJS::GCItem*)|
|0.00|NuXJS::GCItem::gcMarkReferences(NuXJS::Heap&) const|
|0.00|NuXJS::Vector<NuXJS::Value, 8u>::operator[](long)|

### buildStringBuffered.js
| % time | Function |
|------:|--------------------------------|
|20.83|NuXJS::StringListEnumerator::nextPropertyName()|
|10.42|NuXJS::Processor::innerRun()|
|6.25|NuXJS::Processor::pop(int)|
|6.25|NuXJS::Heap::free(void*)|
|6.25|NuXJS::Compiler::addConstant(NuXJS::Value const&)|
|4.17|NuXJS::Processor::convertToObject(NuXJS::Value const&, bool)|
|4.17|NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|4.17|NuXJS::Table::gcMarkReferences(NuXJS::Heap&) const|
|4.17|NuXJS::Processor::run(int)|
|2.08|NuXJS::Processor::push(NuXJS::Value const&)|

### bigArray.js
| % time | Function |
|------:|--------------------------------|
|20.27|NuXJS::Processor::innerRun()|
|16.89|NuXJS::StringListEnumerator::nextPropertyName()|
|4.73|NuXJS::GCList::deleteAll()|
|4.05|NuXJS::Processor::push(NuXJS::Value const&)|
|3.38|NuXJS::intToString(unsigned short*, int)|
|3.04|NuXJS::Value::toDouble() const|
|2.70|NuXJS::Heap::calcPoolIndex(unsigned long)|
|2.70|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|2.70|NuXJS::Heap::drain()|
|2.03|NuXJS::Value::toString(NuXJS::Heap&) const|

### function_bm_1.js
| % time | Function |
|------:|--------------------------------|
|16.67|NuXJS::StringListEnumerator::nextPropertyName()|
|6.25|NuXJS::Heap::allocate(unsigned long)|
|5.21|NuXJS::Processor::innerRun()|
|5.21|NuXJS::FunctionScope::~FunctionScope()|
|5.21|NuXJS::GCList::deleteAll()|
|4.17|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|3.12|NuXJS::String::calcHash() const|
|2.60|NuXJS::Vector<NuXJS::Value, 8u>::Vector(unsigned int, NuXJS::Heap*)|
|2.08|NuXJS::Table::Bucket::valueExists() const|
|2.08|NuXJS::Value::toDouble() const|

### string_bm_1.js
| % time | Function |
|------:|--------------------------------|
|15.79|NuXJS::Processor::innerRun()|
|7.42|NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|6.70|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::operator[](long)|
|6.46|NuXJS::Table::Bucket::valueExists() const|
|5.50|NuXJS::String::calcHash() const|
|5.50|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|5.26|NuXJS::JSObject::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|4.55|NuXJS::Table::lookup(NuXJS::String const*)|
|3.83|NuXJS::String::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|3.59|NuXJS::Runtime::GlobalScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const|

### navierStokes_bm.js
| % time | Function |
|------:|--------------------------------|
|22.58|NuXJS::Processor::innerRun()|
|12.90|NuXJS::Processor::push(NuXJS::Value const&)|
|9.68|NuXJS::Value::toDouble() const|
|6.45|NuXJS::JSArray::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|6.45|NuXJS::JSArray::setOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value const&, unsigned char)|
|4.84|NuXJS::Value::compareStrictly(NuXJS::Value const&) const|
|4.84|NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const|
|3.23|NuXJS::Vector<NuXJS::Value, 8u>::operator[](long)|
|3.23|NuXJS::Value::toArrayIndex(unsigned int&) const|
|3.23|NuXJS::Value::add(NuXJS::Heap&, NuXJS::Value const&) const|

### noEval.js
| % time | Function |
|------:|--------------------------------|
|55.07|NuXJS::Processor::innerRun()|
|16.67|NuXJS::Processor::push(NuXJS::Value const&)|
|12.32|NuXJS::Value::toDouble() const|
|4.35|NuXJS::Processor::pop(int)|
|3.62|NuXJS::Value::toBool() const|
|2.90|NuXJS::Value::isLessThan(NuXJS::Value const&) const|
|2.17|NuXJS::Processor::pop2push1(NuXJS::Value const&)|
|1.45|NuXJS::Value::add(NuXJS::Heap&, NuXJS::Value const&) const|
|1.45|NuXJS::Value::compareStrictly(NuXJS::Value const&) const|

### evalCalced.js
| % time | Function |
|------:|--------------------------------|
|37.37|NuXJS::Processor::innerRun()|
|6.57|NuXJS::Processor::pop(int)|
|5.56|NuXJS::Processor::pop2push1(NuXJS::Value const&)|
|5.05|NuXJS::Value::toDouble() const|
|4.04|NuXJS::Table::Bucket::valueExists() const|
|4.04|NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|3.03|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::operator[](long)|
|3.03|NuXJS::Value::toString(NuXJS::Heap&) const|
|3.03|NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const|
|3.03|NuXJS::Vector<NuXJS::Value, 8u>::operator[](long)|

### minimum.js
| % time | Function |
|------:|--------------------------------|
|14.60|NuXJS::Processor::innerRun()|
|9.49|NuXJS::Table::find(NuXJS::String const*, unsigned int)|
|7.30|NuXJS::Vector<NuXJS::Table::Bucket, 8u>::operator[](long)|
|7.30|NuXJS::JSArray::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const|
|5.47|NuXJS::Table::Bucket::valueExists() const|
|4.38|NuXJS::Value::toDouble() const|
|3.65|NuXJS::StringListEnumerator::nextPropertyName()|
|3.65|NuXJS::Processor::pop(int)|
|3.28|NuXJS::Processor::push(NuXJS::Value const&)|
|2.92|NuXJS::Table::lookup(NuXJS::String const*)|

### math_bm_2.js
| % time | Function |
|------:|--------------------------------|
|33.77|NuXJS::Processor::innerRun()|
|11.04|NuXJS::Value::toDouble() const|
|10.39|NuXJS::Processor::push(NuXJS::Value const&)|
|6.49|NuXJS::StringListEnumerator::nextPropertyName()|
|5.19|NuXJS::Processor::pop2push1(NuXJS::Value const&)|
|3.90|NuXJS::Value::add(NuXJS::Heap&, NuXJS::Value const&) const|
|3.25|NuXJS::Value::toBool() const|
|2.60|NuXJS::Processor::pop(int)|
|2.60|NuXJS::String::calcHash() const|
|2.60|NuXJS::Value::toString(NuXJS::Heap&) const|

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
## Optimization Opportunities

- **Property enumeration** – `StringListEnumerator::nextPropertyName` dominates several benchmarks (`bigArray.js`, `function_bm_1.js`, `minimum.js`, `math_bm_2.js`). Caching property lists or tightening the enumerator could trim this overhead.
- **Stack operations** – `Processor::push`, `pop`, and `pop2push1` consume large fractions of loop-heavy workloads such as `noEval.js` and `math_bm_2.js`. Fusing operations or using a more efficient stack representation may help.
- **Numeric conversions** – `Value::toDouble` repeatedly shows up in numeric tests (`noEval.js`, `navierStokes_bm.js`, `math_bm_2.js`), suggesting specialized numeric paths or cached conversions could reduce cost.


## Notes

- `GCList::deleteAll` now sweeps with a cached-next pointer loop, dropping the `gc_bm_1.js` median from 3.49s to 3.40s.
- `Runtime::newStringConstantWithHash` now compares cached literals with `std::memcmp`.
  A gprof run of `string_bm_1.js` shows this helper is never called, so the change only benefits C string constants.
- Always run the benchmark suite before and after changes to confirm any claimed speedups.
- Reordering `Table::find` to check pointer equality before the truncated hash avoids needless `hash16` loads. The suite-wide median fell from 1.29 s to 0.95 s after this tweak.
