# Profiling and Optimization Findings

## Profiling Overview

NuXJS was built with `-pg` and profiled with gprof across several benchmarks.

## Benchmark Profiles

### gc_bm_1.js
| % time | Function |
|------:|----------------|
|17.59|NuXJS::GCList::deleteAll()|
|11.11|NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)|
|8.33|NuXJS::GCList::relinquish(NuXJS::GCItem*)|
|8.33|NuXJS::Table::gcMarkReferences(NuXJS::Heap&) const|
|7.41|NuXJS::StringListEnumerator::nextPropertyName()|
|4.63|NuXJS::Heap::allocate(unsigned long)|
|3.70|NuXJS::Processor::innerRun()|
|3.70|NuXJS::Heap::drain()|
|2.78|NuXJS::JSObject::gcMarkReferences(NuXJS::Heap&) const|
|2.78|NuXJS::Processor::popFrame()|

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
