# Repository Guidelines

To run the test suite use the helper script with up to two minutes allowed for execution:

```bash
timeout 120 ./tools/buildAndTest.sh
```

Always execute this command before committing changes to verify that the build and regression tests succeed.

### PikaCmd directory
The `tools/PikaCmd` folder is a separate project copied into this repository.
Ignore it when applying formatting or running tests.

Please use tabs (not spaces) for indentation throughout.

### Formatting rules
Key style points:
- Tabs (width 4) for indentation.
- Opening braces stay on the same line as the control statement and closing braces are on their own line.
- Maximum line width is 120 characters. End-of-line comments may start at column 120.
- Line continuations should start with the operator and be indented two tabs from the original line.
- `#if`/`#endif` blocks should appear one tab *left* of the current indentation level.

See `docs/NuXJS Documentation.md` for details on how `src/stdlib.js` is
minified and converted to `src/stdlibJS.cpp` during the build.

### Script portability
All user-facing `.sh` and `.bat` files must work when launched from any directory.  
They should start by changing to their own folder (or the repository root) so that
relative paths resolve correctly.

```bash
# example for a shell script
cd "$(dirname "$0")"/..

REM example for a batch script
CD /D "%~dp0\.."
```
