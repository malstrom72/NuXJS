# Repository Guidelines

To run the test suite use the helper script with up to three minutes allowed for execution:

```bash
timeout 180 ./build.sh
```

Always execute this command before committing changes to verify that the build and regression tests succeed. The build is complete only when the output contains the line:

```
=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===
```

If this message is absent, the build and test sequence did not finish.

The full both-variant build (`es3` and `es5`, beta and release) takes longer than the 180 s above; allow roughly ten minutes (`timeout 600 ./build.sh`).

## ECMAScript 5.1 work (`NUXJS_ES5`)

The engine is being lifted from ES3 to ES5.1. Follow these rules for every ES5 addition:

- **Implement from the spec, not from memory.** The full ES5.1 standard is `docs/specs/ECMA-262 5.1.md` (clause-numbered). Read the relevant clause before writing a feature and follow its numbered algorithm steps literally - including the pedantic parts: `Reject`/Throw semantics, `SameValue` versus `===`, "an absent field takes its default value", and the exact `CheckObjectCoercible` / `ToObject` / `ToString` ordering.
- **Cite the clause in every test.** Each `tests/es5/*.io` names the clause it verifies (e.g. `// ES5.1 8.12.9 step 7`). Give each fiddly spec branch its own test section - those are exactly where a plausible implementation silently diverges from the standard.
- **Differential-test against V8, don't just read.** `node` is available; verify fiddly ES5 behaviour by running the same snippet in `node` and the `es5` NuXJS build and diffing, rather than claiming conformance from spec-reading alone. But V8 implements a much newer spec, so it is only a valid oracle where ES5.1 and current ES agree - consult `docs/specs/ES5.1 vs modern divergences.md` (e.g. `Object.keys(5)` throws in ES5.1 but returns `[]` in V8). **V8 to catch bugs, the ES5.1 spec to arbitrate.**
- **Guard additively; keep ES3 pristine.** Every ES5 change is wrapped in `#if NUXJS_ES5`, is strictly additive, and must not alter an ES3 code path. The ES3 build (with `NUXJS_ES5` defined to 0 - `NuXJS.h` defaults it to 1, so silence means es5) must stay behaviourally identical - ideally the es3 release binary is byte-for-byte unchanged. Verify by building both variants.
- **Standard-library additions go at the end of `src/stdlib.js`, behind `//#if ES5`**, in the `ES5.1 additions` section. The ES3 side of every guard stays untouched: `output/stdlib.es3.js`, regenerated on each build, must stay byte-identical to the pristine ES3 library. See `docs/Standard Library Guidelines.md`.
- **Document intentional deviations** in `docs/notes/ECMAScript Compatibility Notes.md` rather than leaving a silent gap.

See `docs/ES5.1 Roadmap.md` for the plan and current status.

## Repository layout
The project uses a consistent folder structure. Build output is written to `output/` and no source files live there. Useful locations:

- `tools/` - scripts for building and maintaining the code and documentation.
- `projects/` - Xcode and Visual Studio project files.
- `docs/` - documentation.
- `externals/` - projects and source code from other repositories (only touch this content when explicitly asked to).
- `src/` - C++ source code for the library. The library is distributed as source rather than prebuilt binaries.
- `tests/` - regression tests.
- `benchmarks/` - JavaScript performance tests.
- `output/` - contains only build artifacts (and any runtime dependencies), no source files.

Root-level `build.sh` and `build.cmd` (mirrored implementations) should build and test both the beta and release targets.

### PikaCmd directory
The `externals/PikaCmd` folder is a separate project copied into this repository. Ignore it when applying formatting or running tests.

### BuildCpp
BuildCpp.sh and BuildCpp.cmd are copied from another repository. Only make changes to them if there is no other solution.

## Coding style

Code style and design principles are canonical in `docs/Coding Style.md`, which is shared across projects: error
handling and design by contract, compactness and no duplicated functionality, naming, class layout, comments and
formatting. Read it before writing code here. This file adds only the NuXJS-specific operational notes.

Two NuXJS-specific notes on top of it:

- The existing sources still carry a lot of the abandoned Doxygen comment style (`///`, `///<`, `/** **/`) and
  per-declaration access specifiers. Do not copy either into new or edited code; see `docs/Coding Style.md` §4 and §5.
- When handling files with command-line tools, always run `expand -t 4` on the file before processing and
  `unexpand -t 4` on it afterwards.
- Keep commit messages short, one or two sentences. Do not add `Co-Authored-By` or other generated trailers.

See `docs/NuXJS Documentation.md` for details on how `src/stdlib.js` is minified and converted to `src/stdlibJS.cpp` during the build, and `docs/Standard Library Guidelines.md` for rules when editing the standard library: the no-prototype-methods rule, what the minifier does and does not do, and where `src/stdlib.js` departs from `docs/Coding Style.md`.

## Script portability
All user-facing `.sh` and `.cmd` files must work when launched from any directory. They should start by changing to their own folder (or the repository root) so that relative paths resolve correctly.

`.sh` scripts must be runnable without requiring `chmod +x`; always invoke them with `bash path/to/script.sh` (do
**not** rely on the system-default `sh`).  Each script must start with a portable she-bang:

```
#!/usr/bin/env bash
set -e -o pipefail -u
```

Every `.sh` script must have a corresponding `.cmd` implementation with identical behavior. Use `.cmd` files rather than `.bat`.

```
# example for a shell script
cd "$(dirname "$0")"/..
```

REM example for a .cmd script  
```
CD /D "%~dp0\.."
```

For robust error handling, `.sh` scripts should begin as shown above, and `.cmd` scripts normally use a simple error check:

```
CALL buildAndTest.cmd %target% || GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%
```

## Silent failures

The traps in this repository do not produce wrong answers, they produce convincing silences. Each of these has cost
someone a working session:

- **Building by hand opts out of every rail in the build scripts.** `NuXJS.h` defaults `NUXJS_ES5` to 1, so a bare
  `BuildCpp` call gives you an es5 engine; run `tests/es3only/` against it and you get nineteen plausible failures
  rather than an error. `buildAndTest` passes `-DNUXJS_ES5=0` for the es3 variant and filters the test directories
  per variant. Use it rather than invoking `BuildCpp` or `test.pika` directly.
- **A `/* */` comment in a `.io` file disables the test.** Every line must begin with `> < ! - * or /`
  (`tools/test.pika`), so a block comment's body discards the section being collected and `*/` reads as the
  disabled-section marker: the suite goes green by not running. `//` is the only comment form `.io` has, which is
  why the three-lines-becomes-a-block rule in `docs/Coding Style.md` section 5 does not apply there - shorten the
  prose instead of reformatting it.
- **`assert` is compiled out of release.** Release-only work, benchmarking above all, silently skips every invariant
  guarded that way - `getOpcodeInfo`'s check that `opcodeInfo[]` agrees with the opcode enum among them. Run the beta
  build over anything that touches such a table.
- **A benchmark delta under about 2% is not evidence.** Two builds of identical machine code measured 0.24-0.46%
  apart; two carrying the same never-emitted opcodes at different enum positions measured 1.2-1.4% apart; and a
  control doing provably nothing read as a four-sigma regression. msvc/x64 and clang/arm64 agree. Any claim needs an
  A/A control measured in the same session, not a comparison against a golden time.
- **Never match working-tree text against blob contents.** Git stores LF whatever the checkout shows, so a script
  comparing the two finds nothing and reports success - a `filter-branch` over 197 commits printed "Ref is unchanged"
  and exited 0.
- **clang-tidy hides headers and, with no real check enabled, runs nothing.** Without `--header-filter='.*'` every
  diagnostic in `NuXJS.h` is dropped, which hid six of the eleven `-Wreorder-ctor` sites. With
  `--checks='-*,clang-diagnostic-*'` alone it prints its usage and exits 1, which a `grep warning:` reads as a clean
  run. Enable one real check alongside, as in `--checks='-*,misc-unused-alias-decls,clang-diagnostic-*'`, and look
  at the exit code.
