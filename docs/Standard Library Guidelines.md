# Standard Library Guidelines

The standard library lives in `src/stdlib.js` and ships as minified strings in `src/stdlibJS.cpp`. After editing
it, run `bash tools/buildAndTest.sh release x64` to regenerate the blob and run the regression tests. That
regeneration is unconditional, the generator rewriting `src/stdlibJS.cpp` only when its content actually changes,
so there is no mtime gate left to defeat and no stale blob to test against.

## Conditional compilation

`src/stdlib.js` serves both language targets. `//#if ES5`, `//#if !ES5`, `//#else` and `//#endif` select what each
one sees, and `tools/stdlibToCpp.pika` resolves them twice, emitting both variants under one `#if NUXJS_ES5` in the
blob. Guards nest.

Everything ES5.1 adds lives in the one file, at the end under `/* --- ES5.1 additions --- */`, so that it can reach
the helpers above it rather than restate them. That placement is what lets it supersede the entries it replaces, and
it is also why the section is last.

The pass is line-based and runs *before* the minifier, so a directive owns its whole line (leading tabs are fine,
trailing text is not), and what reaches the minifier is exactly the source you would have written without the
guards. That is what keeps the ES3 blob byte for byte what it has always been, which is the invariant the whole
lift rests on: the ES3 release binary must not move.

Being line-based, the pass knows nothing about JavaScript, and cuts through a comment as readily as through code.
That is deliberate for the `@preserve` header, where it is how a name only one target needs is declared only
there. It also means a directive *spelled out* inside a string literal or a block comment is acted on, so do not
write one where you meant to quote one.

Keep a guard around whole entries rather than inside a shared body, per D1 in `docs/ES5.1 Roadmap.md`: the two
implementations of a method read far better side by side than one implementation interleaved with directives.

Anything whose first step is CheckObjectCoercible or ToObject on the this value, and anything that stores with
Throw = true, has to sit inside the strict IIFE in that section. A non-strict function never sees a null or
undefined `this`, because 10.4.3 substitutes the global object at frame entry, so the TypeError the spec asks for
would be unreachable. The file as a whole cannot be strict: `evalThere` assigns to `eval`, which strict mode makes
a SyntaxError.

`bash tools/buildAndTest.sh` writes `output/stdlib.es3.js`, the ES3 library recovered from the merged file with
every guard resolved away. Read it, or diff it against a previous revision, whenever you want the pristine ES3
source rather than the two targets interleaved. Ask for the other side with

	PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../output/stdlib.es5.js es5

Any `.js` output selects this mode; anything else generates the blob.

Blank lines count. A guard that swallows the blank line before it and leaves the one after (or the reverse) keeps
both variants reading naturally; taking neither leaves the target that drops the block with a double blank.

General code style is in `docs/Coding Style.md`. This file covers what is specific to the library, including where
it deliberately departs from that document.

## Never call a method off a user-reachable prototype (PRIO 1)

The library shares one object graph with user code, and user code may replace any built-in method at any moment. So
`s.indexOf(..)`, `a.slice(..)`, `a.join(..)` and every other `Something.prototype` method are out of bounds. Use the
`support.*` primitives or their `$`-prefixed aliases at the top of the file (`$sub`, `$match`, `$charCodeAt`,
`$isNaN`, `$callWithArgs`, ...), or a local helper built from them.

This is not hypothetical: a one-line `String.prototype.indexOf` override once made `toExponential()` answer
`1.234.5678e+8`, and an `Array.prototype.slice` override made `toFixed(1)` answer `0.1`.

Property *reads* are safe (`s.length`, `s[i]`, `d[i]`), being own properties that no prototype can shadow, so
scanning with `s[i]` is the natural replacement for `indexOf` and needs no primitive.

The legitimate exceptions are spec-mandated dynamic dispatch, where the standard *requires* the current method to be
seen: `Object.prototype.toLocaleString` calling `this.toString()` (15.2.4.3) and `Array.prototype.toString` calling
`this.join()` (15.4.4.2).

`tests/stdlib/numberToString.io` ends with a regression test that hijacks several prototypes at once. That damage
persists for the rest of an `.io` file, so put any new test *before* that block, or give it a file of its own.

## The minifier

`tools/stdlibToCpp.pika` drives the PEG in `tools/stdlibMinifier.ppeg`. What it does decides what is worth squeezing
by hand.

It strips every comment and all whitespace, emitting a single space only where two adjacent tokens would otherwise
merge; renames every identifier through one flat, file-wide map (no scope analysis, but a bijection, so it is safe);
and drops a `;` sitting immediately before a `}`. It does **not** fold expressions, remove dead code, merge `var`s,
rewrite `if`/`?:`, remove braces, rewrite numbers, or touch anything inside a string literal.

- **Comments and formatting are free.** They vanish. Cite the spec and explain the reasoning; terseness here is about
  the *code*, never the commentary. Match the file's density, which is sparse and short.
- **Identifier length is free; identifier count is not.** Each distinct name takes a slot from a pool of 52
  single-character names before spilling to two. Prefer a name the file already uses over coining a new one, and
  never shorten a name for the blob's sake. Both modules are long past that pool, so the cost of one more name is a
  flat byte per occurrence rather than a cliff: worth minding, not worth contorting the code for.
- **A `@preserve` name is emitted verbatim at every occurrence, so never use one as a local.** Many read like
  ordinary variable names: `value`, `name`, `index`, `length`, `min`, `max`, `test`, `source`, `global`, `log`,
  `parse`, `time`, `input`, `match`, `call`, `apply`. Check the lists at the top of `src/stdlib.js` before naming
  anything.
- **Keywords are just identifiers to the minifier**, so every keyword in use must be on a `@preserve` list. `catch`,
  `continue` and `with` are *not* on it, which is safe only because the file uses none of them. Introducing a
  `try`/`catch` or a `continue` without adding the keyword first yields a silently corrupt blob.
- **Private property names are free.** A property invented and used only inside the file is renamed on both store and
  load. Only names the engine or user code must see need preserving.
- **Numbers are never rewritten.** Write `1e21`, not the digits.
- **Do not hand-strip a `;` before a `}`.** The minifier already does that one.

## Squeezing by hand

Since the minifier does nothing at the expression level, that is where hand work pays.

- **Fold an assignment into the expression that consumes it** rather than spending a statement on it. It works on an
  argument, on a receiver, and on the subject of a test (`if ((start = int(start)) < 0)`). Apply it **only where the
  result is provably identical**: evaluation order bites. Folding a compound assignment into the *right* operand of a
  `-` changes the answer, because 11.6.2 evaluates the left operand first.
- **Drop braces around a single statement** and put it on the control line. This is the file's overwhelming
  convention and it overrides `docs/Coding Style.md` §6 here. It is not only cosmetic: the minifier does not remove
  braces, so each pair dropped is two characters off the blob. A two-statement body goes on one braced line,
  `if (val < 0) { val = -val; sign = '-'; }`. Longer bodies stay braced and indented per §6.
- **An `if`/`else if`/`return` cascade is usually a `?:` cascade**, broken with the operator leading the continuation
  line.
- **Count down when iteration order does not matter.** `for (i = n; --i >= 0; )` is 8 VM instructions per pass
  against 10 for `for (i = n - 1; i >= 0; --i)`, 11 for a forward loop over a cached length, and 14 for
  `for (i = 0; i < d.length; ++i)`, which re-fetches `length` every time. `--i >= 0` stores through `WRITE_LOCAL`
  rather than `WRITE_LOCAL_POP`, so the decremented value stays on the stack and feeds the compare directly, fusing
  the update into the test. Do not "tidy" these into forward loops.
- **Nest a helper inside its only caller.** `sort` keeps `swap`, `compare` and `qsort`; the date parser keeps
  `readPart`. ES3 §12 has no `FunctionDeclaration` statement, so the declaration belongs at the top of the enclosing
  function body, never inside an `if` or a loop.
- `void 0` over `undefined`, `undefined` being a preserved name that costs nine characters every time.
- The comma operator is legal and occasionally right, but rarely shrinks anything without costing more in syntax than
  it saves.

## Measuring

Settle a bytecode question with `dasm(func)` in the REPL. Time with the engine's own `-t` flag, which reports
`getCPUSecs` at microsecond resolution, or with `tools/benchmark.node.js`, which takes a median over N runs.
`Date.getTime()` is useless for benchmarking: it comes from `std::time` and ticks once a second. Compare blob sizes
by `stat`ing `src/stdlibJS.cpp` before and after. Run-to-run noise is around 2%, so interleave runs, take a minimum
or median, and treat anything smaller than that as noise rather than a result.

## Engine interaction

- Interact with the engine only through the injected `support` object, using helpers like `defineProperty`,
  `callWithArgs` and `getInternalProperty`.
- Use `defineProperties` to apply `readOnly`, `dontEnum` and `dontDelete` attributes consistently.
- Add identifiers that must survive minification to the `@preserve` block at the top of `src/stdlib.js`.

## Unconstructable methods

- Wrap functions that must not be invoked with `new` using `unconstructable` (an alias for
  `support.distinctConstructor`).
- This removes their `.prototype` property and throws a `TypeError` when construction is attempted.

## Language constraints

- Target ECMAScript 3 semantics.
- Avoid engine limitations such as custom getters/setters, non-ES3 evaluation order and unsupported regular
  expression features.
