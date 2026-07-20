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

- **JSON nesting depth is bounded.** `JSON.parse` / `JSON.stringify` cap nesting at `MAX_JSON_DEPTH` (61) to stay
  within the compiler's recursion limit; deeper structures throw a `TypeError`. The spec imposes no fixed limit.
