# NuXJS Documentation

## Introduction

NuXJS is a sandboxed JavaScript engine written in portable C++03.
The core engine consists of two small `.cpp` files and a header file and
provides a fast stack based virtual machine.  It is fully compatible with
ECMAScript 3 and includes partial support for useful ECMAScript&nbsp;5
features such as JSON and indexed string access.

## Building NuXJS

The project supplies helper scripts under `tools/` for compiling and
running the test-suite.  The main entry point is:

```bash
./tools/buildAndTest.sh
```

which builds the engine and executes all regression tests.  The sources rely on
IEEE compliant floating point math. The main implementation files contain
`#error` directives that fire if `__FAST_MATH__` is defined. Ensure your
compiler options do not enable `-Ofast`, `-ffast-math` or similar flags.
Compilers such as Clang may not support disabling fast math per file, so verify
that these optimizations are turned off at least for `src/NuXJScript.cpp` and
`src/stdlibJS.cpp`.

## Quick Start

After cloning the repository simply run `tools/buildAndTest.sh` to build the
library and execute the self tests.  A minimal "hello world" program looks
like this:

```cpp
#include <NuXJScript.h>
using namespace NuXJS;

int main() {
    Heap heap;
    Runtime rt(heap);
    rt.setupStandardLibrary();
    Var msg = rt.eval("'hello ' + 'world'");
    std::wcout << msg << std::endl;
}
```
After building you will find the interactive REPL program under `output/`. Running `./output/NuXJScript_debug_x64` (or the corresponding build name) starts a simple shell for evaluating JavaScript.

## Embedding NuXJS

The high-level C++ API allows embedding the interpreter into an existing application.
Functions exposed to JavaScript typically have the signature `Var func(Runtime& rt, const Var& thisVar, const VarList& args)` and are stored in the global object like any other value.
Source code may be executed with `Runtime::run()` or evaluated with `Runtime::eval()`.
See the README for a more complete example.

### The Var Type

Var represents a JavaScript value tied to a particular runtime. It derives from AccessorBase which provides conversions and property access. A Var automatically roots its value so it will not be collected while C++ code holds it. Conversions such as `operator double()` and `operator std::wstring()` return primitives without invoking user `valueOf` or `toString`. Var instances can be called like functions and indexed like objects. The companion VarList class stores argument arrays for function calls.


## Memory Management

 A _Heap_ in _NuXJScript_ is a shallow class that implements a simple "mark and sweep" ("stop-the-world") garbage
collector. It also maintains "memory pools" for improved performance but uses the standard C++ heap for allocating
larger objects and for expanding the pools. An application may spawn and use several Javascript engines simultaneously
and **normally each engine (or _Runtime_) has its own _Heap_**. _Heap_ can be sub-classed for custom allocation methods.

 Virtually every object that is dynamically allocated in _NuXJScript_ inherits from _GCItem_. A _GCItem_ normally 
belongs to one of two lists inside a _Heap_: **the list of root items or the list of managed items**. You place them
there by passing the list to the _GCItem_ constructor (e.g. `GCItem(myHeap.managed())`) or by calling
`GCList::claim(...)`. (You obtain the list of root items with `Heap::roots()` and the list of managed items with
`Heap::managed()`.)

 Managed items are subject to garbage collection (via the `Heap::gc()` routine). When a managed item is not reachable
directly or indirectly from any of the root items it will be deleted from the heap. Thus, **managed items must be
dynamically allocated**. You need to allocate such items on a _Heap_ using the overloaded `new` operator like this:
`new(myHeap) MyItem(myHeap.managed())`.

 **Root items do not need to be allocated on a _Heap_.** They can be constructed and destructed in any way you wish.
E.g. it is ok to have root items on the C++ stack. Obviously it is important to assure that other items do not reference
root items when they go out of scope / are deallocated. You can move an item from one list to the other by calling
`GCList::claim(...)`. E.g. to turn a root item that was allocated with `new(heap)` into a managed item, write:
`myHeap.managed().claim(myFormerRootItem)`.

 **In rare circumstances it is ok to not place a _GCItem_ on a heap at all**. The item will in this case never be a
candidate for garbage collection, but it will also never mark any of its references. In other words, this item must be a
terminal leaf that has no further unique references. (One use case of this is for global constant Strings, e.g. `const
String MAGNUS_STRING("Magnus")`.)

 When a _GCItem_ is destructed (regardless if it is from automatic garbage collection or not) it is removed from the
list it belongs to. This enables heaps to contain a mixture of automatically garbage collected and manually memory
managed items. It also means that **it is always ok to manually delete an item** (including managed items) once you are
done with it **provided that you can guarantee that it can no longer be reached** of course. This might ease the burden
on the garbage collector and speed up allocation.

 **Every sub-class of _GCItem_ is responsible for overriding `gcMarkReferences(Heap& heap)` to mark all _GCItems_ it
references** (via the overloaded `gcMark(heap, ...)` functions). Remember to also call the super-class's
`gcMarkReferences` in the overriden method. **If `gcMarkReferences` is implemented incorrectly, items that are still in
use may get garbage collected** (= deadly sin).

Garbage collection is either invoked manually with `Heap::gc()` or automatically via `Runtime::autoGC()`. **Automatic
garbage collection occurs when the number of bytes on a heap reaches a threshold that is two times the heap's size after
the last garbage collection.** It is also possible to impose a hard limit on the heap's size.

## Creating Strings

Strings store UTF‑16 data. When a new string should live on a heap you may
allocate it directly with `new(heap) String(heap.managed(), text)` or use the
helper `String::allocate(heap, "text")`. Temporary root strings can be
constructed on the stack using `String(heap.roots(), ...)`.

NuXJS provides several convenience routines for constructing managed strings:

```
String::allocate(heap, "foo")           // copy from UTF‑8 literal
String::concatenate(heap, left, right)   // join two existing strings
String::fromInt(heap, 42)                // formatted integer (cached for -1000..1000)
String::fromDouble(heap, 3.14)           // formatted double with special handling for NaN/Inf
```

`String::fromInt` and `String::fromDouble` return pointers to static constant
strings for small integers and special floating point values. For other values a
fresh heap string is created every call.

# Source Code Conventions

- `const String&` arguments never saves pointer to the argument, temporary (unmanaged) instances of `String()` are
  allowed.
- `getXXX()` implies that there will be an assertion failure if the value is not of type XXX.
- `asXXX()` implies that 0 will be returned if the value is not of type XXX.
- `toXXX()` implies that the value will be converted to type XXX if necessary and an exception might be thrown if it is
  not possible.

## Runtime Architecture

NuXJS uses a simple stack machine running bytecode emitted by a single-pass compiler. `Processor` objects interpret the code on behalf of a `Runtime`. You can create multiple processors for the same runtime, for instance when a C++ callback calls back into JavaScript. Because the interpreter is asynchronous, applications can call `Processor::run(maxCycles)` repeatedly to interleave JavaScript execution with other tasks.

## Exception Handling

JavaScript code uses ordinary `throw` statements and `try`/`catch` blocks. When an exception propagates to C++, a `ScriptException` is thrown. It owns the underlying `Error` object and exposes its message through `what()`. Compilation errors are reported via `CompilationError` which additionally stores the filename, character offset and line number. The runtime may also throw a `ConstStringException` for conditions such as running out of memory or hitting a timeout. Embedding code typically catches `ScriptException`:

```cpp
try {
    rt.run("someScript();");
} catch (const ScriptException& ex) {
    std::wcerr << ex.what() << std::endl;
}
```

Native functions can raise script errors using
`ScriptException::throwError(heap, type, message)`. This helper creates a
JavaScript `Error` instance and throws it as a `ScriptException` so that
JavaScript can catch it normally:

```cpp
if (touchFunction.typeOf() != &FUNCTION_STRING) {
    ScriptException::throwError(heap, GENERIC_ERROR,
        "cannot compile JS gui-variable (touch is not a function)");
}
```

When your native code may throw exceptions of its own, convert them to script
errors so JavaScript callers can handle them:

```cpp
Var loadFile(Runtime& rt, const Var&, const VarList& args) {
    Heap& heap = rt.getHeap();
    try {
        std::ifstream f(wideToUTF8String(args[0]));
        if (!f)
            ScriptException::throwError(heap, GENERIC_ERROR, "failed to open file");
        // read file here
    } catch (const std::exception& e) {
        ScriptException::throwError(heap, GENERIC_ERROR, e.what());
    } catch (...) {
        ScriptException::throwError(heap, GENERIC_ERROR, "native exception");
    }
    return Var(rt);
}
```

## Standard Library and JavaScript Features

The engine ships with a standard library implemented in JavaScript providing
the objects described in ECMAScript&nbsp;3.  It also offers selected
ECMAScript&nbsp;5 functionality including JSON and string indexing.

## Conformance and Known Limitations

The file `docs/ECMAViolations.txt` documents numerous deviations from the ECMAScript specification. The current implementation still exhibits the following behaviours:

* `\0` is interpreted as a null character even if digits follow (octal escapes are not supported).
* Unicode line separator (`\u2028`) and paragraph separator (`\u2029`) are treated as linefeeds. The non‑breaking space (`\u00A0`) counts as white space, but the zero width no‑break space (`\uFEFF`) does not. No other Unicode "space separator" characters are recognised.
* Custom property getters and setters are not implemented.
* Implicit `valueOf` and `toString` conversions may happen earlier than specified, for example `v[o]++` only invokes `toString()` once.
* Octal (`0o`) and binary (`0b`) prefixes are not understood when converting strings to numbers.
* The `arguments` object follows ES3 mapping semantics; changing element attributes does not fully emulate the ES5 behaviour.
* Every created function has a writable, enumerable and configurable `name` property.
* Evaluation order of member expressions follows the ES3 order (object and arguments evaluated before selecting the member).
* When the identifier of a `catch` clause is called as a function, its `this` value is the global object.
* Assignments evaluate the right hand side before resolving the reference on the left hand side.
* Property access may convert the property key before converting the base object.
* In regular expressions the lookahead operators `?=` and `?!` cannot be quantified as in ES3; they behave like the ES5 assertions.
* Case-insensitive ranges in regular expressions and zero-length captures inside repeats may not perfectly match other engines.
* A semicolon is required after `do ... while` statements. This matches the ES3 and ES5 grammar even though ES6 made the semicolon optional.
* Creating a numeric property on an object can shadow a read-only numeric property in the prototype chain.
* Several tests under `tests/unconforming` demonstrate additional corner cases.
* Assigning an object to an array's `length` property is unsupported.
* Recursive grammar constructs are limited to 64 levels to avoid C++ stack overflow.

The engine also implements a subset of later specifications:

* `Array.isArray`, `Object.prototype.hasOwnProperty`, `Object.prototype.isPrototypeOf`, `Object.getPrototypeOf`, `Object.defineProperty`, `JSON.parse` and `JSON.stringify` are provided.
* Characters of a String object can be accessed through array indexing as specified in ES5.
* `eval()` differentiates between direct and indirect calls as defined in ES5.
* `String.prototype.match` uses the ES5 behaviour for global regular expressions and always calls the built-in `RegExp.prototype.exec`.
* `Array.prototype.splice` with a single argument deletes the rest of the array (ES6 rule).
* Many features of the `Date` object from ES5 have been added.
* Regular expression flags cannot contain Unicode escapes (ES6 restriction).
* Unicode format control characters are preserved in source text as specified by ES5.

## Testing and Benchmarking

The test suite resides in the `tests/` directory and is exercised by running
the helper script `tools/buildAndTest.sh`.  Additional benchmark programs are
found under `benchmarks/`.

## Performance and Optimization Tips

Use `Runtime::setMemoryCap()` and `Runtime::resetTimeOut()` to limit memory
usage and execution time of JavaScript code.

## Contributing

Patches should be validated by running `./tools/buildAndTest.sh` before submission. Follow the existing C++03 style (avoid STL containers) and adhere to the naming conventions listed above.

## License

NuXJS is released under the terms of the BSD&nbsp;2‑Clause license.  See the
`LICENSE` file for details.
