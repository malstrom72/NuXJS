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

- **Implement from the spec, not from memory.** The full ES5.1 standard is `docs/specs/ECMA-262 5.1.md` (clause-numbered). Read the relevant clause before writing a feature and follow its numbered algorithm steps literally — including the pedantic parts: `Reject`/Throw semantics, `SameValue` versus `===`, "an absent field takes its default value", and the exact `CheckObjectCoercible` / `ToObject` / `ToString` ordering.
- **Cite the clause in every test.** Each `tests/es5/*.io` names the clause it verifies (e.g. `// ES5.1 8.12.9 step 7`). Give each fiddly spec branch its own test section — those are exactly where a plausible implementation silently diverges from the standard.
- **Guard additively; keep ES3 pristine.** Every ES5 change is wrapped in `#if NUXJS_ES5`, is strictly additive, and must not alter an ES3 code path. The ES3 build (with `NUXJS_ES5` undefined) must stay behaviourally identical — ideally the es3 release binary is byte-for-byte unchanged. Verify by building both variants.
- **Standard-library additions go in `src/stdlibES5.js`**, never in `stdlib.js`; the base library and the ES3 native `support` contracts stay untouched.
- **Document intentional deviations** in `docs/notes/ECMAScript Compatibility Notes.md` rather than leaving a silent gap.

See `docs/ES5.1 Roadmap.md` for the plan and current status.

## Repository layout
The project uses a consistent folder structure. Build output is written to `output/` and no source files live there. Useful locations:

- `tools/` – scripts for building and maintaining the code and documentation.
- `projects/` – Xcode and Visual Studio project files.
- `docs/` – documentation.
- `externals/` - projects and source code from other repositories (only touch this content when explicitly asked to).
- `src/` – C++ source code for the library. The library is distributed as source rather than prebuilt binaries.
- `tests/` – regression tests.
- `benchmarks/` – JavaScript performance tests.
- `output/` – contains only build artifacts (and any runtime dependencies), no source files.

Root-level `build.sh` and `build.cmd` (mirrored implementations) should build and test both the beta and release targets.

### PikaCmd directory
The `externals/PikaCmd` folder is a separate project copied into this repository. Ignore it when applying formatting or running tests.

### BuildCpp
BuildCpp.sh and BuildCpp.cmd are copied from another repository. Only make changes to them if there is no other solution.

## Formatting rules
Key style points:
- Tab characters for indentation, *not spaces*. A tab character equals four spaces.
- Opening braces stay on the same line as the control statement and closing braces are on their own line.
- Maximum line width is 120 characters. End-of-line comments may start at column 120.
- Line continuations should start with the operator and be indented two tabs from the original line.
- `#if`/`#endif` blocks should appear one tab *left* of the current indentation level.
- Class comment – put a plain C-style block comment immediately above each class, *not* Doxygen.  
       ```
       /**
               One-sentence summary of what the class does.
               Extra details if truly needed.
       **/
       ```
	* The two asterisks open/close the block; everything inside is indented with one tab.  
- Small method comment – use a single end-of-line comment:  
	void blahblah(int blah);	/// brief description of `blahblah`
- Inside comment text, wrap any variable, parameter, class or function names in back-ticks, e.g. `blah` is the temporary buffer.

When handling files with command-line tools:
- Always run `expand -t 4` on the file before processing.
- Always run `unexpand -t 4` on the file after processing.

See `docs/NuXJS Documentation.md` for details on how `src/stdlib.js` is minified and converted to `src/stdlibJS.cpp` during the build, and `docs/Standard Library Guidelines.md` for rules when editing the standard library.

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
