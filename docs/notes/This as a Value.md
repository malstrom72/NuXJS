# `this` as a `Value`

Working note for the last open item of `docs/ES5.1 Roadmap.md` §5 - carrying the receiver as a `Value` instead of
an `Object*`, so a strict function sees a primitive or `null` `this` verbatim (10.4.3). **Done**; the roadmap entry
carries the summary and this note keeps the reasoning and the traps, which the next person touching the receiver
path will want.

Everything is behind `#if NUXJS_ES5`. The es3 release binary stayed byte-identical across every step (design rule
D1), so each ES3 branch is the verbatim original, never a restructured version of it.

## The one idea

The receiver used to be coerced in *four* places: `Value::toObjectOrNull` inside `callWithArgs`, inside
`BoundFunction::invoke`, `convertToObject` inside `GET_METHOD_OP`, and the global substitution in
`Processor::enter`. ES5.1 coerces in exactly *one*: entry to non-strict **function code** (10.4.3). Built-ins get
the this value unmodified and do their own `CheckObjectCoercible` / `ToObject` per clause, which is why
`Object.prototype.toString.call(null)` can answer `[object Null]` at all. In NuXJS the built-ins are JS, not
natives, so this only works because the `Object.prototype`, `String.prototype` and `Array.prototype` tables sit
inside guarded strict IIFEs - a non-strict built-in would have its receiver substituted at frame entry and could
never see the `null`.

So: the receiver flows as a `Value` end to end, and `enter` is the single coercion point. Do **not** carry a
primitive alongside the `Object*` - two receivers on every call path is the accreting data model
`docs/Coding Style.md` §2 rules out.

## The alias, which is what made it tractable

77 textual sites carry the receiver: 36 native tails (`, Object*)`) and 41 named `Object* thisObject` parameters.
Guarding each would have meant ~77 `#if` pairs, and **19 of the 27 natives are shared es3/es5 code**, so they could
not have been guarded cheaply at all. (The natives' *bodies* genuinely do not change - every one leaves the tail
unnamed - but their *signatures* must, or they no longer match the `NativeFunction` typedef.)

Instead, one guarded block in `NuXJS.h`:

- `Receiver` - `const Value&` in es5, `Object*` in es3. The parameter type everywhere.
- `ReceiverSlot` - `const Value` in es5, `Object* const` in es3. The `Frame` member, and the `innerRun` local,
  which must **copy** rather than bind a reference into the frame.
- `noReceiver()` - the unbound `this`, `UNDEFINED_VALUE` or `0`. This is what keeps the five default arguments
  from needing guards of their own; `= 0` against a `const Value&` would bind `Value(Int32 0)`, the *number* zero.

A typedef is transparent to type identity and mangling, so es3 codegen cannot move. That was verified by compiling
`NuXJS.cpp` and `stdlibJS.cpp` in a fixed directory before and after and comparing the objects, which is a better
gate than the binary `cmp`: it isolates the change from link paths and the Mach-O UUID.

## Traps found along the way

- **`Runtime::call`'s default.** It compiles fine with an object receiver, which is what makes it dangerous: its
  `Object* thisObject = 0` default forwarded a null pointer that becomes an `OBJECT_TYPE` `Value` holding `NULL`,
  not `isUndefined()`. `Var::call` takes that default on every receiverless `Var(fn)()`. Same trap in
  `callWithArgs` and `BoundFunction::invoke`, both of which manufactured a null `Object*` for a null or absent
  receiver. Anything that converts a possibly-null `Object*` to a `Value` is a bug, not a conversion.
- **The `Frame` constructor**, not just the member, takes the receiver - the alias covers both, but a plan that
  changes only the member compiles and silently stores the wrong thing.
- **`innerRun`'s local** (`ReceiverSlot thisObject = currentFrame->thisObject;`) is the one place where the two
  builds genuinely differ in the *type* of a local, so it can never collapse to a single unguarded line the way
  `THIS_OP` did.
- **Accessors are receivers too.** `GET_PROPERTY_OP` and `SET_PROPERTY_POP_OP` invoke a getter/setter, and 8.7.1
  step 6 / 8.7.2 step 6 hand it the *base*, not the object the lookup was resolved through. `GET_PROPERTY_OP`
  additionally overwrites the base with the read result before the accessor runs, so it needs a saved copy, not
  just a different argument.
- **Only the strict tables notice.** `String.prototype.valueOf` / `toString` broke the moment the receiver stopped
  being boxed, because the `String.prototype` table is inside a strict IIFE while `Number.prototype` and
  `Boolean.prototype` are not - those two still get their receiver boxed at frame entry, so their identical-looking
  `checkClass` entries never noticed. 15.5.4.2-3 accept a String *value*, so the es5 entries test `typeof` first;
  boxing to read the value straight back would allocate on `"s".toString()`. Whenever a table becomes strict, its
  `checkClass` callers need the same review.
- **The generics were relying on a pre-boxed receiver.** `Array.prototype` `concat`, `join`, `slice` and
  `toLocaleString` called `toObject(this, …)` purely for its throw and then read `this` raw - `slice` even does
  `i in this`. `Array.prototype.slice.call("abc", 1)` failed the moment `call` stopped boxing. They are now
  whole-entry guarded pairs reading the ToObject result, matching how `pop` / `push` / `reverse` were already
  written.
- **A template nobody instantiates is not covered by a green build.** `AccessorBase::VarMemberFunctionAdapter`
  dereferences its receiver, so the alias pass left it doing `reinterpret_cast<C*>` on a `Value`; both builds went
  green because nothing in the tree binds an unbound member function. `receiverObject()` sits in the alias block
  for exactly this case - a boundary that genuinely wants the object - and `docs/examples/examples.cpp` should
  grow a case that instantiates it.

## Gates

- **Byte identity**: compile `NuXJS.cpp` and `stdlibJS.cpp` from a fixed directory with `-DNUXJS_ES5=0` before and
  after, and `cmp` the objects. For the binary, `cmp output/NuXJS /tmp/nuxjs-es3-baseline` after `./build.sh`
  works because the link path is constant, but a cross-directory `cmp` is invalid - the Mach-O UUID differs at
  byte 1609.
- **ES3 library**: `output/stdlib.es3.js` and the es3 blob inside `stdlibJS.cpp` must both stay byte-identical.
- **V8**: the 36-cell pass-through matrix (`call`/`apply`/`bind` × `5`/`"x"`/`true`/`null`/`undefined`/object ×
  strict/non-strict) diffs clean, as do the method, getter and setter cases off a primitive base.
- **Tests**: `tests/es5/strictThisBinding.io`, `objectToStringTag.io`, `strictPrimitiveBaseAssignment.io`,
  `checkObjectCoercible.io`, and the `tests/es3only/globalsFromUndefinedOrNullThis.io` twin. Each new `.io`
  section was verified by breaking its expectation and confirming the run fails - a blank line silently skips the
  section that follows it.

## Left open

- **Perf, measured.** A primitive receiver can be boxed twice: once by `GET_METHOD_OP` for the lookup and once by
  `enter` for a non-strict callee. `GET_METHOD_OP` now boxes with `requireExtensible = false`, which it can because
  the wrapper is only walked, and which for a string returns the `String` itself and allocates nothing: a 5M-call
  `charCodeAt` loop went 3.06s -> 1.16s against the pre-change es5 build, and 100 calls allocate 8 objects rather
  than 108. Numbers and booleans do **not** benefit - `toObjectOrNull` allocates a `GenericWrapper` for them either
  way, so a method call on one went from one box to two: 2M `(255).toString(16)` went 1.54s -> 1.61s. Undoing that needs a
  lookup that takes a `Value`, which is real code, and `docs/Coding Style.md` §2 wants a measured win first.
- **A `Frame` costs 16 more bytes** in es5: the receiver went from an 8-byte pointer to a 16-byte `Value`, and with
  `GCItem`'s hidden `Heap*` the pooled block rounds 80 -> 96. Unavoidable given that carrying both was ruled out.
- **Every public receiver is a `Receiver`**, `AccessorBase::apply` included. Leaving that one as an `Object*`
  looked like a boundary worth keeping, but it was the last place a literal `0` could still be spelled, and
  `tools/NuXJSTest.cpp` was spelling it four times. The overloads are header-inline, so widening them protects no
  ABI, and in es3 `Receiver` *is* `Object*`, so the signature does not move there at all.
- **Dual-typed member**: `Frame::thisObject` is an `Object*` in one build and a `Value` in the other. Any new code
  comparing it against a pointer compiles in es3 and fails in es5, or worse. Nothing does so today; keep it that
  way.
