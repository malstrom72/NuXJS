# ES5.1 vs modern ECMAScript (V8) - divergence reference

We use `node` (V8) as a **differential oracle** for the ES5.1 lift: run a snippet in both `node` and the `es5`
NuXJS build and diff. But V8 implements a *much* newer spec, so it is only a valid oracle **where ES5.1 and the
current spec agree**. This file lists the places they diverge, so V8's answer must be *ignored* in favour of
`ECMA-262 5.1.md`. It is a living document - add a row whenever a divergence is found.

Methodology: **V8 to catch bugs, the ES5.1 spec to arbitrate.** When V8 disagrees with our ES5.1 implementation,
check this table first; if the behaviour is listed here, ES5.1 wins.

## Behaviours that changed (V8 is wrong for ES5.1)

### `Object.*` on a non-object argument - ES5.1 throws, ES6+ coerces
ES5.1 §15.2.3.x begins each of these with "If Type(O) is not Object throw a **TypeError**". ES2015 relaxed most
of them to coerce/accept the primitive. Verified in node v26:

| Call | ES5.1 (NuXJS) | V8 / ES6+ |
| --- | --- | --- |
| `Object.preventExtensions(5)` | **TypeError** | returns `5` |
| `Object.seal(5)` / `freeze(5)` | **TypeError** | returns `5` |
| `Object.isExtensible(5)` | **TypeError** | `false` |
| `Object.isSealed(5)` / `isFrozen(5)` | **TypeError** | `true` |
| `Object.getPrototypeOf(5)` | **TypeError** | `Number.prototype` |
| `Object.keys(5)` | **TypeError** | `[]` |
| `Object.getOwnPropertyNames(5)` | **TypeError** | `[]` |
| `Object.getOwnPropertyDescriptor("s", 0)` | **TypeError** | a descriptor / `undefined` |

### Property enumeration order
ES5.1 leaves the order of `for-in`, `Object.keys`, and `Object.getOwnPropertyNames` **implementation-defined**
(§12.6.4, §15.2.3.14). ES2015 mandated: integer-index keys in ascending numeric order, then string keys in
insertion order. **Do not** assert V8's order in ES5.1 tests - sort, or test single keys. (NuXJS enumerates in
hash-table order, which is spec-legal for ES5.1.)

### Duplicate data properties in a strict object literal
ES5.1 §11.1.5 makes an `ObjectLiteral` with more than one definition of the same **data** property a `SyntaxError`
in strict code (`"use strict"; ({a:1, a:2})`). ES2015 removed that restriction, so V8 accepts it in both modes.
NuXJS follows ES5.1. The other §11.1.5 collisions - data vs. accessor, and two getters or two setters for one name
- are errors in *both* modes in ES5.1; V8 accepts those too.

### When a `null` / `undefined` base throws in `base[key] = rhs`
ES5.1 §11.2.1 puts `CheckObjectCoercible(baseValue)` at step 5, *inside* the evaluation of the
`LeftHandSideExpression`, and §11.13.1 evaluates that whole production (step 1) before the right-hand side
(step 2). So `(null)[hit = 1] = (rhsHit = 1)` throws before the RHS runs: `hit` is `1` (the key *expression* is
step 3, before the throw) and `rhsHit` stays `0`. ES2015 moved the check out of member evaluation into `PutValue`,
which runs *after* the RHS, so V8 reports `rhsHit = 1`. Only the `rhsHit` cell diverges - both agree `hit` is `1`.
ES3 §11.2.1 matches ES5.1 here, so this ordering is shared by both NuXJS variants.

### White space is category Zs of Unicode 3.0, not of a modern Unicode
ES5.1 §7.2 defines `<USP>` as "any other Unicode space separator", and §2 pins the database to "Unicode 3.0 or
later". NuXJS derives every Unicode table from **3.0** (see `tools/work/generateUnicodeTables.js`), so V8 is not a
valid oracle for two characters. Both engines conform; they just read different editions of the database.

- **U+200B ZERO WIDTH SPACE is white space here, and is not in V8.** It is category Zs in Unicode 3.0 and only
  became a format character in Unicode 4.0.1. So `Number("\u200B1")` is `1` for us and `NaN` in V8.
- **U+205F MEDIUM MATHEMATICAL SPACE is not white space here, and is in V8.** It does not exist before Unicode
  3.2, so it cannot be in a 3.0 derived set. `Number("\u205F1")` is `NaN` for us and `1` in V8.

The BOM is a genuine edition difference rather than a Unicode one: ES5.1 §7.2 lists `<BOM>` and ES3 §7.2 does not,
so `U+FEFF` is white space in the es5 build only. `tests/es5/whiteSpaceSet.io` and
`tests/es3only/bomNotWhiteSpace.io` hold both halves.

### Other changed semantics (add as encountered)
- `Function.prototype.bind` - the `.name` of a bound function is `"bound " + target.name` in ES2015; ES5.1 does
  not specify the name. (NuXJS follows the common `"bound "` prefix; check the ES5.1 text before asserting.)
- `[[ThrowTypeError]]` poison pill: ES5.1 allows one per realm; ES2015 mandates exactly one shared. Cosmetic.
- **Strict `arguments.caller`.** ES5.1 §10.6 defines *both* `caller` and `callee` as `[[ThrowTypeError]]` poison
  pills on a strict-mode arguments object, so `arguments.caller` throws a `TypeError`. ES2017 removed the `caller`
  pill, so V8 returns `undefined`. NuXJS follows ES5.1 (both throw). Verified against the spec text, not V8.
- **An ISO date string with no time zone offset.** The rule has moved twice, so the exact texts matter:
  - ES5.1 §15.9.1.15: "The value of an absent time zone offset is `Z`." No exception, so every form is UTC.
  - ES2015 §20.3.1.16: "If the time zone offset is absent, the date-time is interpreted as a local time." The
    exact opposite, and again no exception.
  - ES2016 §20.3.1.16 onwards, unchanged since: "When the time zone offset is absent, date-only forms are
    interpreted as a UTC time and date-time forms are interpreted as a local time."

  **The es5 build follows ES5.1**: `new Date("2011-10-10T14:48:00")` is `14:48Z`, where V8 and JavaScriptCore
  answer `14:48` local. The es3 build reads it as local, ES3 §15.9.4.2 defining no format at all and leaving the
  reading to the implementation; `tests/es3only/dateTimeWithoutOffsetIsLocal.io` and
  `tests/es5/isoDateTimeWithoutOffsetIsUTC.io` are the pair.

  Only the `T` form divides them. §15.9.1.15 defines that separator alone, so the space-separated form NuXJS also
  accepts is its own, reached through the implementation-specific fallback §15.9.4.2 allows, and stays local in
  both builds. That is not a detail: `toString` prints the space form, and §15.9.4.2 requires
  `Date.parse(x.toString())` to equal `x.valueOf()`. Making the space form UTC too would break that round trip,
  which is what a first attempt at this did.

  Date-only is UTC in both builds and under every edition. Reading it as local was a plain bug, now fixed. The
  single test262 case for the clause, `15.9.1.15-1`, is `new Date("1970")`, so the suite pins only that half.

### A plain V8 bug: a non-enumerable mapped arguments index
Not a spec divergence, but it looks like one from the diff. After
`(function (a) { Object.defineProperty(arguments, "0", {enumerable: false}) })(1)`, V8 drops `"0"` from
`Object.getOwnPropertyNames(arguments)` even though `hasOwnProperty("0")` and `getOwnPropertyDescriptor` both still
report it. §15.2.3.4 asks for every own property, so NuXJS lists it. Only *mapped* indices are affected; a strict
(unmapped) arguments object is fine in V8. Verified in node v26.

## Features V8 has that ES5.1 does NOT (never "match V8" by adding these)

If a test needs any of these, it is outside ES5.1 scope - do not implement them to match V8:
- Block scoping: `let`, `const`, block-scoped functions.
- Arrow functions, classes, generators, `async`/`await`, template literals, destructuring, spread/rest,
  default parameters, computed property names, shorthand methods, symbols.
- Newer built-ins: `Object.assign`, `Object.getOwnPropertySymbols`, `Object.setPrototypeOf`, `Array.from`,
  `Array.of`, `Array.prototype.{find,findIndex,includes,fill,copyWithin,flat,...}`,
  `String.prototype.{startsWith,endsWith,includes,repeat,padStart,...}`, `Number.{isInteger,parseInt,...}`,
  `Map`/`Set`/`WeakMap`/`Promise`/`Proxy`/`Reflect`, typed arrays.
- Annex B web-compat that ES5.1 does not require in the core grammar: `__proto__` literal key, `String.prototype`
  HTML methods, `escape`/`unescape` nuances, legacy octal *escapes* in non-strict strings. Concretely, V8 in
  non-strict mode evaluates `010` to `8`, `08` to `8`, `"\47"` to `"'"` and `"\01"` to `""`; NuXJS implements
  the core grammar only, so it rejects the octal *literals* in both modes. (Both engines reject every octal form in
  strict mode, which is the part `7.8.3` / `7.8.4` actually make normative.) See the octal entry in
  `docs/notes/ECMAScript Compatibility Notes.md` for what NuXJS does with non-strict octal escapes.
- Trailing commas in function parameter lists and call arguments (ES2017).
- `RegExp` `y`/`u`/`s` flags, named groups, lookbehind.

### `Object.isFrozen` on an empty non-extensible array
§15.2.3.12 returns **false** as soon as any own data property is writable. An array's `length` starts writable
(§15.4.5.2) and `Object.preventExtensions` does not change that, so `Object.isFrozen(Object.preventExtensions([]))`
is `false` under ES5.1. V8 answers `true`, apparently treating an empty non-extensible array's `length` as fixed.
Verified in node; `Object.freeze([])` is `true` in both, because freeze clears the writable flag explicitly.

### Function `length` is non-configurable, and `name` is not an ES5.1 property
§15.3.5.1 gives every function's `length` the attributes { [[Writable]]: false, [[Enumerable]]: false,
[[Configurable]]: **false** }. ES2015 made it configurable, so V8 reports `configurable: true` and lets you
`delete f.length`. ES5.1 arbitrates, so NuXJS refuses both.

§15.3.5 defines only `length` and `prototype`, so `name` is a NuXJS extension in either edition. It is deliberately
left **writable**, because `stdlib.js` assigns it when naming the error constructors; V8 follows ES2015 and reports
`writable: false`. Verified in node:

| Expression | ES5.1 (NuXJS) | V8 / ES6+ |
| --- | --- | --- |
| `Object.getOwnPropertyDescriptor(f, "length").configurable` | `false` | `true` |
| `delete f.length` | `false` | `true` |
| `Object.getOwnPropertyDescriptor(f, "name").writable` | `true` (extension) | `false` |

Note that `prototype` moves the other way, and is an ES3→ES5 change rather than a V8 divergence: ES3 §15.3.5.2 gave
it only { DontDelete }, so it was **enumerable**, while ES5.1 adds [[Enumerable]]: false. Both builds are covered by
the `enumerableOfFunctions.io` twins.

### Bound functions: poison pills and the `length` attributes
ES5.1 §15.3.4.5 steps 20-21 make `Function.prototype.bind` define own `caller` and `arguments` properties on the
returned function, both the [[ThrowTypeError]] accessor, non-enumerable and non-configurable. ES2015 dropped them
from bound functions (they survive only on `Function.prototype`). Step 17 also gives the bound `length` the
§15.3.5.1 attributes, so it is **non-configurable**; ES2015 made function `length` configurable. Verified in node:

| Expression | ES5.1 (NuXJS) | V8 / ES6+ |
| --- | --- | --- |
| `Object.getOwnPropertyNames(f.bind(null))` | includes `caller` and `arguments` | `length`, `name` only |
| `f.bind(null).caller` | **TypeError** (poison pill) | `undefined` |
| `Object.getOwnPropertyDescriptor(f.bind(null), "length").configurable` | `false` | `true` |

Note that `name` is not an ES5.1 property at all - §15.3.5 defines only `length` and `prototype`. NuXJS carries it
as an extension, and gives a bound function `"bound " + target.name` to match V8 rather than leave a gap.

## Same in both (V8 is a valid oracle)

Most core ES5.1 semantics are unchanged and V8 can be trusted: the `[[DefineOwnProperty]]` (8.12.9) algorithm,
`ToPropertyDescriptor`/`FromPropertyDescriptor`, accessor get/set invocation and `this` binding, strict-mode
directive prologue recognition (14.1) and strict `this`/throw semantics, `typeof`/`instanceof`/`in`, most
`Array.prototype`/`String.prototype` ES5 methods, `JSON`, and evaluation order. When in doubt, verify the specific
snippet in both engines rather than assuming.
