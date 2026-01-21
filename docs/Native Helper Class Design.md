# Native Helper Class Design Options in NuXJS

This document summarizes approaches for designing native helper classes that blend C++ storage/acceleration with
JavaScript-friendly APIs. It references NuXJS's documented object hooks and the example custom object usage to
ground the recommendations in engine behavior.

## Goals and constraints observed in NuXJS

* **Property semantics are defined by `Object` hooks** (`getOwnProperty`, `setOwnProperty`, enumerators, and
  `getPrototype`), with prototype chain fallback occurring when `getOwnProperty` returns `NONEXISTENT`.
* `JSObject` (and `LazyJSObject`) provides a full property-table implementation, while custom subclasses of
  `Object` can avoid table overhead and provide their own storage.
* Host objects must use flags to enforce JavaScript-like rules (read-only, non-enumerable, non-configurable).

These behaviors are described in NuXJS Documentation under “Implementing Custom Native Objects,” and they define
what is possible in each design below.【F:docs/NuXJS Documentation.md†L98-L142】

The `docs/examples/examples.cpp` example of `Counter` shows a lightweight object that uses a prototype defined
in JavaScript space but backed by C++ state. That example is valuable as a reference point for native helper
patterns and is summarized later in this document.【F:docs/examples/examples.cpp†L80-L129】

## Recap of the current pattern

Your `NativeFloat32Array` pattern does the following:

1. Stores data in a native `Vector<float>` for tight loops.
2. Exposes indexed reads via `getOwnProperty` and indexed writes via `setOwnProperty`.
3. Manually exposes native methods by string-compare in `getOwnProperty`.
4. Lets JavaScript fill out the prototype with higher-level functionality.

The friction points you noted (string compares on each property lookup, “native methods overriding prototype
methods,” and limited ability to replace native methods) flow directly from the decision to surface methods
through `getOwnProperty` instead of a JS property bag.

The rest of this document focuses on alternative approaches that preserve the performance-critical core while
improving JS ergonomics and reducing lookup overhead.

---

## Approach A: `JSObject` or `LazyJSObject` with a native data payload

**Core idea:** use `JSObject`/`LazyJSObject` for property storage and keep the native data as a C++ member, so
methods are normal JS properties (or functions) instead of string-compare dispatch.

**How it works:**

* Derive from `JSObject` (or `LazyJSObject`) and expose a `data` member (or pointer) that stores the native
  vector. `JSObject` handles method properties like any other JS object (including fast hash lookups and
  prototype overrides).
* Populate the prototype in C++ once (during startup or at class creation), or allow JavaScript to mutate
  it later without special-case native logic.

**Strengths:**

* **Prototype overrides behave naturally**, because methods are ordinary JS properties, not special-cased in
  `getOwnProperty`.
* **Lower dispatch overhead** than repeated string compares; `JSObject` uses a property table and can be
  lazily allocated when necessary.【F:docs/NuXJS Documentation.md†L125-L132】
* **Simpler integration with `Object::setProperty`** and `updateOwnProperty`.

**Trade-offs:**

* Slightly higher memory overhead for the `Table` storage (though you can keep it lazy).
* If you still want “index access without real properties,” you may need to override
  `getOwnProperty`/`setOwnProperty` for indices and then defer to `JSObject` for everything else. This is
  possible but requires careful ordering so prototype lookups behave correctly.

**Pattern sketch:**

* `getOwnProperty` checks for array indices, then defers to `super::getOwnProperty` for other keys.
* `setOwnProperty` similarly updates indices or defers to `super::setOwnProperty`.
* Methods and constants live in JS space as normal properties.

---

## Approach B: Hybrid “native indexed access + JS prototype bag”

**Core idea:** keep your existing indexed handling in C++ but move method exposure out of `getOwnProperty` by
attaching a JS prototype object whose properties are purely JavaScript or pre-bound native functions.

**How it works:**

* `getOwnProperty`/`setOwnProperty` only handle numeric indices and the `length` slot; everything else returns
  `NONEXISTENT`, letting the prototype chain resolve the method.
* Create a prototype object in C++ during initialization and attach native functions there (or allow JS to do
  it in a bootstrap file).

**Strengths:**

* Eliminates string-compare method dispatch in `getOwnProperty` for method lookups, because non-index keys
  fall through to the prototype chain.
* Preserves the tight native storage for indices while making function overrides behave like standard JS.

**Trade-offs:**

* You need a clean way to create the prototype and retain it for new instances.
* If your instance uses `LazyJSObject` and also wants an internal JS property bag, you still need to decide
  whether to allow instance methods to be installed directly on the object or only via the prototype.

---

## Approach C: Native method table, but cached or pre-interned for fast lookup

**Core idea:** keep the current method table and `getOwnProperty`-based dispatch, but make it faster by
pre-interning method keys or caching the most common lookups.

**How it works:**

* Store the `String*` pointer for method names in static globals, or use a small perfect-hash/lookup table
  keyed by pointer identity (interned strings) instead of repeated `isEqualTo` calls.
* Optionally keep a tiny per-instance cache for recent keys, if the engine has no internal caching for
  repeated property accesses.

**Strengths:**

* Minimal changes to your current architecture.
* Keeps method exposure entirely in C++ when you want it.

**Trade-offs:**

* **Still non-idiomatic JS** in terms of property override rules; overrides require special handling or
  fallback logic.
* Doesn’t solve the “method override” story unless you explicitly return `NONEXISTENT` when a JS override
  exists (which requires a more complex lookup sequence).

---

## Approach D: Pure host object + JS wrapper class

**Core idea:** expose a minimal native object to JS (only data + a small set of native functions), then wrap it
in a JS class that owns the native object as a hidden slot or internal property.

**How it works:**

* Native object is not used directly as the JS instance. Instead, the JS constructor creates the native object
  and stores it in a property like `_native`.
* All JS methods forward to `_native` as needed.

**Strengths:**

* **Full JS control over method surfaces**, including `toString`, subclassing, and method overrides.
* Native methods remain internal and can be smaller in number.

**Trade-offs:**

* Every operation is one level of indirection.
* Requires conventions for hiding the native pointer (non-enumerable property or symbol-like slot). NuXJS
  does not expose symbols, so you need a naming convention and non-enumerable flags.

---

## Approach E: Engine-integrated typed array style (native fast path + JS spec surface)

**Core idea:** implement the native class as an engine-backed intrinsic and mirror the TypedArray pattern:
C++ handles storage and indexed behavior, while JS surface methods are standard function objects installed on
`Float32Array.prototype`.

**How it works:**

* `getOwnProperty`/`setOwnProperty` handle indices and (optionally) `length`.
* JS defines `Float32Array` constructor and methods, but native class instances store the data.
* Methods are free to operate on “this” by checking the class name and reading the native payload.

**Strengths:**

* Matches how JS environments typically expose typed arrays.
* Prototype overrides are normal JS operations.

**Trade-offs:**

* Requires a consistent “brand” check (like `checkedThis`) to validate that the JS method is used on the
  correct native instance.
* Requires a clear story for `instanceof` and `getClassName` checks.

---

## Approach F: Use `Object` hooks directly with small, specialized property dispatch

**Core idea:** skip `JSObject` and use custom hooks for properties you care about, but separate method lookup
from indexed lookup by using internal identifiers or a controlled lookup path.

**How it works:**

* `getOwnProperty` handles indexed access + a small, fixed set of slots.
* Any method dispatch happens through a custom `getOwnProperty` subroutine that compares only a known small
  list of keys.

**Strengths:**

* Lean storage, minimal overhead.
* Explicit behavior, easy to profile and control.

**Trade-offs:**

* The more method keys you add, the less maintainable it becomes.
* Still has the same JS override limitations unless you explicitly check for overrides in a separate
  prototype bag.

---

## Comparison: `examples.cpp` Counter vs. the NativeFloat32Array pattern

The `Counter` example uses a native object (`Counter`) but attaches behavior via a prototype object created in
C++ and then stored in the instance at construction time. The method (`increment`) is installed on the
prototype, not returned from `getOwnProperty`. This means property lookup behaves like ordinary JS prototype
resolution and is a good reference for a more JS-consistent approach.【F:docs/examples/examples.cpp†L80-L129】

Compared with `NativeFloat32Array`:

* `Counter` avoids per-access string comparisons inside `getOwnProperty` for methods; it uses the prototype
  chain as intended.
* `NativeFloat32Array` blends data and methods directly in `getOwnProperty`, which is convenient but shifts
  method overrides away from standard JS semantics.

If your goal is JS ergonomics, the `Counter` approach is closer to what most JS embedders do. If your goal is
absolute minimal property overhead and you are comfortable with custom semantics, the existing `NativeFloat32Array`
pattern is viable but should be optimized (caching or interning) to reduce lookup costs.

---

## Practical recommendations (ordered by JS ergonomics)

1. **Preferred for JS semantics:** Approach B or E
   * Move method exposure to the prototype chain, keep native storage for indexed data, and let `getOwnProperty`
     only handle indices + `length`.
   * This preserves performance-critical loops in C++ and keeps method overrides consistent with JS.

2. **Best for minimal invasive change:** Approach C
   * Keep method dispatch in C++ but use interned `String*` or a faster dispatch table. Consider one-time
     initialization of method keys.

3. **Best for maximal JS flexibility:** Approach D
   * JS wrapper class with a `_native` slot works well if you want custom toString, subclassing, or full
     JS-level replacements without fighting internal semantics.

4. **Best for property-table reuse:** Approach A
   * Use `LazyJSObject` for methods and still override indexed access for data. This can be a clean hybrid
     when you want a true JS object with custom indexed semantics.

---

## Implementation notes and NuXJS-specific considerations

* **Prototype creation:** follow the `Counter` pattern where the prototype object is created once and passed
  to native constructors, or a JavaScript bootstrap file sets up the prototype after binding the constructor.
* **Property flags:** if you expose method properties from C++, mark them `HIDDEN_CONST_FLAGS` or
  `STANDARD_FLAGS` depending on whether you want them enumerable or writable. Refer to the documented property
  hook semantics in the NuXJS docs for consistent behavior.【F:docs/NuXJS Documentation.md†L98-L142】
* **Avoiding expensive comparisons:** prefer interned `String*` comparisons or hashed tables if you must
  handle keys in C++.
* **Index handling:** keep `getOwnProperty` fast by checking `toArrayIndex` first and return `NONEXISTENT` for
  non-indices. This lets the prototype chain resolve methods and helps avoid mixing data and method lookups.
* **GC safety:** continue to override `gcMarkReferences` when storing a prototype or any heap objects.

---

## Suggested next steps for the NativeFloat32Array design

1. **Move method lookup to prototype:** expose native methods on the prototype (created in C++ or JS) and let
   `getOwnProperty` handle only indices and `length`.
2. **Keep the C++ data backend:** preserve the current native fast paths for `add`, `mul`, `compare`, etc., but
   route them through prototype functions that use `checkedThis` to verify the native backing.
3. **Optional:** experiment with `LazyJSObject` as a base class to reduce the need for custom property storage
   if you want to install methods directly on the instance for certain scenarios.

These steps match the behavior in the documented `Counter` example and align more closely with standard JS
object semantics while retaining performance-critical native operations.
