# ES5.1 Implementation Roadmap (clean-room)

A fresh plan to lift NuXJS from ECMAScript 3 to **ECMAScript 5.1**, written from an audit of the current
`main` engine - not derived from the 2025 attempt (`archive/es51-codex-2025`), which is kept for reference only.

Spec of record: `docs/specs/ECMA-262 5.1.md` (clause-numbered; cite clauses in tests, e.g. `8.12.9 [[DefineOwnProperty]]`).

---

## 0. Guiding principles - stay true to the ES3 engine

Every item below is subordinate to the engine's existing philosophy. If a proposed change violates one of these,
the change is wrong, not the principle.

1. **Small and single-file.** The engine stays one `.cpp` + one `.h` + `stdlib.js` (generated `stdlibJS.cpp`).
   No new source files, no new external dependencies, C++03 only.
2. **Library work lives in `stdlib.js`.** Keep the trusted C++ surface minimal. Only touch the C++ core for what
   genuinely cannot be done in JS: the property/descriptor model, parser syntax, strict-mode VM plumbing, and a
   handful of native `support` hooks. Everything else (Object.keys, Array iteration, bind, trim, …) is JS.
3. **Memory-conscious to the byte.** The `Table::Bucket` must stay `Value`-sized. Accessors are stored by
   **indirection**, never by widening the bucket (see §1). No per-property size regression for ordinary data
   properties.
4. **Sandbox and bounds are invariant.** Preserve cooperative stepping (`run(maxCycles)`), the cycle/timeout
   budgets, and the recursion/nesting/stack/prototype caps. New features must not open an unbounded or
   host-crashing path. New "must throw" ES5 semantics surface as **managed exceptions**, never asserts.
5. **Regression-test-driven, both builds green.** No roadmap item is "done" until it has an `.io` test under
   `tests/es5/` that cites its spec clause, and the **full `es3` *and* `es5` builds** pass
   (`=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===`). The ES3 build (with `NUXJS_ES5` undefined) must stay
   behaviorally identical to today - no ES3 test may regress, and ideally the ES3-compiled binary is unchanged.
   This is the hard guarantee that the engine the author is proud of remains intact underneath the lift.
6. **Deviations are documented, not hidden.** Any intentional non-conformance goes in
   `docs/notes/ECMAScript Compatibility Notes.md` (to be re-created; the README used to link it).

### Key design decisions

- **D1 - Compile-time `NUXJS_ES5` toggle; ES3 stays the untouched base. (DECIDED.)** Every ES5.1 change is
  bracketed by `#if NUXJS_ES5 … #endif` (C++) or the equivalent build-time gate (stdlib.js - see D5). Rationale:
  it makes each deviation from ES3 *individually visible in the diff*, reversible, and forces a per-change "is this
  worth it?" judgment, keeping the footprint minimal. The pure ES3 engine must still build and pass its full suite
  with `NUXJS_ES5` undefined. Build variants: `es3`, `es5`, `both` (both = default gate for CI). Discipline: guard
  additively - **prefer adding a guarded branch over rewriting an existing ES3 code path**; never let an ES5 guard
  silently change ES3 behavior.
- **D5 - Gating the JS standard library. (DECIDED - separate `stdlibES5.js`.)** ES5 library code lives in a
  standalone `src/stdlibES5.js` module; the base `stdlib.js` and the ES3 native `support` contracts are left
  byte-for-byte untouched (the archive proved that reusing base's private helpers means *rewriting* them -
  ~25% of base churned - which is why ES3 couldn't stay pristine there). `tools/stdlibToCpp.pika` minifies it
  separately (seeded with the base `@preserve` header so it inherits all keywords/globals) and emits a second
  `STDLIB_ES5_JS` string guarded by `#if NUXJS_ES5`; `setupStandardLibrary` evals + runs it after the base
  library, sharing the same `support`. The es3 embedding and binary stay byte-identical. The module uses only the
  native `support` bridge and already-installed globals - never base's closure. *(Pipeline landed with the first
  feature, `String.prototype.trim`.)*
- **D2 - Accessor storage by indirection.** Add an `ACCESSOR_FLAG`; an accessor bucket's union holds a pointer to
  a small GC item `Accessor { Function* get; Function* set; }` - a plain `GCItem`, *not* an `Object`, stored via
  its own union member so it can never be read back as a JS `Value`. Bucket size is unchanged. Ordinary data
  properties pay nothing.
- **D3 - Separate `defineOwnProperty` from assignment.** Today `Table::update` OR-s flags and can never clear them
  (`NuXJS.cpp:1434`) - correct for `[[Put]]`, wrong for `[[DefineOwnProperty]]`. Add a distinct define path that
  writes *exact* attribute bits (and can flip accessor⇄data), leaving assignment semantics untouched.
- **D4 - Keep the inverted attribute encoding.** Retain `READ_ONLY / DONT_ENUM / DONT_DELETE` (the negation of
  ES5 `writable/enumerable/configurable`); it already matches ES3 built-ins and the spec's default-false-for-new
  semantics. Just add `ACCESSOR_FLAG` and the define path.

---

## 0.5. Scaffolding (do first, no behavior change)

Pure plumbing - lands before any feature so the guard discipline exists from commit one.

- [x] Define the `NUXJS_ES5` macro and wire `es3` / `es5` / `both` variants into `build.sh`, `build.cmd`, and
      `tools/buildAndTest.sh`/`.cmd`. `both` is the default. The `es5` variant compiles with `-DNUXJS_ES5=1`,
      names its binaries `NuXJS_es5_*` (release installed as `output/NuXJS_ES5`), runs `tests/es5/` and skips
      `tests/es3only/`; the `es3` variant does the reverse.
- [x] Create `tests/es5/`; smoke feature is a real conformance item - ES5.1 §12.6.4 `for-in` over `null`/
      `undefined` enumerates nothing (guarded in `GET_ENUMERATOR_OP`). ES3 expectation moved to
      `tests/es3only/forInNullUndefined.io`; ES5 expectation in `tests/es5/forInNullUndefined.io`.
- [x] Confirmed the `es3` release binary is **byte-identical** to one built from pre-lift `main` - this is the
      baseline the whole roadmap must not disturb.

**Gate:** `es3` and `es5` both green; ES3 binary unchanged.

## 1. Object model foundation - the keystone

This is the single invasive change; everything else builds on it. Do it first, in the C++ core.

### Design guidance (lessons from the archived 2025 attempt - approach re-derived, no code reused)

The archive got the *storage* right (accessor pair behind a flag, bucket unchanged) but the *plumbing* wrong.
Rules for this implementation:

- **Core lookups stay pure.** `Object::getProperty`/`getOwnProperty` never run script. Do **not** fork the API
  into pure + Processor variants (the archive did; the pure variant then leaked raw accessor objects as values,
  and the invoke logic was duplicated at ~6 call sites).
- **Invocation has exactly two choke points.** (1) The VM: `GET_PROPERTY_OP`/`SET_PROPERTY_OP` invoke the
  getter/setter as a normal frame via the same in-place `invokeFunction` continuation that `OBJ_TO_PRIMITIVE_OP`
  already uses - cycle budget and stepping keep working; no nested run-loop reachable from script. (2) The host:
  `Var`/`Property` and native hooks go through `rt.call`, already bounded by `MAX_CROSS_CALL_RECURSION`. One
  shared inline helper extracts the pair; it is written once.
- **Leak-proof by construction.** `Accessor` is a plain `GCItem`, **not** an `Object`, and the Bucket union gets
  an explicit `Accessor*` member (same size). An accessor slot can then never be materialized as a JS `Value` -
  the type system enforces it, rather than call-site discipline.
- **No `friend` into `Table`/`Bucket`.** Native `defineProperty` routes through a proper virtual
  `Object::defineOwnProperty(rt, key, descriptor)` implementing §8.12.9 (which `JSArray`/arguments can override -
  ES5 array `length` semantics need that anyway).
- **Descriptor state is transient.** Presence bits ("was `value`/`get` specified?") live only in the stack-only
  C++ `PropertyDescriptor` during validation - never persisted into bucket flags (the archive's `HAS_VALUE_FLAG`
  mistake).
- **Re-entrancy tests are part of the definition of done:** getter that throws, getter that allocates/triggers GC,
  getter that mutates the receiver during a prototype walk, recursive getter (must die on the existing bounds as a
  managed exception, never the C++ stack).

### Property descriptors & attributes
- [x] Add `ACCESSOR_FLAG` to the `Flags` bits and a GC item `Accessor { Function* get; Function* set; }`
      (per D2: a plain `GCItem`, not an `Object`, held via its own Bucket-union member); marked in
      `Table::gcMarkReferences`. Object literals install pairs via `JSObject::defineOwnAccessor` and the
      guarded `ADD_GETTER_OP`/`ADD_SETTER_OP`. (`tests/es5/accessorProperties.io`)
- [x] `PropertyDescriptor` value type carrying `value | {get,set}` + present/attribute bits (§8.10). Stack-only as
      intended: a plain struct, never heap-allocated, and the presence bits never reach bucket flags.
- [x] `Object::defineOwnProperty(rt, key, const PropertyDescriptor&, doThrow)` implementing §8.12.9, distinct from
      `setOwnProperty`/`update`; virtual, forwarded by `LazyJSObject`. `JSArray` overrides it - see the gaps below.
- [x] `extensible` flag on `Object`. `defineOwnProperty` honors it at step 3; assignment honors it in
      `Object::setProperty` (§8.12.4 `[[CanPut]]`), which is where the spec puts the check.
- [x] `getOwnPropertySlot` returns flags plus the `Accessor*`, enough to rebuild a descriptor for reflection.

Gaps this section leaves open (pre-existing, not regressions; the array ones overlap §6):
- [ ] `JSArray::defineOwnProperty` (§15.4.5.1): no 8.12.9 validation on indices or `length`, absent attributes are
      forced false, an accessor on an index is rejected. Deviation documented in `tests/es5/objectDefineProperty.io`.
- [ ] Array `length` reports `writable: false`; §15.4.5.2 requires true, which also makes `isFrozen([])` wrong.
- [ ] `Arguments` has no `defineOwnProperty` override and reports mapped indices non-enumerable (§10.6).

### VM wiring
- [x] `GET_PROPERTY_OP` invokes getters via the standard `invokeFunction` continuation with the receiver as
      `this` (undefined getter → `undefined`). Pure `getPropertySlot` walk reports the pair; invocation only in
      the opcode. (§8.12.3, `tests/es5/accessorProperties.io`)
- [x] Property stores route through `SET_PROPERTY_POP_OP` (es5 net effect −2 + compiler-emitted `POP_OP`) so a JS
      setter frame can deposit its discarded return value; undefined setter is silently ignored (strict throw
      comes in Phase 4). (§8.12.5)
- [x] Accessors participate in the prototype chain; inherited setters run against the receiver.
- [x] Method calls split into guarded `GET_METHOD_OP` + `CALL_THIS_OP`, which also lands the ES5 11.2.3
      evaluation-order fix (callee fetched before arguments). ES3-order tests moved to `tests/es3only/` with ES5
      twins (`tests/es5/callTargetResolvedBeforeArgs.io`, `tests/es5/methodCallTypeErrorTrace.io`).

### Tests (`tests/es5/`)
- [x] accessor get/set on own and inherited properties; getter/setter `this` binding; compound/post-inc; syntax
      errors for arity and 11.1.5 duplicates. (`tests/es5/accessorProperties.io`)
- [x] re-entrancy: throwing/recursive/self-deleting getters, GC-heavy getters - all managed, never a host crash.
      (`tests/es5/accessorReentrancy.io`)
- [x] `defineOwnProperty` data→accessor and accessor→data transitions, attribute toggling, non-configurable
      rejection. (`tests/es5/objectDefineProperty.io`)
- [ ] Still uncovered: `defineProperty` on a non-extensible object (§8.12.9 step 3 has no test at all), enumerable
      `false→true` on a configurable property, accessor→accessor partial redefine, and arrays under seal/freeze.

**Gate met:** full `both` build green (1222 test files) and the es3 release binary stayed **byte-identical**.

---

## 2. Reflection stdlib (built on §1)

Pure `stdlib.js` + one upgraded native hook. Replaces the current data-only `Object.defineProperty` shim
(`stdlib.js:1875`).

- [x] Native descriptor hook - landed as a *new* `support.defineOwnProperty(obj, key, present, value, get, set,
      attribs)` routing to `Object::defineOwnProperty`, rather than by upgrading the ES3 data-only
      `support.defineProperty`, which stays for internal plumbing. Accessors, exact attributes and "leave
      unspecified fields unchanged" all work for ordinary objects; array indices still take the `JSArray` shim.
- [x] `Object.defineProperty`, `Object.defineProperties` (§15.2.3.6-7) via native `defineOwnProperty` (8.12.9) + JS `toPropertyDescriptor` (8.10.5). (`tests/es5/objectDefineProperty.io`)
- [x] `Object.getOwnPropertyDescriptor` (§15.2.3.3) and `getOwnPropertyNames` (§15.2.3.4) via native FromPropertyDescriptor + a per-type name collector. (`tests/es5/objectReflection.io`, `objectCreate.io`)
- [x] `Object.create` incl. `null` prototype and second (properties) argument (§15.2.3.5). (`tests/es5/objectCreate.io`)
- [x] `Object.keys` (§15.2.3.14, own enumerable via for-in) and `Object.getPrototypeOf` (§15.2.3.2, now throwing on non-object). (`tests/es5/objectReflection.io`)
- [x] `Object.preventExtensions / isExtensible / seal / freeze / isSealed / isFrozen` (§15.2.3.8-13), the last four
      pure JS iterating `getOwnPropertyNames` + `defineProperty`. (`tests/es5/objectExtensions.io`, `objectSealFreeze.io`)
- [x] These built-ins are **not constructable** (wrapped via `distinctConstructor`) with the standard writable / non-enumerable / configurable attributes.

### Tests
- [x] Grouped rather than one `.io` per method: `objectDefineProperty`, `objectReflection`, `objectCreate`,
      `objectExtensions`, `objectSealFreeze`. `create(null)`, freeze/seal on data properties and on a getter-only
      accessor, and graceful rejection of primitives are all covered.
- [ ] Missing: an explicit descriptor round-trip (get → re-define → compare), `isSealed(primitive)`, `seal` on an
      accessor, the `defineProperty`/`defineProperties` return value, and attribute / non-constructability
      assertions for the new built-ins (`checkAllPrototypes.io` only checks `defineProperty` and `getPrototypeOf`).

---

## 3. Parser - ES5 syntax & lexical

C++ compiler (`NuXJS.cpp`), no VM changes beyond emitting the accessor-define path from §1.

- [x] **Getter/setter in object literals**: parse `get name(){}` / `set name(v){}` and emit accessor property
      definitions (§11.1.5), including all four duplicate/collision early errors.
- [ ] **Reserved words as property keys** - implemented and verified, both as literal keys and after `.`, including
      the strict future-reserved words. Only the confirming test is missing.
- [ ] **Octal numeric literals**: `010` is still mis-lexed as `0` followed by a stray `10`. That *does* yield a
      SyntaxError, which is the right verdict for the core grammar, but it arrives by accident and the message
      depends on context (`Expected ',' or ')'` inside a call, `Syntax error` in a var initialiser); a clean
      diagnostic is all that is left. Note that `tests/erroneous/badNumericLiterals.io` currently asserts the
      accidental message, so it changes with the fix. Octal *escapes* are done, and were **not** an ES5 change -
      ES3 §7.8.4 has the identical core grammar and its own Annex B.1.2 - so they are rejected by the shared ES3
      lexer rather than behind `#if NUXJS_ES5` (see `docs/notes/ECMAScript Compatibility Notes.md`).
- [ ] **Trailing commas** - implemented and verified for both forms. Arrays are covered by
      `tests/conforming/ArrayLiteralHoleLength.io`; the object-literal case `{a:1,}` has no test.
- [ ] **Whitespace/Unicode (lower priority, own sub-phase):** `Compiler::white()` accepts only space, `\f \n \r \t
      \v`, U+00A0, U+2028 and U+2029. Missing: U+FEFF as WhiteSpace anywhere (§7.2); the rest of Zs (U+1680,
      U+2000-U+200A, U+202F, U+205F, U+3000); line-continuation (`\`+LineTerminator) in string literals (§7.8.4),
      today an explicit `\ continuation is not supported` error that `tests/erroneous/escapedLFNotAllowed.io`
      asserts; Cf format-control characters as IdentifierPart (§7.1). The runtime skipper `eatStringWhite` has the
      same gap, so `Number("\u30001")` is `NaN`. These are the items flagged in `docs/notes/Todo.md`.

### Tests
- accessor object literals; octal rejection; reserved-word keys; BOM-as-whitespace; string line continuation.

---

## 4. Strict mode - **DONE**

The largest behavioral addition. Needs both parser (directive detection) and VM (make silent failures throw).

- [x] **Directive prologue**: scan leading string-literal statements for exactly `use strict`; set a `bool strict`
      on `Code` for global, function, and eval scopes (§14.1). Nested functions inherit.
- [x] **`this` binding**: unbound `this` stays `undefined` - change `enter`'s `thisObject == 0 ? global : …`
      substitution to skip substitution when strict (§10.4.3). *Partial:* a primitive/null receiver passed via
      `call`/`apply` is still coerced; see the deferral in `docs/notes/ECMAScript Compatibility Notes.md`.
- [x] **Throw on silent failures** (the VM discarded the store-success bool at `SET_PROPERTY_OP`):
      assignment to read-only / accessor-without-setter, assignment to a property of a **primitive base** (the
      §8.7.2 special `[[Put]]`, where the store lands on a transient wrapper and is therefore never kept),
      assignment to undeclared identifier, and `delete` of a non-configurable property all throw
      `TypeError`/`ReferenceError` in strict (§8.7.2, §11.4.1, §11.13.1).
- [x] **Syntax restrictions**: `with` forbidden; duplicate parameter names; `eval`/`arguments` as binding/assignment
      targets; future reserved words; duplicate data properties in an object literal (§11.1.5); octal literals &
      escapes - all SyntaxErrors in strict (§12.10.1, §11.13.1, §7.8.3, §7.8.4).
- [x] **Strict `arguments`**: non-mapped arguments object (no parameter aliasing); `callee`/`caller` poison-pill
      throwers; `Function.prototype.caller`/`arguments` throwers (§10.6, §13.2.3). The non-mapped object keeps its
      weak back-link to the FunctionScope, since that link is what lets either side sever the other at destruction;
      only the aliasing is switched off. (`tests/es5/strictArgumentsThrowUseAfterFree.io`)
- [x] **Eval isolation**: strict direct `eval` gets its own variable environment and inherits caller strictness;
      indirect `eval` runs global and non-strict (§10.4.2).
- [x] **Read-only global constants**: `NaN`/`Infinity`/`undefined` are non-writable (§15.1.1.1-3), so a strict
      write to them throws. Lives in `stdlibES5.js`; ES3 §15.1.1 leaves them writable.

### Tests
One `.io` per rule under `tests/es5/`: `strictDirectivePrologue`, `strictThisBinding`, `strictAssignmentErrors`,
`strictSyntaxRestrictions`, `strictEvalArguments`, `strictGlobalAssignment`, `strictReservedWords`,
`strictArguments`, `strictFunctionPoison`, `strictEvalEnvironment`, `strictOctal`, `strictDuplicateProperties`,
`strictPrimitiveBaseAssignment`, `globalConstantAttributes` (with an `es3only` twin for the ES3 attributes). All
verified present. Verified against V8 as a differential
oracle, with ES5.1-vs-modern divergences arbitrated by the spec and logged in `docs/specs`.

---

## 5. Function semantics

- [ ] `Function.prototype.bind` → a `BoundFunction` with correct partial application, `[[Construct]]` behavior,
      `length = max(0, target.length - bound args)`, and `name = "bound " + target.name` (§15.3.4.5). Prefer a small
      native helper wrapped by `stdlib.js`, consistent with how `apply`/`call` are done.
- [ ] Function `length`/`name` become read-only/non-enumerable; `prototype` non-enumerable (§15.3.5).
- [ ] Named `FunctionExpression` binding lives in its own declarative environment (§13) so it doesn't leak via
      `Object.prototype`.
- [ ] `Function.prototype.toString` returns source text; throws `TypeError` for non-functions (§15.3.4.2).

### Tests
- bind partial application + `new`; bound `name`/`length`; named-function-expression scope isolation.

---

## 6. Array & String library (mostly `stdlib.js`)

- [x] Array iteration: `forEach, map, filter, some, every, reduce, reduceRight, indexOf, lastIndexOf` (§15.4.4.14-22),
      spec-accurate on callback args, `thisArg` and **sparse** arrays (`k in O`, not naive loops). Pure
      `stdlibES5.js`. They sit in a strict IIFE for two reasons the spec forces: strict so a null `this` survives to
      the ToObject step instead of being replaced by the global (§10.4.3), and each takes exactly one formal
      parameter with the optional second read from `arguments`, because §15.4.4.x fixes their `length` at 1.
      (`tests/es5/arrayIteration.io`, `arrayReduce.io`, `arraySearch.io`)
- [x] `Array.isArray` (§15.4.3.2) - verified: `arguments` and `{length:0}` are false, `Array.prototype` is true.
      Needs a test.
- [ ] Generic behaviors: `sort` with no comparator and `toLocaleString` are already correct and generic over
      array-likes. Still broken: `push` succeeds on a non-extensible array, and `length` truncation ignores
      non-configurable elements. Both need §15.4.5.1, so they land with the §1 array gap.
- [x] `String.prototype.trim` with the full ES5 WhiteSpace + LineTerminator set (§15.5.4.20) - first
      `stdlibES5.js` feature, proving the pipeline. (`tests/es5/stringTrim.io`) Its CheckObjectCoercible guard was
      dead until it moved into the strict block: a non-strict built-in never sees a null `this`.
- [x] String character indices are non-writable, non-configurable own data properties (§15.5.5.2) - already
      conformant (`writable:false enumerable:true configurable:false`). Needs a test.

### Tests
- iteration methods incl. sparse/`thisArg`/early-exit; `sort` no-comparator; `trim` unicode; string index immutability.

---

## 7. Number / Date / JSON / global refinements

- [ ] `Number.prototype.toFixed / toExponential / toPrecision` (§15.7.4): ES5 range checks and rounding verified
      correct. The one gap left is `toFixed` precision - `(1000000000000000128).toFixed(0)` loses the last digits
      (the existing TODO in `docs/notes/Todo.md`).
- [ ] `Date.now` (§15.9.4.4) - missing entirely. `toISOString`/`toJSON` work and non-finite → `null`, but `toJSON`
      is not generic (explicit TODO at `stdlib.js:1002`). `Date.parse` handles the ISO date-time form but reads the
      date-only form as local time where §15.9.1.15 says UTC, and has no legacy fallback (§15.9.4.2).
- [ ] `Number.isNaN`/`isFinite` shims (ES6, not ES5.1). `parseInt`/`parseFloat` radix and no-octal behaviour already
      match ES5 (§15.1.2); their whitespace handling pends §3's Zs work.
- [x] JSON reviver/replacer/space (§15.12) - verified working, including array and function replacers, `space`
      indenting and `toJSON` dispatch. The depth-cap deviation stays documented. Needs a test.
- [x] Global `NaN`/`Infinity`/`undefined` read-only (§15.1.1) - landed in §4 via `stdlibES5.js`.
- [ ] `Object.prototype.toString` → `[object Undefined]`/`[object Null]` for those receivers; `[object Arguments]`
      for arguments objects (§15.2.4.2). All three still report `[object Object]`.
- [x] `for-in` over `null`/`undefined` yields an empty iteration rather than throwing (§12.6.4) - landed in §0.5.

### Tests
- number formatting ranges/rounding; `Date.now`/ISO parse; global constants read-only; toString tags; for-in null.

---

## 8. Conformance, docs & tooling

- [ ] Retarget the Test262 dashboard to ES5.1: re-categorize the currently-excluded `ES >3` set, import the ES5.1
      section, and track pass/fail (`tools/testdash.*`, `docs/Test262 Dashboard.md`).
- [ ] Re-create `docs/notes/ECMAScript Compatibility Notes.md` documenting every intentional deviation (JSON depth
      cap, any Unicode gaps, etc.).
- [ ] Update `README.md` scope ("ES5.1" instead of "ES3 + focused ES5"), `docs/NuXJS Documentation.md`,
      `docs/notes/TypeScript Compatibility.md`, and `docs/examples/lib.NuXJS.d.ts`.
- [ ] Refresh the ES3-compliance numbers in the README from an actual dashboard run.

---

## Sequencing summary

```
§0.5 Scaffolding (NUXJS_ES5 guard + build variants + tests/es5)
   │
§1 Object model (C++, keystone)
  └─ §2 Reflection stdlib ─┐
§3 Parser syntax           ├─ §5 Functions ─ §6 Array/String ─ §7 Number/Date/JSON ─ §8 Conformance & docs
§4 Strict mode ────────────┘
```

§0.5 first, then §1 must land and stay green. §2-§4 can proceed in parallel once §1 is stable; §5-§7 are largely independent
`stdlib.js` work gated by the object model and strict-mode plumbing. Each item is a small, test-backed commit; the
full suite stays green at every step.
