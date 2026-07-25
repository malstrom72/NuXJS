# ES5.1 vs modern ECMAScript (V8) — divergence reference

We use `node` (V8) as a **differential oracle** for the ES5.1 lift: run a snippet in both `node` and the `es5`
NuXJS build and diff. But V8 implements a *much* newer spec, so it is only a valid oracle **where ES5.1 and the
current spec agree**. This file lists the places they diverge, so V8's answer must be *ignored* in favour of
`ECMA-262 5.1.md`. It is a living document — add a row whenever a divergence is found.

Methodology: **V8 to catch bugs, the ES5.1 spec to arbitrate.** When V8 disagrees with our ES5.1 implementation,
check this table first; if the behaviour is listed here, ES5.1 wins.

## Behaviours that changed (V8 is wrong for ES5.1)

### `Object.*` on a non-object argument — ES5.1 throws, ES6+ coerces
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
insertion order. **Do not** assert V8's order in ES5.1 tests — sort, or test single keys. (NuXJS enumerates in
hash-table order, which is spec-legal for ES5.1.)

### Other changed semantics (add as encountered)
- `Function.prototype.bind` — the `.name` of a bound function is `"bound " + target.name` in ES2015; ES5.1 does
  not specify the name. (NuXJS follows the common `"bound "` prefix; check the ES5.1 text before asserting.)
- `[[ThrowTypeError]]` poison pill: ES5.1 allows one per realm; ES2015 mandates exactly one shared. Cosmetic.
- **Strict `arguments.caller`.** ES5.1 §10.6 defines *both* `caller` and `callee` as `[[ThrowTypeError]]` poison
  pills on a strict-mode arguments object, so `arguments.caller` throws a `TypeError`. ES2017 removed the `caller`
  pill, so V8 returns `undefined`. NuXJS follows ES5.1 (both throw). Verified against the spec text, not V8.

## Features V8 has that ES5.1 does NOT (never "match V8" by adding these)

If a test needs any of these, it is outside ES5.1 scope — do not implement them to match V8:
- Block scoping: `let`, `const`, block-scoped functions.
- Arrow functions, classes, generators, `async`/`await`, template literals, destructuring, spread/rest,
  default parameters, computed property names, shorthand methods, symbols.
- Newer built-ins: `Object.assign`, `Object.getOwnPropertySymbols`, `Object.setPrototypeOf`, `Array.from`,
  `Array.of`, `Array.prototype.{find,findIndex,includes,fill,copyWithin,flat,...}`,
  `String.prototype.{startsWith,endsWith,includes,repeat,padStart,...}`, `Number.{isInteger,parseInt,...}`,
  `Map`/`Set`/`WeakMap`/`Promise`/`Proxy`/`Reflect`, typed arrays.
- Annex B web-compat that ES5.1 does not require in the core grammar: `__proto__` literal key, `String.prototype`
  HTML methods, `escape`/`unescape` nuances, legacy octal *escapes* in non-strict strings.
- Trailing commas in function parameter lists and call arguments (ES2017).
- `RegExp` `y`/`u`/`s` flags, named groups, lookbehind.

## Same in both (V8 is a valid oracle)

Most core ES5.1 semantics are unchanged and V8 can be trusted: the `[[DefineOwnProperty]]` (8.12.9) algorithm,
`ToPropertyDescriptor`/`FromPropertyDescriptor`, accessor get/set invocation and `this` binding, strict-mode
directive prologue recognition (14.1) and strict `this`/throw semantics, `typeof`/`instanceof`/`in`, most
`Array.prototype`/`String.prototype` ES5 methods, `JSON`, and evaluation order. When in doubt, verify the specific
snippet in both engines rather than assuming.
