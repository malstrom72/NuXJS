# Host Guide

How to put NuXJS inside an application. It follows one small host, `docs/examples/host.cpp`, which loads a "rules"
script, gives it a `host` object, sends it events and reports what goes wrong. The build compiles and runs it and
compares its output with `docs/examples/expected_host.txt`, so every call shown here works. The API itself is in
`NuXJS Documentation.md`; this guide says which parts a host needs and in what order, and links there for the rest.

## 1. Setting up

A host needs a `Heap`, a `Runtime` on it, and usually the standard library:

```cpp
Heap heap;
heap.setMaxAllocationSize(4 * 1024 * 1024);
Runtime rt(heap);
rt.setupStandardLibrary();
rt.setMemoryCap(16 * 1024 * 1024);
```

Set the limits before running anything a script controls. Each one is described where the engine defines it:

- `Heap::setMaxAllocationSize` and `Runtime::setMemoryCap` bound memory ("Memory Management").
- `Runtime::resetTimeOut` bounds running time; `noTimeOut` turns it off again.
- `Runtime::setMaxNestedCompileDepth` bounds compile-time recursion, which matters on a small C++ stack ("Nesting
  limits"). Lower it before the standard library is set up; it must stay at 64 or above.
- `Runtime::setStackSize` sets the virtual machine's value stack, the one script recursion uses.

A runtime and everything on its heap belong to one thread. Several runtimes may share a heap, but a heap is not
thread-safe, so a host that runs scripts on several threads gives each thread its own heap ("Runtime Architecture").

## 2. Loading scripts

Compile with a file name, so that errors and stack traces can say where they happened:

```cpp
Var source(rt, text);
Var name(rt, fileName);
const Code* code = rt.compileGlobalCode(source, name);
```

The source and the name sit in `Var`s so the garbage collector keeps them while the compiler works ("The Var Type").
Source that does not compile throws a `CompilationError`, which carries the file name and the line and column where
the compiler stopped; its `what()` is the `SyntaxError` message. `host.cpp`'s `load()` reports
`broken.js:1:30: SyntaxError: Expected ',' or ')'`.

Compiled code runs as global code on a `Processor`, as in section 5. Code that only needs a value back can use
`Runtime::eval` or `Runtime::run` instead ("Embedding NuXJS").

## 3. Exposing host functions and objects

A host gives scripts what they may use and nothing else. The example builds one object and puts it on the global
object:

```cpp
Var host = rt.newObjectVar();
host["log"] = hostLog;
host["scale"] = hostScale;
rt.getGlobalsVar()["host"] = host;
rt.getGlobalsVar()["Meter"] = Meter::createConstructor(rt);
```

Each function has the signature `Var f(Runtime&, const Var& thisVar, const VarList& args)`; the binding forms are in
"Binding C++ functions".

A host type with state of its own is a native class. The example's `Meter` keeps a count and a highest value in C++:
the script creates one with `new Meter()` and calls `add()` and `highest()` on it. Its methods are static functions on
`Meter.prototype`, so a script can call them with any `this`; each one first passes `this` through `checkedSelf`,
which refuses anything that is not a `Meter` before it is cast. The example's `misuse` event detaches `add` from its
meter and gets `TypeError: can only be used on a Meter` rather than a corrupted object. "Checking `this`" explains
the check, and "Implementing Custom Native Objects" what else a native class can override.

A host function reports a misuse to the script as an exception the script can catch:

```cpp
if (args.size() < 1 || !args[0].to<Value>().isNumber()) {
	ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "host.scale() expects a number");
}
```

C++ exceptions of the host's own must not cross into script code; convert them as "Exception Handling" shows.

## 4. Calling into script

The host finds the script's handler by name and calls it like a function:

```cpp
Var handler = rt.getGlobalsVar()["onEvent"];
handler(Var(rt, name), value);
```

A call runs the script to completion before it returns, with the runtime's limits applied. A `Var` keeps its value
alive for as long as the host holds it, so a host can look a handler up once and keep it. Calls nest: a script may
call a host function that calls back into script, up to a fixed depth of such crossings, past which the runtime throws
rather than risk the C++ stack.

## 5. Driving execution

`Runtime::runUntilReturn` runs a processor to the end. A host that has other work to interleave, an audio or UI loop
for instance, drives the processor itself and applies the runtime's policies between batches, which is where they
belong ("Runtime Architecture"):

```cpp
Processor processor(rt);
processor.enterGlobalCode(code);
while (processor.run(1000)) {
	rt.autoGC(true);
	rt.checkTimeOut();
}
```

`autoGC(true)` collects when the heap has grown enough and enforces the memory cap; `checkTimeOut` enforces the
timeout. A host can also call `Heap::gc` itself at a moment it chooses, such as between events.

## 6. Errors

Three kinds of exception reach the host:

- `CompilationError`, for source that does not compile (section 2).
- `ScriptException`, for an exception the script did not catch. `what()` is its message and `getStackTrace()` adds
  where it was thrown, with file names and positions: `ReferenceError: undefinedRule is not defined` followed by
  `at onEvent (rules.js:6:37)`.
- `ConstStringException`, for the runtime's own limits: `Out of memory` and `Time out`.

All three derive from `NuXJS::Exception`, which is a `std::exception`. After any of them the runtime remains usable:
the example goes on to send another event once a script has run out of memory and another has timed out. What a
failed script stored in global variables stays there, so a host that keeps the runtime clears what it no longer
wants. The example's runaway script keeps its data in a function's local variable, so it is garbage once the call
fails.

## 7. Untrusted scripts

With the limits from section 1, a script cannot crash or hang the host:

- the memory cap stops a script that keeps what it allocates, and the allocation limit stops a single huge
  allocation;
- the timeout stops a script that runs too long;
- the compile limit turns too deeply nested source into a `RangeError`, and the value stack and the crossing depth
  bound recursion at run time.

What remains unbounded is noted where it is measured: the memory a process holds can exceed the cap by what one batch
allocates, garbage included ("Memory Management").
