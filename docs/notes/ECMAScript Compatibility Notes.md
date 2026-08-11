# ECMAScript Compatibility Notes

Intentional deviations from the ECMAScript specifications, and their rationale. The engine targets ECMAScript 3
by default and ECMAScript 5.1 when built with `NUXJS_ES5` (see `docs/ES5.1 Roadmap.md`). Deviations that are simply
"not yet implemented" during the ES5.1 lift are marked *(deferred)* and tracked in the roadmap.

## ES5.1

- **`Object.defineProperty` on array indices and `length` - partial *(deferred)*.** The full `Array`
  `[[DefineOwnProperty]]` algorithm (15.4.5.1) - `length` maintenance and 8.12.9 validation for indices/`length`,
  which interact with the engine's dense-vector element storage - is not yet implemented. A *data* (or generic)
  descriptor on an array index or `length` still works (it maps to the ordinary set-with-attributes path); an
  *accessor* descriptor on an index or `length` throws a `TypeError`. Named array properties and all ordinary
  object / function properties follow 8.12.9 exactly. Tracked in `docs/ES5.1 Roadmap.md` §6.

- **An array `length` set to an *object* throws a `RangeError`.** 15.4.5.1 takes ToUint32 of the value, which for
  an object runs ToPrimitive and so `valueOf` / `toString`; `arr.length = { toString: function () { return "2" } }`
  should give 2. `Value::toDouble` answers NaN for an object instead, by design - proper ToNumber has to run
  script, and the object model is required not to (`docs/ES5.1 Roadmap.md` §1, "core lookups stay pure"). Every
  primitive coerces correctly, `true`, `null`, `"3"` and a `Number` wrapper included; only a plain object with a
  `valueOf` / `toString` is affected, through plain assignment and through `Object.defineProperty` alike. Shared
  with the es3 build, which has always behaved this way. Found by the Test262 dashboard, 12 tests.

- **`Date.parse` accepts no legacy formats.** 15.9.4.2 requires the 15.9.1.15 ISO format and says an implementation
  *may* fall back to other heuristics for anything else. NuXJS does not, so
  `Date.parse("Mon, 25 Dec 1995 13:30:00 GMT")` is `NaN` where V8 returns a time value. Conformant, but worth
  knowing when porting code. A string with no time zone offset is read as UTC, per 15.9.1.15, which is the whole
  of the rule in that edition; a later edition kept it for the date-only form and made the date-time form local,
  so `Date.parse("2011-10-10T14:48:00")` is an hour count away from V8 in any zone but UTC. See
  `docs/specs/ES5.1 vs modern divergences.md`.

- **ES3 mode accepts two ES5 syntax relaxations.** ES5.1 `11.1.5` takes an `IdentifierName` as a property name and
  `11.2.1` does the same after the dot, so `{ if: 1 }` and `o.if` are legal; it also added the trailing comma to
  `ObjectLiteral`. ES3 `11.1.5` / `11.2.1` asked for an `Identifier` and had no trailing comma. NuXJS has always
  accepted all three, in both builds, so the `NUXJS_ES5` build is conformant here and the ES3 build is *lenient*
  rather than conformant. Tightening it would break working code for no benefit, so the confirming tests
  (`tests/conforming/reservedWordsAsPropertyNames.io`, `objectLiteralTrailingComma.io`) are shared.

- **An assignment finds its target twice - es3 build only.** Evaluating an identifier yields a Reference whose
  base is the *particular* scope object found at that moment (ES3 `10.1.4` step 3, ES5.1 `10.2.2.1`), and every
  assignment form evaluates its left-hand side once, before the right-hand side, then hands that same Reference
  to `PutValue` (ES3/ES5.1 `11.13.1` steps 1 and 4, `11.13.2` steps 1 and 6, `11.3` / `11.4.4` for `++` and
  `--`, and `12.2` steps 1 and 4 for a `var` initialiser). The es3 engine emits `READ_NAMED` and `WRITE_NAMED`, which each walk the scope chain by name, so if the
  right-hand side removes the binding the write lands on whatever the name resolves to next:
  `with (scope) { x = (delete scope.x, 2) }` writes to the outer `x` where the spec writes to `scope`. V8 has the
  same deviation. Left as it stands in es3 rather than moving the frozen binary for it; recorded by
  `tests/es3only/rightSideBeforeAssignmentRef.io`. The `NUXJS_ES5` build is conformant: it resolves the name up
  front and keeps the reference on the value stack, the way a property reference already keeps its base. An
  object environment record is kept as its holder and a declarative one as the level it was found at, which is
  what stops a binding that a direct `eval` adds more locally during the right-hand side from taking the write
  (`tests/es5/assignmentReferenceCapture.io`). V8 does not do this last part. A name that resolves nowhere keeps
  no base at all, and `8.7.2` step 3 then sends the write to the global object, running a setter installed since
  if there is one, or throws a `ReferenceError` in strict code.

- **JSON nesting depth is bounded.** `JSON.parse` / `JSON.stringify` cap nesting at `MAX_JSON_DEPTH` (61) to stay
  within the compiler's recursion limit; deeper structures throw a `TypeError`. The spec imposes no fixed limit.

- **Annex B library functions - partial, by design.** Annex B is *informative* in ES5.1, so each entry is a
  separate decision rather than a block. `String.prototype.substr` (`B.2.3`) has always been there, and
  `Date.prototype.getYear` / `setYear` / `toGMTString` (`B.2.4` - `B.2.6`) are implemented under `NUXJS_ES5`;
  `toGMTString` is the same Function object as `toUTCString`, as `B.2.6` requires. `escape` (`B.2.1`) and
  `unescape` (`B.2.2`) are deliberately **not** implemented and never have been. Note that a Test262 path under
  `annexB/` does not mean the test is Annex B for *this* edition: the RegExp tests there carry `es5id: 7.8.5` and
  `15.10.2.x`, which are normative core in ES5.1 and only became Annex B in ES6.

- **No Annex B octal - by design, in both modes.** ES5.1 keeps octal out of the core grammar (`7.8.3` / `7.8.4`);
  octal integer literals and octal escapes exist only as the Annex B compatibility extension (`B.1.1` / `B.1.2`),
  which NuXJS deliberately does not implement. So octal *literals* (`010`, `08`) and octal *escapes* (`"\47"`,
  `"\01"`) are `SyntaxError`s in **both** strict and non-strict code, which is what the grammar proper says. Real
  browsers do implement Annex B, so `"\47"` is `"'"` and `010` is `8` there; code relying on that will not run.
  This is not an ES5-versus-ES3 difference - ES3 `7.8.4` has the identical core grammar and its own Annex B.1.2 -
  so the escape half of it is enforced by the shared ES3 lexer rather than behind `NUXJS_ES5`.
