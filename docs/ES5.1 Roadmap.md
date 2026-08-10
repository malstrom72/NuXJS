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
   (`=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===`). The ES3 build (with `NUXJS_ES5` at 0) must stay
   behaviorally identical to today - no ES3 test may regress, and ideally the ES3-compiled binary is unchanged.
   This is the hard guarantee that the engine the author is proud of remains intact underneath the lift.
6. **Deviations are documented, not hidden.** Any intentional non-conformance goes in
   `docs/notes/ECMAScript Compatibility Notes.md` (to be re-created; the README used to link it).

### Key design decisions

- **D1 - Compile-time `NUXJS_ES5` toggle; ES3 stays the untouched base. (DECIDED.)** Every ES5.1 change is
  bracketed by `#if NUXJS_ES5 … #endif` (C++) or the equivalent build-time gate (stdlib.js - see D5). Rationale:
  it makes each deviation from ES3 *individually visible in the diff*, reversible, and forces a per-change "is this
  worth it?" judgment, keeping the footprint minimal. The pure ES3 engine must still build and pass its full suite
  with `NUXJS_ES5` at 0. `NuXJS.h` defaults the macro to 1, so both variants pass it explicitly and an unflagged
  build is es5; 0 and undefined preprocess alike, every guard being `#if` rather than `#ifdef`, so D1 byte identity
  is unaffected. Build variants: `es3`, `es5`, `both` (both = default gate for CI). Discipline: guard
  additively - **prefer adding a guarded branch over rewriting an existing ES3 code path**; never let an ES5 guard
  silently change ES3 behavior.
- **D5 - Gating the JS standard library. (DECIDED - `//#if ES5` guards inside `stdlib.js`.)** All ES5 library code
  lives in `src/stdlib.js` behind `//#if ES5` / `//#if !ES5` / `//#else` / `//#endif`, which
  `tools/stdlibToCpp.pika` resolves twice before minification, emitting both variants under one `#if NUXJS_ES5`.

  ES5 code was originally forbidden to touch `stdlib.js` at all, and lived in a standalone `src/stdlibES5.js`
  module, because the archived attempt showed that reusing base's private helpers meant *rewriting* them, churning
  ~25% of base and losing the pristine ES3 source. That ban cost real duplication, all of it forced by the closure
  boundary rather than by the language: a second `ToInteger`, a second whitespace set, a `parseInt` wrapper, a
  second capture block, and a `method()` that was a near-copy of `defineProperties`. What the ban was protecting is
  now checked rather than assumed: the generator re-emits the pure ES3 source to `output/stdlib.es3.js` on every
  build, and both it and the ES3 blob must stay byte-identical. See `docs/Standard Library Guidelines.md`.
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
      `tests/es3only/`; the `es3` variant does the reverse with `-DNUXJS_ES5=0`. `src/stdlibJS.cpp` includes
      `NuXJS.h` so the header's default reaches the library blob too, an unflagged build otherwise pairing an es5
      engine with the es3 library.
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
- [x] `JSArray::defineOwnProperty` implements §15.4.5.1: length maintenance, per-index 8.12.9 validation, accessors
      on indices, and truncation that deletes from the top down and stops below a non-deletable element.
      (`tests/es5/arrayDefineOwnProperty.io`)
- [x] Array `length` now reports `writable: true` until cleared (§15.4.5.2), tracked by its own flag so
      `defineProperty(a, "length", {writable: false})` sticks and blocks any later growth or shrink.
- [x] `Arguments::defineOwnProperty` implements §10.6, including the parameter map that step 5 keeps or severs, and
      indices are enumerable as §10.6 (11)(b) says (ES3 §10.1.8 made them DontEnum). The attribute bits of an index
      still in its slot ride in the spare bits of the existing per-index byte, so the object grew by nothing.
      (`tests/es5/argumentsDefineOwnProperty.io`, and the `Arguments2.io` / `Arguments3.io` twins whose ES5
      expectations were already sitting commented out in `tests/es3only/`)

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
- [x] §8.12.9 step 3 is now covered, and was genuinely broken: a lazy object forwards to its complete object, which
      carries its own extensible flag, so `preventExtensions` then `defineProperty` succeeded on functions as well as
      arrays. Arrays under seal/freeze are covered too.
- [ ] Still uncovered: enumerable `false→true` on a configurable property, and accessor→accessor partial redefine.

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

## 3. Parser - ES5 syntax & lexical - **DONE**

C++ compiler (`NuXJS.cpp`), no VM changes beyond emitting the accessor-define path from §1.

- [x] **Getter/setter in object literals**: parse `get name(){}` / `set name(v){}` and emit accessor property
      definitions (§11.1.5), including all four duplicate/collision early errors.
- [x] **Reserved words as property keys** - all 45 of them (§7.6.1.1 keywords, §7.6.1.2 future reserved words
      including the strict-only set, and the `null` / `true` / `false` literals) as literal keys, after `.`, in
      `delete`, with a trailing comma and in strict code. NuXJS accepts them in the es3 build too, so the test is
      shared rather than an es5 twin. (`tests/conforming/reservedWordsAsPropertyNames.io`)
- [x] **Octal numeric literals**: a leading `0` followed by a digit is now diagnosed at the literal, so the message
      no longer depends on whatever the stray second number ran into. The verdict was already right, only the
      message was accidental. `tests/erroneous/badNumericLiterals.io` asserted those accidental messages, so its six
      leading-zero cases moved into the `badOctalLiterals.io` twins. Octal *escapes* were **not** an ES5 change -
      ES3 §7.8.4 has the identical core grammar and its own Annex B.1.2 - so they are rejected by the shared ES3
      lexer rather than behind `#if NUXJS_ES5` (see `docs/notes/ECMAScript Compatibility Notes.md`).
- [x] **Trailing commas** - both forms. Arrays are covered by `tests/conforming/ArrayLiteralHoleLength.io`, and the
      object-literal case now by `tests/conforming/objectLiteralTrailingComma.io`, which also pins down that the
      grammar allows exactly one and only after a property. Accepted in the es3 build too, so it is shared.
- [x] **String line continuation (§7.8.4).** A `\` before a LineTerminatorSequence now contributes the empty
      character sequence instead of raising `\ continuation is not supported`. ES3 §7.8.4 has no such production at
      all, so this is genuinely ES5-only and the old error moved to `tests/es3only/escapedLFNotAllowed.io` rather
      than being edited. §7.3 makes CR LF one sequence, which `unescapedMaxLength` has to agree with or it
      under-counts the buffer `unescape` then fills. (`tests/es5/stringLineContinuation.io`)
- [x] **The full §7.2 WhiteSpace set.** ES5 added U+FEFF, moved out of the §7.1 format-control set, and NuXJS had
      never implemented the `<USP>` category-Zs catch-all that both editions carry. Four places must agree on that
      set and only `String.prototype.trim` did: `Compiler::white()`, the run-time skipper `eatStringWhite` behind
      §9.3.1 `ToNumber` and §15.1.2.3 `parseFloat`, and §15.1.2.2 `parseInt`. The first two now share
      `isES5ExtraWhite`. `parseInt` reads its own whitespace table, closure-local in `stdlib.js`; a `//#if ES5`
      guard extends the set that table is built from, which makes `parseInt` conformant without touching a line of
      its code, and publishes the membership test on `support` for `trim` to share. The es3 build is deliberately
      left alone, so the `<USP>` half stays a *shared* deviation rather than
      an ES5 gap; see `docs/notes/Todo.md` under Compiler. (`tests/es5/whiteSpaceSet.io`)
- [x] **Cf format-control characters as IdentifierPart (§7.1).** ES3 §7.1 strips every Cf character from the source
      before lexing, everywhere; ES5.1 §7.1 abandons that and names the two places a format-control character means
      something instead. One is the BOM, done above. The other is §7.6 IdentifierPart, which takes `<ZWNJ>` and
      `<ZWJ>` after the first character. Cf is in none of the categories the identifier bitmaps are built from, so
      the generator builds a second part bitmap for es5 and packs it into the same mask array. `buildLookup` only
      ever appends, so taking that table last leaves the es3 mask array a prefix of the es5 one, and the whole
      difference is 8 words of mask data plus one of the 256 block offsets, both under a guard. No lexer code
      changes at all, which is what makes it reach every caller: the keyword-boundary check in `token()`, where it
      makes `in<ZWNJ>o` a single identifier as in V8, and §7.8.5 RegularExpressionFlags, which is IdentifierPart
      too. The `\u` escape form goes through the same test, so it agrees for free. NuXJS still does not strip Cf
      anywhere, which is correct for es5 and stays an es3 deviation in `docs/notes/Todo.md`.
      (`tests/es5/identifierFormatControl.io`)

### Tests
- accessor object literals; octal rejection; reserved-word keys; BOM-as-whitespace; string line continuation;
  ZWNJ/ZWJ in identifiers.

---

## 4. Strict mode - **DONE**

The largest behavioral addition. Needs both parser (directive detection) and VM (make silent failures throw).

- [x] **Directive prologue**: scan leading string-literal statements for exactly `use strict`; set a `bool strict`
      on `Code` for global, function, and eval scopes (§14.1). Nested functions inherit.
- [x] **`this` binding**: unbound `this` stays `undefined` - change `enter`'s `thisObject == 0 ? global : …`
      substitution to skip substitution when strict (§10.4.3). A primitive or null receiver passes through
      verbatim too, which took the `this`-as-a-`Value` item in §5.
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
      write to them throws. Guarded in `stdlib.js`; ES3 §15.1.1 leaves them writable.

### Tests
One `.io` per rule under `tests/es5/`: `strictDirectivePrologue`, `strictThisBinding`, `strictAssignmentErrors`,
`strictSyntaxRestrictions`, `strictEvalArguments`, `strictGlobalAssignment`, `strictReservedWords`,
`strictArguments`, `strictFunctionPoison`, `strictEvalEnvironment`, `strictOctal`, `strictDuplicateProperties`,
`strictPrimitiveBaseAssignment`, `globalConstantAttributes` (with an `es3only` twin for the ES3 attributes). All
verified present. Verified against V8 as a differential
oracle, with ES5.1-vs-modern divergences arbitrated by the spec and logged in `docs/specs`.

---

## 5. Function semantics

- [x] `Function.prototype.bind` → a native `BoundFunction` (§15.3.4.5) with partial application, a `[[Construct]]`
      that constructs the target and ignores the bound `this`, a `[[HasInstance]]` that defers to the target, no
      `prototype` property, `length = max(0, target.length - bound args)` and the poison-pill `caller`/`arguments`.
      A `support.bindFunction` hook wrapped in `stdlib.js`, like `apply`/`call`. `new` needed one new seam:
      `getConstructPrototype`, because the object a `new` expression creates takes its prototype from the callee,
      and a bound function has none. `name` is a NuXJS extension (ES5.1 §15.3.5 has no such property) set to
      `"bound " + target.name` to match V8. (`tests/es5/functionBind.io`)
- [x] Function `prototype` becomes non-enumerable (§15.3.5.2) - a real ES3→ES5 change, since ES3 gave it only
      { DontDelete }; the two builds are covered by the `enumerableOfFunctions.io` twins. `length` already had the
      §15.3.5.1 attributes. `name` is deliberately NOT made read-only: §15.3.5 does not define it at all, and
      `stdlib.js` assigns it when naming the error constructors. (`tests/es5/functionInstanceProperties.io`)
- [x] Named `FunctionExpression` binding lives in its own declarative environment (§13): visible inside, invisible
      outside, immutable, so a non-strict assignment to it is ignored and a strict one throws. Already correct in
      the engine; this was verification, not a change. (`tests/es5/namedFunctionExpression.io`)
- [x] `Function.prototype.toString` returns source text and throws `TypeError` for a non-Function `this`
      (§15.3.4.2). Already correct; the representation is implementation-dependent, so only the round-trip of the
      source text is asserted. (`tests/es5/functionInstanceProperties.io`)
- [x] **`this` as a `Value`, not an `Object*`** - the last strict-mode gap (§10.4.3), and the only item here that
      reached into the public header. `s.call(5)` now sees `5` rather than a `Number` wrapper, `s.call(null)` sees
      `null`, and `Object.prototype.toString.call(null)` answers `[object Null]`. ES3 §10.2.3 *requires* the
      coercion and keeps its `Object*`; the es3 release binary is byte-identical across the whole change. The 77
      signature sites went behind one alias (`Receiver` in `NuXJS.h`) rather than 77 guards, which is what let the
      mechanical pass land separately. Writing a native or subclassing `Function` needs a recompile in an es5
      build; the `Var` tier does not move. Reasoning, traps and gates: `docs/notes/This as a Value.md`.

### Tests
- bind partial application + `new`; bound `name`/`length`; named-function-expression scope isolation.
- strict `this` pass-through: primitive and `null` receivers via `call`, `apply` and `bind`, and off a primitive
  base through a method, a getter and a setter, each against a strict and a non-strict callee; `[object Null]` in
  `objectToStringTag.io`; `es3only` twins asserting the §10.2.3 coercion the ES3 build must keep.

---

## 6. Array & String library (mostly `stdlib.js`)

- [x] Array iteration: `forEach, map, filter, some, every, reduce, reduceRight, indexOf, lastIndexOf` (§15.4.4.14-22),
      spec-accurate on callback args, `thisArg` and **sparse** arrays (`k in O`, not naive loops). They sit in the
      guarded strict IIFE at the end of `stdlib.js` for two reasons the spec forces: strict so a null `this` survives to
      the ToObject step instead of being replaced by the global (§10.4.3), and each takes exactly one formal
      parameter with the optional second read from `arguments`, because §15.4.4.x fixes their `length` at 1.
      (`tests/es5/arrayIteration.io`, `arrayReduce.io`, `arraySearch.io`)
- [x] `Array.isArray` (§15.4.3.2) - verified: `arguments` and `{length:0}` are false, `Array.prototype` is true.
      Needs a test.
- [x] Generic behaviors: `sort` with no comparator and `toLocaleString` were already correct and generic over
      array-likes. `length` truncation now respects non-configurable elements.
- [x] The Throw flag, §15.4.4.6-13. The audit had this as two methods; it was seven. `push`, `pop`, `shift`,
      `unshift`, `reverse` and `splice` are restated strict in `stdlib.js`, since strict mode *is* the flag
      (§8.7.2 and §11.4.1 turn the refused store or delete into the TypeError). `sort` hands the present elements to
      the base sort and writes the permutation back strictly, so the ordering and even the comparator call pattern
      stay identical to ES3. All 64 refusal cases and a 364-case semantic differential match V8 and the es3 build.
      (`tests/es5/arrayMutatorThrowFlag.io`, `tests/es3only/arrayMutatorNoThrowFlag.io`)
- [x] `String.prototype.trim` with the full ES5 WhiteSpace + LineTerminator set (§15.5.4.20) - first
      ES5 library feature, proving the pipeline. (`tests/es5/stringTrim.io`) Its CheckObjectCoercible guard was
      dead until it moved into strict code: a non-strict built-in never sees a null `this`. That observation is
      what turned up the 27 methods below with the same dead step.
- [x] String character indices are non-writable, non-configurable own data properties (§15.5.5.2) - already
      conformant (`writable:false enumerable:true configurable:false`). Needs a test.
- [x] CheckObjectCoercible / ToObject on the this value, step 1 of 26 prototype methods that had it silently dead:
      the 17 `String.prototype` methods of §15.5.4.4-19, `concat`, `join`, `slice` and `toLocaleString` on
      `Array.prototype` (§15.4.4.3-10), and `hasOwnProperty`, `isPrototypeOf`, `propertyIsEnumerable`,
      `toLocaleString` and `valueOf` on `Object.prototype` (§15.2.4.3-7). §10.4.3 substituted the global object for
      a null this at frame entry, so `"".charAt.call(null, 0)` answered `"["` off `"[object global]"` rather than
      throwing; the fix is to make each table a guarded strict IIFE, which costs nothing in the ES3 source, and add
      one `coercible(this, ...)` line per entry. §15.2.4.6 needed care: it tests V *before* ToObject(this), so a
      primitive V still answers false. `valueOf` and `Object.prototype.toString` became guarded alternative entries,
      the former because §15.2.4.4 returns ToObject(this) rather than this. All 55 cases match V8.
      (`tests/es5/checkObjectCoercible.io`, `tests/es3only/globalsFromUndefinedOrNullThis.io`)
      DEVIATION left standing: `Number.prototype.toLocaleString` and `Date.prototype.toLocaleString` are the same
      function object as `Object.prototype.toLocaleString`, where §15.7.4.2 and §15.9.5.5 specify three distinct
      ones. They inherit the check correctly, but `===` can tell.

### Tests
- iteration methods incl. sparse/`thisArg`/early-exit; `sort` no-comparator; `trim` unicode; string index immutability.

---

## 7. Number / Date / JSON / global refinements

- [ ] **`getFullYear`, `getUTCFullYear`, `getMonth` and `getUTCMonth` answer 0 / 0 / 2 / 2 for an invalid date**
      where §15.9.5.10 and §15.9.5.12 step 2 want NaN. `dateFromEpoch` runs its era arithmetic through `int()`, and
      ToInteger(NaN) is 0 by §9.4, so the year and month fall out as numbers while the date correctly does not. The
      other seventeen getters are right. Shared with ES3, so a fix has to be guarded or the frozen binary moves.
      Found while adding `getYear` (Annex B §B.2.4), whose step 2 states the same requirement and which therefore
      carries its own NaN check rather than inheriting one.

- [ ] `Number.prototype.toFixed / toExponential / toPrecision` (§15.7.4): ES5 range checks and rounding verified
      correct. The one gap left is `toFixed` precision - `(1000000000000000128).toFixed(0)` loses the last digits
      (the existing TODO in `docs/notes/Todo.md`).
- [x] `Date.now` (§15.9.4.4) and a fully generic `Date.prototype.toJSON` (§15.9.5.44) are guarded in `stdlib.js`; the
      base `toJSON` read the receiver's own date value instead of going through ToPrimitive and the receiver's own
      `toISOString`. (`tests/es5/dateES5.io`)
- [x] `RegExp.prototype` is itself a regular expression object (§15.10.6): [[Class]] `RegExp` and the §15.10.7
      data properties of `new RegExp()`, where `distinctConstructor` had handed out a plain object. Found by the
      first dashboard run, not by the roadmap. ES2015 reverted the whole idea, so V8 is not an oracle here and the
      clause text is. (`tests/es5/regExpPrototypeObject.io`)
- [ ] An array `length` assigned an *object* throws a `RangeError` where 15.4.5.1 wants ToUint32 through
      ToPrimitive. Needs the value coerced before it reaches the object model, which may not run script; the
      `defineProperty` half is the §6 deferral, the plain-assignment half is not. 12 dashboard tests, documented
      in `docs/notes/ECMAScript Compatibility Notes.md`.
- [ ] `Date.parse` reads the ISO *date-only* form as local time where §15.9.1.15 says UTC. The parser is shared with
      es3, so fixing it moves the es3 binary; see `docs/notes/Todo.md`. No legacy fallback, which §15.9.4.2 permits.
- [x] `parseInt`/`parseFloat` radix and no-octal behaviour already match ES5 (§15.1.2); their whitespace handling
      was brought up to the full §7.2 set in §3. `Number.isNaN`/`isFinite` are ES6, not ES5.1, and are deliberately NOT added - this is an
      ES5.1 engine, and shipping ES6 globals would misreport what it supports.
- [x] JSON reviver/replacer/space (§15.12) - verified working, including array and function replacers, `space`
      indenting and `toJSON` dispatch. The depth-cap deviation stays documented. Needs a test.
- [x] Global `NaN`/`Infinity`/`undefined` read-only (§15.1.1) - landed in §4, guarded in `stdlib.js`.
- [x] `Object.prototype.toString` (§15.2.4.2) reports `[object Undefined]`, `[object Null]` and
      `[object Arguments]`; ES3 gave the arguments object the class `Object` (§10.1.8), so there is an `es3only`
      twin. (`tests/es5/objectToStringTag.io`)
- [x] `for-in` over `null`/`undefined` yields an empty iteration rather than throwing (§12.6.4) - landed in §0.5.

### Tests
- number formatting ranges/rounding; `Date.now`/ISO parse; global constants read-only; toString tags; for-in null.

---

## 8. Conformance, docs & tooling

- [ ] Retarget the Test262 dashboard to ES5.1 (`tools/testdash.*`, `docs/Test262 Dashboard.md`).
    - [x] Scope is derived from each test's own `es5id`/`es6id`/`esid` frontmatter instead of being recorded, so
      the 8943 hand-marked `ES >3` entries collapsed to the 58 that carry no edition id. `testdash.json` went from
      9427 entries to 349: 190 `BY DESIGN`, 101 `BAD TEST`, 58 `ES >5.1`, and 7 stale keys dropped. 5073 tests
      come into scope. Verified by classifying all 16485 tests twice, independently, with zero disagreements.
    - [x] `--engine` selects the binary. It defaulted to the ES3 build, which would have scored the wrong engine.
    - [x] `--include-strict` drops `--non_strict_only`. That flag skips all 482 `onlyStrict` tests, so no strict
      mode behaviour was ever measured; ES5.1 conformance numbers are not meaningful without it.
    - [~] First full run against the es5 build with `--include-strict`: 16255 total, 11151 passed, 268 failed,
      4874 ignored, 230 still red. That is 98.0% of the 11381 in scope. Triage is under way rather than done:
      the RegExp prototype family (20) and the 15.2.3.x non-object TypeErrors (38) are closed, each entry
      verified by running the test's own expression in both engines and citing the clause. 230 to go.
- [x] `docs/notes/ECMAScript Compatibility Notes.md` exists again and has been kept current with each deviation as
      it landed: the JSON depth cap, no Annex B octal, `Date.parse`, the two ES5 syntax relaxations the es3 build
      also accepts, and the array `[[DefineOwnProperty]]` note. The strict `this` entry was retired with §5.
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
