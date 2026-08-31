# NuXJS Documentation

## Introduction

NuXJS is a sandboxed JavaScript engine implemented in portable C++03. It has been tested with GCC and Clang on x86-64 and ARM, as well as with MSVC on Windows. The core consists of a single `.cpp` file, a single `.h` file, and a `.js` standard library (also available as a `.cpp` array for embedding). It features a fast, stack-based virtual machine and builds in two editions: the **es5 build** (`NUXJS_ES5`) implements ECMAScript 5.1 - strict mode, accessors, the full `Object` reflection API and library included - while the **es3 build** is the original, fully ECMAScript 3 compatible core with a handful of ES5 conveniences like JSON and indexed string access.

## Building NuXJS

Helper scripts are available under `tools/` for building and running the test suite. The recommended entry point is:

'''bash
./build.sh
'''

On Windows, use `build.cmd` instead.

This wrapper builds and tests both editions (es3 and es5) in both the `beta` and `release` configurations by invoking `tools/buildAndTest.sh`; `./build.sh es5 release` selects a single combination (arguments are recognized by value, in any order). Each build runs its own tests - the es5 build additionally runs `tests/es5`, the es3 build `tests/es3only`. When everything completes, the native release REPLs are saved as `output/NuXJS` (es3) and `output/NuXJS_ES5` (es5).

The implementation depends on IEEE-compliant floating-point math. `src/NuXJS.cpp` includes `#error` directives that trigger if `__FAST_MATH__` is defined. Avoid compiler flags like `-Ofast`, `-ffast-math`, or similar, at least for `src/NuXJS.cpp`.

The standard library lives in `src/stdlib.js`.
During the build, it is minified and converted to C++ via `tools/stdlibToCpp.pika` using `PikaCmd`.
The build scripts automatically regenerate `src/stdlibJS.cpp` when `stdlib.js` changes.
See `Standard Library Guidelines.md` for rules on modifying this file.

## Using the REPL

Building NuXJS produces a command line REPL named `NuXJS`. Inside the REPL,
`help()` lists the available helper functions and meta commands. Custom helpers
include `read(file)`, `load(file)`, `quit()`, `gc()` and `dasm(fn)`. Meta
commands start with `#` and currently support `#save [name]` to write the session
log and `#purge` to clear it. `#save` without a name uses a timestamp for the
file name and saves the `.io` file directly into `tests/` so it can be added as
a regression case. Prefixing a line with `?` runs `print()` on that expression.

## Embedding NuXJS

The high-level C++ API allows easy embedding of the interpreter into an existing application. Functions exposed to JavaScript typically have the signature `Var func(Runtime& rt, const Var& thisVar, const VarList& args)` and are stored in the global object like any other value. Source code may be executed with `Runtime::run()` or evaluated with `Runtime::eval()`.

A minimal "hello world" program looks like this:

```cpp
#include <NuXJS.h>
using namespace NuXJS;

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();
	Var msg = rt.eval("'hello ' + 'world'");
	std::wcout << msg << std::endl;
}
```

### The Var Type

`Var` represents a JavaScript value tied to a particular runtime. It derives from `AccessorBase`, which provides conversions and property access. A `Var` automatically roots its value, so it will not be garbage collected while C++ code holds it. Conversions such as `operator double()` and `operator std::wstring()` return primitives (without invoking custom `valueOf` or `toString`). `Var` instances can be called like functions and indexed like objects. The companion `VarList` class stores argument arrays for function calls.

### Extended Example

The following program shows how to expose a native function, enforce memory and time limits, and call back and forth between C++ and JavaScript:

```cpp
#include <NuXJS.h>
using namespace NuXJS;

// Native function used from JavaScript.
static Var sum(Runtime& rt, const Var&, const VarList& args) {
	double total = 0.0;
	for (int i = 0; i < args.size(); ++i)
		total += args[i];
	return Var(rt, total);
}

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();
	rt.setMemoryCap(1024 * 1024); // 1 MB cap
	rt.resetTimeOut(10);		  // 10‑second time limit
	Var globals = rt.getGlobalsVar();

	globals["sum"] = sum;
	rt.run("function demo(a,b,c){return 'a+b+c = ' + sum(a,b,c);}");
	std::wcout << globals["demo"](7, 15, 20) << std::endl;

	Var silly = rt.eval("(function(){return arguments;})");
	Var arg0(rt, "131");
	const Value nums[10] = { arg0, 535, 236, 984, 456.5, 666, 626, 585, 382, 109.5 };
	Var list = silly(VarList(rt, 10, nums));
	std::wcout << globals["sum"]["apply"](Value::NUL, list) << std::endl;

	const int y = 2008, m = 7, d = 20;
	Var date = rt.eval("(function(y,m,d){return new Date(y,m,d)})")(y, m, d);
	std::wcout << date << std::endl;
	std::wcout << date["toString"]() << std::endl;

	Var arr = rt.eval("[4,8,15,16,23,42]");
	for (Var::const_iterator it = arr.begin(); it != arr.end(); ++it)
		std::wcout << arr[*it] << ' ';
	std::wcout << std::endl;
}
```

This mirrors the JavaScript idioms used in the engine's high‑level API and illustrates how `Var` and `VarList` manage lifetime and conversions between the two languages.

### Implementing Custom Native Objects

Embedding applications often need richer objects than plain functions. Every scriptable entity in NuXJS ultimately derives from `Object`, which defines the contract for property lookups, mutation, and enumeration. Property access uses a compact set of attribute flags - `EXISTS_FLAG`, `READ_ONLY_FLAG`, `DONT_ENUM_FLAG`, and `DONT_DELETE_FLAG` - together with the `STANDARD_FLAGS` helper constant for ordinary writable properties.

`Object` exposes five virtuals that host objects may override. Understanding how they interact is key to building a class that behaves just like its JavaScript counterparts:

* `getOwnProperty(Runtime&, const Value&, Value*)` returns a `Flags` bitmask describing the slot and, on success, writes the current value through the output pointer. Return `NONEXISTENT` (zero) when the key is unknown; in that case the engine will leave the output untouched and fall back to the prototype chain.
* `setOwnProperty(Runtime&, const Value&, const Value&, Flags)` creates or replaces a property on the object itself. Return `true` once the write has been applied, or `false` to refuse it (for example, when a read-only slot is already present). The caller supplies the attribute flags so native code can mark properties read-only, non-enumerable, or non-deletable by OR-ing the appropriate bits. Implementations should reject requests that conflict with existing storage by returning `false`.
* `updateOwnProperty(Runtime&, const Value&, const Value&)` updates an existing property while preserving its flags. Return `true` only when the property existed and the new value has been stored; return `false` otherwise. The default implementation simply checks `hasOwnProperty` and then defers to `setOwnProperty`, but custom classes often override it to short-circuit lookups or to report failures without disturbing `setOwnProperty`.
* `deleteOwnProperty(Runtime&, const Value&)` decides whether `delete obj[key]` succeeds. Return `true` once the property has been removed. Returning `false` leaves the property intact, mirroring JavaScript's semantics for `configurable: false` slots.
* `getOwnPropertyEnumerator(Runtime&)` hands back an `Enumerator` that yields enumerable keys; the pointer should reference a GC-managed enumerator allocated by the callee. NuXJS automatically chains enumerators from the prototype chain by calling `getPropertyEnumerator`. Returning an empty enumerator (never `nullptr`) signals that the object contributes no own properties.

All other property helpers funnel through these hooks. A write performed from JavaScript-or from C++ via `globals["name"] = value`-ultimately lands on `Object::setProperty`. That helper first calls `updateOwnProperty`, then checks the prototype chain for a read-only shadow, and finally falls back to `setOwnProperty` to insert a new slot. The assignment helpers in `Var` and `Property` call the same path, so custom classes see identical behaviour whether a script or the host performs the mutation.

Because `setOwnProperty` receives the attribute flags, it is responsible for enforcing the invariants attached to a slot. `JSObject`, the dictionary-style object NuXJS uses for ordinary JavaScript values, provides the canonical example: it interns the key as a string, updates an internal hash table, and refuses writes when a bucket already carries `READ_ONLY_FLAG` or `DONT_DELETE_FLAG`. Host objects can employ the same pattern when exposing selective mutability.

#### Reusing the built-in storage helpers

Deriving from `JSObject` is the quickest way to obtain a full ECMAScript property bag. `JSObject` couples `Object` with the internal `Table`, automatically handles key canonicalisation, and allocates enumerators that honour the `DONT_ENUM` bit. Passing `STANDARD_FLAGS` to `setOwnProperty` yields a normal writable, enumerable property; additional flags add const-like semantics. If you only need to materialise the property table lazily (for example, when exposing a large native object with rare script interaction) you can inherit from `LazyJSObject` instead and build the backing `JSObject` the first time a property hook fires. `LazyJSObject` is a class template parameterised on its own super-class, so it is used as `LazyJSObject<Object>` (the form `JSArray`, `Error` and `Arguments` take) or `LazyJSObject<Function>` (the form `ExtensibleFunction` takes), and the subclass supplies the deferred construction by implementing `constructCompleteObject`.

When the host manages its own backing state and does not need `JSObject`'s hash table, overriding the base `Object` hooks directly avoids the bookkeeping overhead. Returning `NONEXISTENT` from `getOwnProperty` delegates the lookup to the prototype chain, while returning `false` from `setOwnProperty` causes assignments to silently do nothing-matching JavaScript's behaviour for read-only properties on non-strict code paths. Deletions mirror this pattern: `delete` succeeds only if your implementation returns `true` and the stored flags did not include `DONT_DELETE_FLAG`.

#### Example: exposing a mutable point

The snippet below sketches a small native class that surfaces `x`/`y` fields with read-write semantics and participates in property enumeration. It relies on the common `StringListEnumerator` helper to report its keys:

```cpp
using namespace NuXJS;

static const String X_STRING("x");
static const String Y_STRING("y");

class NativePoint : public Object {
public:
    NativePoint(GCList& gcList, double x, double y)
        : Object(gcList), x(x), y(y) { }

    Object* getPrototype(Runtime& rt) const override { return rt.getObjectPrototype(); }

    Flags getOwnProperty(Runtime&, const Value& key, Value* out) const override {
        if (key.equalsString(X_STRING)) { *out = x; return STANDARD_FLAGS; }
        if (key.equalsString(Y_STRING)) { *out = y; return STANDARD_FLAGS; }
        return NONEXISTENT;
    }

    bool setOwnProperty(Runtime&, const Value& key, const Value& v, Flags flags) override {
        if ((flags & READ_ONLY_FLAG) != 0) {
            return false;        // refuse read-only redefinitions
        }
        if (key.equalsString(X_STRING)) { x = v.toDouble(); return true; }
        if (key.equalsString(Y_STRING)) { y = v.toDouble(); return true; }
        return false;
    }

    bool updateOwnProperty(Runtime& rt, const Value& key, const Value& v) override {
        return setOwnProperty(rt, key, v, STANDARD_FLAGS);
    }

    bool deleteOwnProperty(Runtime&, const Value&) override { return false; }

    Enumerator* getOwnPropertyEnumerator(Runtime& rt) const override {
        Heap& heap = rt.getHeap();
        StringListEnumerator* e = new(heap) StringListEnumerator(heap.managed(), 2);
        e->add(&X_STRING);
        e->add(&Y_STRING);
        return e;
    }

private:
    double x;
    double y;
};

void exposePoint(Runtime& rt) {
    Heap& heap = rt.getHeap();
    Object* globals = rt.getGlobalObject();
    NativePoint* p = new(heap) NativePoint(heap.managed(), 3.0, 4.0);
    globals->setOwnProperty(rt, String::allocate(heap, "point"), p, STANDARD_FLAGS);
}
```

Because `Property::operator=` also routes through `Object::setProperty`, the same object can be updated from C++ in a fluent style - for example `rt.getGlobalsVar()["point"]["x"] = 7.5;` - and those writes still flow through the overrides above. This keeps host-side and script-side interactions consistent without duplicating bookkeeping.

#### Exposing methods: hooks versus the prototype chain

A native class that carries bulk data - a sample buffer, a matrix, a decoded image - usually needs fast indexed access from C++ as well as a set of methods callable from script. It is tempting to answer the method names directly in `getOwnProperty` alongside the indices, but the two cases pull in opposite directions. Answering a key is precisely what suppresses the prototype chain, so a method resolved inside `getOwnProperty` permanently shadows whatever the prototype offers: scripts cannot override it, cannot wrap it, and cannot delete it to fall back on something else. String-comparing each candidate method name on every property access also costs more than one hashed lookup.

`JSArray` demonstrates the alternative. Its `getOwnProperty` resolves an array index against a dense `Vector` and returns `STANDARD_FLAGS`, answers `length` with `HIDDEN_CONST_FLAGS`, and defers everything else to `super::getOwnProperty` - which, because `JSArray` derives from `LazyJSObject<Object>`, consults the lazily built property table and then the prototype chain. The methods themselves live in `src/stdlib.js` on `Array.prototype` and are found by ordinary prototype resolution. `String::getOwnProperty` follows the same shape for indexed character access.

The rule that generalises: let the hooks answer indices and a small fixed set of internal slots, return `NONEXISTENT` for everything else, and install the methods on a prototype. Test `Value::toArrayIndex` first so the common case exits early. The performance-critical paths stay in C++ while method lookup, shadowing and overriding remain ordinary JavaScript. When script must be able to replace the visible surface wholesale, the further step is to keep the native object out of script's hands entirely and have a JavaScript wrapper hold it in a property; NuXJS has no symbols, so such a slot is an ordinary string key made unobtrusive with `DONT_ENUM_FLAG` rather than genuinely private.

A prototype built in C++ is a heap reference like any other. Whichever object owns it - the `Runtime`, a shared holder, or each instance - must mark it in `gcMarkReferences` and chain to the super-class implementation. Note also that a class whose hooks expose indices has to report them from `getOwnPropertyEnumerator` as well, or `for...in` will disagree with direct property access.

#### Binding C++ functions to properties, and validating `this`

A method installed on a prototype can be invoked with any receiver, so before casting `this` to the native class something has to confirm that it really is one. Whether anything does is decided by *which kind of C++ function you assign* - the four forms below are picked apart by overload resolution on `AccessorBase::makeValue`, and they behave differently. This is a safety decision rather than a matter of taste, so it is worth being deliberate about:

| What is assigned | Signature | Adapter created | Receiver (`this`) |
| --- | --- | --- | --- |
| a free or static function | `Value (*)(Runtime&, Processor&, UInt32, const Value*, Receiver)` (`NativeFunction`) | `FunctorAdapter` | passed through raw, **not checked** |
| a free or static function | `Var (*)(Runtime&, const Var&, const VarList&)` (`VarFunction`) | `VarFunctorAdapter` | wrapped in a `Var`, **not checked** |
| a pointer to a member function | `Var (C::*)(Runtime&, const Var&, const VarList&)` | `VarMemberFunctionAdapter<C>` | **checked**, then used as the C++ `this` |
| `Var(rt, cppObject, &C::method)` | the same member signature, bound | `BoundVarMemberFunctionAdapter<C>` | ignored - the call always runs on `cppObject` |

The distinction that catches people out is the first two versus the third. A static function and a member function can have identical-looking bodies and be installed on the same prototype, yet only the member function gets a receiver check. The static forms hand over whatever the call site supplied and do nothing else - `VarFunctorAdapter::invoke` is a single forwarding line. A static function that casts its receiver to its own class **must** validate it first, or `Type.prototype.method.call({}, ...)` will cast an unrelated object and corrupt memory instead of throwing.

`Receiver` is the one type in this table that differs between the builds: `Object*` in the es3 build, `const Value&` under `NUXJS_ES5`, because ES5.1 strict mode lets `this` be a primitive, `null` or `undefined` rather than always an object. A native written against the es3 signature therefore stops compiling when the build is switched; `receiverObject(r)` answers the `Object*` again, and `docs/notes/This as a Value.md` covers the reasoning and the call sites it touched.

One further difference: `FunctorAdapter` derives from `Function`, while the other three derive from `ExtensibleFunction`. Only the latter can carry ordinary properties, so a constructor function whose `prototype` property must be assignable - as TypeScript's ES3 `__extends` emit requires of a base class - cannot use the raw `NativeFunction` form.

##### The checked form

Assigning a pointer to a member function with the signature `Var (C::*)(Runtime&, const Var&, const VarList&)` wraps it in an adapter that performs the check automatically. Before dispatching, the adapter compares the statically resolved `C::getClassName()` against the virtual `getClassName()` on the receiver, and throws a `TypeError` carrying the message `Invalid class` when the two differ:

```cpp
static const String VECTOR_CLASS_NAME("NativeVector");

class NativeVector : public JSObject {
public:
    typedef JSObject super;
    NativeVector(Heap& heap, Object* proto) : super(heap.managed(), proto), samples(&heap) { }

    // The receiver check is driven entirely by this override, so it must return the same pointer every time.
    const String* getClassName() const override { return &VECTOR_CLASS_NAME; }

    Var scale(Runtime& rt, const Var& thisObject, const VarList& args) {
        samples.resize(1);                     // reached only once `this` is known to be a NativeVector
        samples[0] = args[0].to<double>();
        return Var(rt, samples[0] * 2.0);
    }

private:
    Vector<double> samples;                    // `Vector` takes its heap explicitly; it has no default constructor
};

Var protoVar(rt, rt.newJSObject());
protoVar["scale"] = &NativeVector::scale;      // a member function pointer, not a static function

NativeVector* v = new(heap) NativeVector(heap, protoVar.to<Object*>());
rt.getGlobalsVar()["v"] = Var(rt, v);

rt.eval("v.scale(21)");                                  // 42 - the receiver is a NativeVector
rt.eval("var o = {}; o.scale = v.scale; o.scale(21)");   // throws TypeError: Invalid class
```

The two `eval` calls are the point of the example: the same function object, reached through the same property, either runs or is rejected purely on what `this` turns out to be. Nothing in `scale` performs the test, and the body of the second call is never entered.

**The class must override `getClassName`, and nothing enforces it.** The comparison is between `C`'s statically resolved `getClassName()` and the receiver's virtual one. If `C` does not override it, the static side resolves to the inherited `JSObject`/`Object` implementation - which is also what any ordinary object returns virtually - so the two agree, the guard passes, and an unrelated object is `reinterpret_cast` into `C`. The check degenerates into a no-op precisely when it is needed, with no warning at compile time or run time. Treat the override as mandatory for any class bound this way, and give it a `String` constant of its own.

Two further limits. The adapter validates the *receiver* only - any arguments that must also be of a native class still need checking by hand. And it is not null-safe: it reaches the receiver's virtual `getClassName()` through a `reinterpret_cast`, so a null receiver crashes rather than throwing. A hand-written check can test for null first.

##### The unchecked form, and the manual check

Static functions - `Counter::increment` in `docs/examples/examples.cpp`, and most native methods in practice - get no help at all, so the same test has to be written out. Compare `getClassName()` against the class's own `String*` by pointer identity, which is exactly what the adapter does, plus a null test:

```cpp
static NativeVector* checkedSelf(Runtime& rt, Object* o) {
    if (o == 0 || o->getClassName() != &VECTOR_CLASS_NAME) {
        ScriptException::throwError(rt.getHeap(), TYPE_ERROR, "can only be used on NativeVector");
    }
    return static_cast<NativeVector*>(o);        // safe: the class name has been confirmed
}

static Var scale(Runtime& rt, const Var& thisObject, const VarList& args) {
    NativeVector* self = checkedSelf(rt, thisObject.to<Object*>());
    ...
}

protoVar["scale"] = scale;                       // a plain function - nothing checks the receiver
```

Omitting `checkedSelf` here would not be a lax cast that usually works; it would be an unchecked one that any script can exploit with `.call()`. A bare `static_cast` is only defensible when nothing else can reach the prototype, as in a self-contained example.

For checked downcasts outside a call, the engine's own idiom is a virtual accessor: `Object::asFunction`, `asArray` and `asError` return `0` by default and the class that owns the type overrides it to return `this`. Giving a custom class an equivalent yields a cheap, safe conversion from an arbitrary `Object*`.

## Runtime Architecture

NuXJS utilizes a simple stack machine that runs bytecode generated by a single-pass compiler. `Processor` objects interpret the code on behalf of a `Runtime`. You can create multiple processors for the same runtime, for instance, when a C++ callback calls back into JavaScript. Because the interpreter is asynchronous, applications can call `Processor::run(maxCycles)` repeatedly to interleave JavaScript execution with other tasks.

## Memory Management

A `Heap` in NuXJS is a shallow class that implements a simple "mark and sweep" ("stop-the-world") garbage collector. It also maintains "memory pools" for improved performance, but uses the standard C++ heap for allocating larger objects and for expanding the pools. An application may spawn and use several JavaScript engines simultaneously and normally, each engine (or `Runtime`) has its own `Heap`. `Heap` can be subclassed for custom allocation methods.

Virtually every object that is dynamically allocated in NuXJS inherits from `GCItem`. A `GCItem` normally belongs to one of two lists inside a `Heap`: the list of root items or the list of managed items. You place them there by passing the list to the `GCItem` constructor (e.g. `GCItem(myHeap.managed())`) or by calling `GCList::claim(...)`. (You obtain the list of root items with `Heap::roots()` and the list of managed items with `Heap::managed()`.)

Managed items are subject to garbage collection (via the `Heap::gc()` routine). When a managed item is not reachable directly or indirectly from any of the root items, it will be deleted from the heap. Thus, managed items must be dynamically allocated. You need to allocate such items on a `Heap` using the overloaded `new` operator like this: `new(myHeap) MyItem(myHeap.managed())`.

Root items do not need to be allocated on a `Heap`. They can be constructed and destructed in any way you wish. For example, it is okay to have root items on the C++ stack. It is important to ensure that other items do not reference root items when they go out of scope / are deallocated. You can move an item from one list to the other by calling `GCList::claim(...)`. E.g., to turn a root item that was allocated with `new(heap)` into a managed item, write: `myHeap.managed().claim(myFormerRootItem)`.

In rare circumstances, it is ok not to place a `GCItem` on a heap at all. The item will, in this case, never be a candidate for garbage collection, but it will also never mark any of its references. In other words, this item must be a terminal leaf that has no further unique references. (One use case of this is for global constant Strings, e.g., `const String MAGNUS_STRING("Magnus")`.)

When a `GCItem` is destructed (regardless of whether it is from automatic garbage collection or not), it is removed from the list it belongs to. This enables heaps to contain a mixture of automatically garbage-collected and manually memory-managed items. It also means that it is always ok to manually delete an item (including managed items) once you are done with it provided that you can guarantee that it can no longer be reached, of course. This might ease the burden on the garbage collector and speed up allocation.

Every sub-class of `GCItem` is responsible for overriding `gcMarkReferences(Heap& heap)` to mark all `GCItem`s it references (via the overloaded `gcMark(heap, ...)` functions). Remember also to call the super-class's `gcMarkReferences` in the overridden method. If `gcMarkReferences` is implemented incorrectly, items that are still in use may get garbage collected (= deadly sin).

Garbage collection is either invoked manually with `Heap::gc()` or automatically via `Runtime::autoGC()`. Automatic garbage collection occurs when the number of bytes on a heap reaches a threshold that is two times the heap's size after the last garbage collection. It is also possible to impose a hard limit on the heap's size.

## Creating Strings

Strings store UTF‑16 data. When a new string should live on a heap, you may allocate it directly with `new(heap) String(heap.managed(), text)` or use the helper `String::allocate(heap, "text")`. Temporary root strings can be constructed on the stack using `String(heap.roots(), ...)`. Global constant strings can be created without a heap using `String string("text")`.

Note: `wchar_t` strings are converted based on the native size of `wchar_t` - UTF‑16 when it is 16 bits and UTF‑32 when it is 32 bits. Plain `char*` and `std::string` values are treated as ISO‑8859‑1 text for fast byte‑for‑byte copying. Use wide strings when full Unicode input is required.

NuXJS provides several convenience routines for constructing managed strings:

```
String::allocate(heap, "foo")			 // copy from ISO-8859-1 literal
String::concatenate(heap, left, right)	 // join two existing strings
String::fromInt(heap, 42)				 // formatted integer (cached for -1000..1000)
String::fromDouble(heap, 3.14)			 // formatted double with special handling for NaN/Inf
```

`String::fromInt` and `String::fromDouble` return pointers to static constant strings for small integers and special floating point values. For other values, a fresh heap string is created every call.

## Exception Handling

JavaScript code uses ordinary `throw` statements and `try`/`catch` blocks. When an exception propagates to C++, a `ScriptException` is thrown. It owns the underlying `Error` object and exposes its message through `what()`. Compilation errors are reported via `CompilationError`, which additionally stores the filename, character offset, and line number. The runtime may also throw a `ConstStringException` for conditions such as running out of memory or hitting a timeout. Embedding code typically catches `ScriptException`:

```cpp
try {
	rt.run("someScript();");
} catch (const ScriptException& ex) {
	std::wcerr << ex.what() << std::endl;
}
```

Native functions can raise script errors using `ScriptException::throwError(heap, type, message)`. This helper creates a JavaScript `Error` instance and throws it as a `ScriptException` so that JavaScript can catch it normally:

```cpp
if (touchFunction.typeOf() != &FUNCTION_STRING) {
	ScriptException::throwError(heap, GENERIC_ERROR, "cannot compile JS gui-variable (touch is not a function)");
}
```

When your native code may throw exceptions of its own, convert them to script errors so JavaScript callers can handle them:

```cpp
Var loadFile(Runtime& rt, const Var&, const VarList& args) {
	Heap& heap = rt.getHeap();
	try {
		const String* filenameString = args[0];
		const std::string filenameUTF8 = filenameString->toUTF8String();
		std::ifstream f(filenameUTF8.c_str());
		if (!f) {
			ScriptException::throwError(heap, GENERIC_ERROR, "failed to open file");
		}
		// read file here
	} catch (const std::exception& e) {
		ScriptException::throwError(heap, GENERIC_ERROR, e.what());
	} catch (...) {
		ScriptException::throwError(heap, GENERIC_ERROR, "native exception");
	}
	return Var(rt);
}
```

> **Note:** `String::toUTF8String()` preserves every ECMAScript code unit by returning WTF-8. Embedders that hand the
> resulting buffer to strict-Unicode facilities should validate or sanitise before bridging across the boundary.

## Standard Library and JavaScript Features

The engine ships with a standard library implemented in JavaScript, providing the objects described in ECMAScript&nbsp;3. It also offers selected ECMAScript&nbsp;5 functionality including JSON and string indexing.

During the build, `src/stdlib.js` is minified and translated into `src/stdlibJS.cpp` with `PikaCmd`. Simply compiling this generated file alongside `NuXJS.cpp` brings in the standard library. Keeping the bulk of the library in JavaScript makes the core C++ code smaller and allows the VM to run the library asynchronously, which is a primary design goal.

## Conformance and Known Limitations

The **es5 build** (`NUXJS_ES5`) implements ECMAScript 5.1: strict mode, accessor properties, the full 8.12.9
`[[DefineOwnProperty]]` machinery, the `Object` reflection statics, `Function.prototype.bind`, the Array iteration
methods, `String.prototype.trim`, the URI handlers, `Date.now` and the rest of the 15.9 additions. Its deviations are
few, deliberate, and each documented with its rationale in `docs/notes/ECMAScript Compatibility Notes.md`; conformance
is measured against Test262 (see `docs/Test262 Dashboard.md` and the numbers in the README). The **es3 build** is the
original, fully ECMAScript 3 compatible core, kept byte-for-byte stable while the es5 build evolves.

### Deviations shared by both builds

- `\0` is interpreted as a null character only when no digit follows it. Octal escapes are not supported: `\1` through `\7`, and `\0` followed by any digit, are rejected with `SyntaxError: Invalid escape sequence` rather than decoded. This is what the core grammar of both editions says (octal lives in Annex B, which NuXJS does not implement).
- Unicode line separator (`\u2028`) and paragraph separator (`\u2029`) are treated as linefeeds. The zero-width no‑break space (`\uFEFF`) counts as white space only in the es5 build, since ES5.1 7.2 lists it and ES3 7.2 does not.
- Case conversion, identifier classification and the `<USP>` white space class are all derived from Unicode 3.0. Both editions ask for a minimum version ("2.1 or later" in ES3, "3.0 or later" in ES5.1), so this conforms, but it parts company with modern engines in three places. The zero width space (`\u200B`) counts as white space, because it is category Zs in Unicode 3.0 and only became a format character in 4.0.1. `"\u10A0".toLowerCase()` returns its argument unchanged, because Unicode 3.0 made Georgian unicameral, where later versions map it to `\u2D00`. `\u2118` and `\u212E` are rejected in identifiers, because ES3 defines those by Unicode category and both are symbols in Unicode 3.0; ES2015 grandfathered them back in with `Other_ID_Start`. Case conversion also skips SpecialCasing's conditional Final_Sigma rule (see the compatibility notes).
- Implicit `valueOf` and `toString` conversions may happen earlier than specified, for example, `v[o]++` only invokes `toString()` once.
- Every created function has a writable and configurable, but *non-enumerable*, `name` property (a NuXJS extension; ES5.1 defines no `name`), and its `length` property is read-only and cannot be deleted, as ES5.1 requires.
- Case-insensitive ranges in regular expressions and zero-length captures inside repeats may not perfectly match other engines.
- A semicolon is required after `do ... while` statements. This matches the ES3 and ES5 grammar, even though ES6 made the semicolon optional.
- Creating a numeric property on an *array* can shadow a read-only numeric property in the prototype chain. This falls out of an optimization for array element writes and does not apply to ordinary objects, where the read-only property in the prototype still wins.
- Own-property enumeration order is the hash table's, not insertion order, and a lookup can transpose adjacent entries (see the compatibility notes).
- Octal (`0o`) and binary (`0b`) prefixes are not understood when converting strings to numbers - an ES6 addition, so this conforms to both target editions.
- Recursive grammar constructs are limited to `MAX_NESTED_COMPILE_DEPTH` (256) levels to avoid a C++ stack overflow; exceeding it raises a `RangeError` at compile time. `JSON.parse` / `JSON.stringify` similarly cap nesting at `MAX_JSON_DEPTH` (61).
- Several tests under `tests/unconforming` demonstrate additional corner cases.

### es3 build only

These are resolved in the es5 build and remain only in the frozen es3 core:

- Custom property getters and setters are not implemented.
- `Object.defineProperty` only accepts plain data descriptors (`value`, `writable`, `enumerable`, `configurable`). Missing
  fields default to `false`, accessors are ignored, and descriptor invariant checks are not performed - redefining a
  non-configurable property silently does nothing instead of throwing. The call always returns `undefined`. `Object.getOwnPropertyDescriptor` and
  `Object.defineProperties` are not implemented.
- The `arguments` object follows ES3 mapping semantics; changing element attributes does not fully emulate the ES5 behaviour. Its elements do not appear in `for...in` enumeration, and `Object.prototype.toString` reports `[object Object]` for it where ES5.1 10.6 gives it the class `"Arguments"`.
- Evaluation order of member expressions follows the ES3 order (object and arguments evaluated before selecting the member); the es5 build resolves the callee before evaluating the arguments, as 11.2.3 requires.
- When the target of an assignment is a plain identifier, the right-hand side is evaluated before that identifier's binding is resolved, so a variable the right-hand side brings into scope becomes the assignment's target (see `tests/es3only/rightSideBeforeAssignmentRef.io`). This applies to identifier bindings only; a member expression on the left is evaluated in full before the right-hand side, as ES3 11.13.1 requires. The es5 build resolves the target up front and keeps the reference on the value stack.
- When the identifier of a `catch` clause is called as a function, its `this` value is the global object (ES3 would pass the catch scope object; ES5.1 10.4.3 makes the global - or `undefined` in strict code - the conformant answer, so only the es3 build deviates).
- In regular expressions the lookahead operators `?=` and `?!` cannot be quantified as in ES3; they behave like the ES5 assertions.
- Assigning an object to an array's `length` property is unsupported; attempts throw `RangeError` instead of converting the value. The es5 build converts it as 15.4.5.1 requires.
- `for...in` throws a `TypeError` when the object is `null` or `undefined`, where ES5.1 12.6.4 just skips the loop.
- Function `prototype` properties are enumerable on user-defined functions, where ES5.1 13.2 makes them `{ DontEnum }`.
- A `"use strict"` directive is an ordinary string expression statement here and does nothing: ES3 has no strict mode. Code carrying the directive runs unchanged, so it is worth knowing that the same code becomes strict the moment it is run on the es5 build, where an assignment to an undeclared variable throws instead of creating a global, `this` is `undefined` rather than the global object in a plain call, and `with` and a duplicate parameter name are SyntaxErrors.
- The URI handlers (`decodeURI` and friends), the Array iteration methods, `Function.prototype.bind`, `String.prototype.trim`, `Date.now`, `Object.keys` and the other reflection statics exist only in the es5 build.

### ES5 features available in the es3 build

The es3 build has always carried a small subset of ES5 conveniences:

- `Array.isArray`.
- `Object.getPrototypeOf`.
- `Object.defineProperty`, with the data-descriptor limitations listed above.
- `JSON.parse` and `JSON.stringify`.
- String objects allow indexed access to individual characters.
- `String.prototype.match` returns `null` for global patterns with no match and always uses the built-in `RegExp.prototype.exec` implementation.
- `eval()` distinguishes between direct and indirect calls.
- Many `Date` object features introduced in ES5, `toISOString` and `toJSON` included.
- Unicode format control characters are preserved in source text.

### ES6-inspired extras

- `Array.prototype.splice` with a single argument deletes the rest of the array.
- Regular expression flags cannot contain Unicode escapes.

### ECMAScript oddities

NuXJS also implements several spec corner cases that are easy to overlook when embedding the engine:

- **Hidden `ToObject` on every property access.** The specification converts primitive bases to objects before retrieving a property. Strings would therefore need a wrapper object for every indexed read. The engine uses _shallow_ string wrappers so indexing does not allocate, while method calls still turn `this` into a full `String` object as required.
- **`catch (x)` really is its own scope.** A catch clause introduces a new declarative environment that shadows outer bindings and must be visible to `eval`. NuXJS creates a transient `CatchScope` at run time so dynamic code inside the block sees the correct variable.
- **Built-ins can distinguish call vs construct.** Native functions may have separate `[[Call]]` and `[[Construct]]` paths. User-defined functions cannot emulate this because they share one body. Built-ins in `stdlib.js` use `support.distinctConstructor` to implement behaviours like `String` where the result differs when invoked with `new`.

## Testing and Benchmarking

The test suite resides in the `tests/` directory and is exercised by running the helper script `tools/buildAndTest.sh`. Additional benchmark programs are found under `benchmarks/`.

## Contributing

Patches should be validated by running `./build.sh` before submission. Follow the existing C++03 style (avoid STL containers) and adhere to the naming conventions listed above.

### Source Code Conventions

- `const String&` arguments never saves pointer to the argument, temporary (unmanaged) instances of `String()` are
  allowed.
- `getXXX()` implies that there will be an assertion failure if the value is not of type XXX.
- `asXXX()` implies that zero will be returned if the value is not of type XXX.
- `toXXX()` implies that the value will be converted to type XXX if necessary and an exception might be thrown if it is
  not possible.

## License

NuXJS is released under the terms of the BSD&nbsp;2‑Clause license. See the `LICENSE` file for details.
