# Writing and Minifying `src/stdlib.js`

This guide explains how the standard library is authored in plain JavaScript and then minified and embedded into the
engine. It covers the minification pipeline (implemented in PikaScript/PPEG), naming rules, and the constraints you
should follow when editing or extending `src/stdlib.js`.

## Overview

- Source of truth: `src/stdlib.js`
- Build step: the file is parsed and minified by PikaScript (via `PikaCmd`) using a PEG grammar in
  `tools/stdlibMinifier.ppeg`
- Emission: `tools/stdlibToCpp.pika` converts the minified code into `src/stdlibJS.cpp` as a C string array that the
  C++ runtime loads on startup.
- Trigger: regeneration happens automatically when `src/stdlib.js` is newer than `src/stdlibJS.cpp`.

Relevant files:
- `tools/buildAndTest.sh:14–22, 28–37` – runs PikaCmd and rebuilds `src/stdlibJS.cpp` on demand
- `tools/stdlibToCpp.pika:1` – orchestrates minification and C++ emission
- `tools/stdlibMinifier.ppeg:1` – PPEG grammar used for tokenizing and renaming

## Minifier, in a nutshell

The minifier is not a full JS parser. It is a small PEG grammar that:

- Removes comments and collapses whitespace
- Renames all identifiers unless explicitly preserved
- Leaves punctuation/operators intact
- Keeps string and numeric literals as-is
- Drops a redundant semicolon before a closing brace (`; }` → `}`)

Identifiers are matched by the simple rule `[$a-zA-Z_0-9]+` and then passed through a renamer. The renamer generates
short symbols (`a`, `b`, …, `Z`, `a0`, `a1`, …) and skips any name listed as preserved.

Because property names in dot form (e.g. `obj.length`) also match `identifier`, they will be renamed unless preserved.
This is why the top of `src/stdlib.js` contains one or more `@preserve:` comment lines enumerating all names that must
remain stable at runtime (built-ins, property keys, well-known globals, etc.).

## Authoring rules for `src/stdlib.js`

Follow these to keep the minifier happy and semantics correct:

1) Preserve externally visible names
- Put every property name and global symbol that must not change under one or more comment lines with the special
  prefix `@preserve:`. Example from the existing file:

  ```
  /*
      @preserve: Array,Boolean,Date,E,Error,Function,Infinity,LN10,LN2,LOG10E,LOG2E,MAX_VALUE,MIN_VALUE,Math
      @preserve: NEGATIVE_INFINITY,NaN,Number,Object,PI,POSITIVE_INFINITY,RangeError,RegExp,SQRT1_2,SQRT2,String
      ...
  */
  ```

- Typical entries include: method names (`apply`, `call`, `toString`, `valueOf`, …), property names (`length`,
  `prototype`, `constructor`, …), global values (`Infinity`, `NaN`, `undefined`), and any object keys that are looked
  up reflectively from C++.

2) Do not use regular expression literals
- The grammar intentionally disables `/…/flags` because it cannot reliably disambiguate division vs. regex without a
  full JS parser.
- Use the constructor instead: `RegExp(pattern, flags)` or the provided `support.createRegExp(pattern, flags)`.

3) Keep to ES3/ES5.1-era syntax
- No template strings, destructuring, default parameters, arrow functions, classes, etc.
- String escapes supported by the grammar: `\n`, `\r`, `\t`, `\\`, `\"`, `\'`, `\xNN`, `\uNNNN`.

4) Assume whitespace is collapsed
- Tokens are re-joined with a single space where needed. Do not rely on line-break-sensitive Automatic Semicolon
  Insertion tricks. Write explicit semicolons as you would in production code.
- The minifier removes `;` immediately before `}`; elsewhere your semicolons are kept.

5) Prefer helper shims for native-like behaviour
- Define methods via `defineProperties(object, attribs, props)` and `support.defineProperty()` to set attributes like
  read‑only, dont‑enum, and dont‑delete. Example patterns used throughout the library:

  - Create “unconstructable” functions (callable but not `new`‑able):
    `unconstructable(function name(...) { ... })`
  - Create distinct call vs. construct behaviour:
    `support.distinctConstructor(callImpl, constructImpl)`
  - Wrap primitives into proper objects:
    `support.createWrapper(className, internalValue, prototype)`

6) Be explicit with property keys
- If a property name is not on the `@preserve:` list and you only need it internally, consider bracket access with a
  string literal (`obj["privateKey"]`) to avoid the renamer touching it.

## What the minifier actually does (details)

`tools/stdlibMinifier.ppeg` defines these key rules:

- `root`: streams the whole file, choosing one of these at each step:
  - `ws` (whitespace or comments) – discarded except for `@preserve:` handling
  - `qString` / `aString` – double- or single-quoted strings, kept verbatim (with escapes)
  - `token` – numbers or identifiers; identifiers go through the renamer
  - a special `';' ws '}'` case that emits only `}`
  - any single character `.` (operators and punctuation) appended as-is

- `token`: `number` or `identifier`
  - `number`: hex (`0x…`) or decimal with optional fraction and exponent
  - `identifier`: `[$a-zA-Z_0-9]+` (note: this is simpler than the real ES grammar)

- `comment`:
  - `/* … */` and `// …` are stripped; if they contain a `@preserve:` clause then each listed identifier is marked
    preserved in the parser state and will never be renamed.

- Renamer: implemented in the `{ … }` preamble block at the top of the PEG file. It generates the sequence
  `a, b, …, Z, a0, a1, …` while avoiding any `@preserve`d symbol.

`tools/stdlibToCpp.pika` then slices the minified output into quoted C++ lines that stay under 120 columns and writes
`src/stdlibJS.cpp` with:

```
namespace NuXJS {
const char* STDLIB_JS =
"…minified and escaped JS…"
"…continued…"
;
}
```

## Testing your changes

1) Edit `src/stdlib.js`
2) Run `./build.sh` (or `build.cmd` on Windows). The build checks timestamps and regenerates `src/stdlibJS.cpp` when
   needed using the local `externals/PikaCmd` tool.
3) For ES5.1 work, set `CPP_OPTIONS='-DNUXJS_ES5=1'` to enable ES5.1 tests, or set
   `NUXJS_TEST_ES5_VARIANTS=1` to run both ES3 and ES5.1 passes:

   ```bash
   CPP_OPTIONS='-DNUXJS_ES5=1' ./build.sh
   NUXJS_TEST_ES5_VARIANTS=1 ./build.sh
   ```

## PikaScript reference (why it matters)

The minifier and emitter are written in PikaScript and PPEG (Pika PEG). If you need to tweak the pipeline, consult the
upstream documentation:

- PikaScript Documentation (language reference):
  https://github.com/malstrom72/PikaScript/blob/main/docs/PikaScript%20Documentation.txt
- PPEG Documentation (parser generator):
  https://github.com/malstrom72/PikaScript/blob/main/docs/PPEG%20Documentation.txt
- PikaCmd Documentation (CLI tool):
  https://github.com/malstrom72/PikaScript/blob/main/docs/PikaCmd%20Documentation.txt

You do not need a system-wide installation; our build uses the checked-in `externals/PikaCmd` tool and the local
scripts under `tools/`. If you want to explore or hack on PikaScript itself, refer to the repository above instead of
adding it to this tree.
