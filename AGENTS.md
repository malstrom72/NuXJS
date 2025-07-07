# Repository Guidelines

To run the test suite use the helper script with up to two minutes allowed for execution:

```bash
timeout 120 ./tools/buildAndTest.sh
```

Always execute this command before committing changes to verify that the build and regression tests succeed.

Please use tabs (not spaces) for indentation throughout.

### Formatting rules
Source files are formatted with `clang-format` using the configuration in `.clang-format`.
Run `clang-format -i <file>` or `clang-format -n --Werror <file>` before committing.
Key style points:
- Tabs (width 4) for indentation.
- Opening braces stay on the same line as the control statement and closing braces are on their own line.
- Maximum line width is 120 characters. End-of-line comments may start at column 120.
- Line continuations should start with the operator and be indented two tabs from the original line.
- `#if`/`#endif` blocks should appear one tab *left* of the current indentation level.

See `docs/NuXJS Documentation.md` for details on how `src/stdlib.js` is
minified and converted to `src/stdlibJS.cpp` during the build.
