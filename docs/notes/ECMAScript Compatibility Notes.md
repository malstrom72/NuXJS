# ECMAScript Compatibility Notes

Intentional deviations from the ECMAScript specifications, and their rationale. The engine targets ECMAScript 3
by default and ECMAScript 5.1 when built with `NUXJS_ES5` (see `docs/ES5.1 Roadmap.md`). Deviations that are simply
"not yet implemented" during the ES5.1 lift are marked *(deferred)* and tracked in the roadmap.

## ES5.1

- **`Object.defineProperty` on array indices and `length` — partial *(deferred)*.** The full `Array`
  `[[DefineOwnProperty]]` algorithm (15.4.5.1) — `length` maintenance and 8.12.9 validation for indices/`length`,
  which interact with the engine's dense-vector element storage — is not yet implemented. A *data* (or generic)
  descriptor on an array index or `length` still works (it maps to the ordinary set-with-attributes path); an
  *accessor* descriptor on an index or `length` throws a `TypeError`. Named array properties and all ordinary
  object / function properties follow 8.12.9 exactly. Tracked in `docs/ES5.1 Roadmap.md` §6.

- **Strict `this` for primitive / null receivers — partial *(deferred)*.** In a strict function an *unbound* `this`
  is `undefined` (correct), and object receivers pass through unchanged. But because the engine represents a
  frame's `this` as an object pointer, a *primitive* or *null* receiver passed via `Function.prototype.call` /
  `apply` is still coerced (a primitive is boxed, `null` becomes `undefined`) rather than passed through verbatim
  as ES5 strict requires. Full fidelity needs `this` to be a value, not an object pointer; tracked for a later
  commit.

- **JSON nesting depth is bounded.** `JSON.parse` / `JSON.stringify` cap nesting at `MAX_JSON_DEPTH` (61) to stay
  within the compiler's recursion limit; deeper structures throw a `TypeError`. The spec imposes no fixed limit.

- **Octal escape sequences in non-strict code — accepted, but as the bare character.** ES5.1 keeps octal out of the
  core grammar (`7.8.3` / `7.8.4`); octal integer literals and octal escapes exist only as the Annex B compatibility
  extension, which NuXJS deliberately does not implement. Octal *literals* (`010`, `08`) are therefore rejected in
  both modes, which is core-grammar-correct. Octal *escapes* are rejected in strict code as `7.8.4` requires, but in
  non-strict code `"\47"` still yields `"47"` (the backslash is simply dropped) instead of being a `SyntaxError` as
  the core grammar says — an ES3-era lexer behaviour left untouched so the ES3 engine stays byte-identical. (ES3
  `7.8.4` *did* include octal escapes, so `"\47"` should be `"'"` there; NuXJS has never implemented that either.)
