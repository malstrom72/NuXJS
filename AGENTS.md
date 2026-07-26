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
