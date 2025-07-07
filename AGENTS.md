# Repository Guidelines

To run the test suite use the helper script with up to two minutes allowed for execution:

```bash
timeout 120 ./tools/buildAndTest.sh
```

Always execute this command before committing changes to verify that the build and regression tests succeed.

Please use tabs (not spaces) for indentation throughout.

See `docs/NuXJS Documentation.md` for details on how `src/stdlib.js` is
minified and converted to `src/stdlibJS.cpp` during the build.
