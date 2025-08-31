# Plan to Guard ES5 Differences in NuXJS

## Stage 0 – Baseline

- [x] Ensure the working tree is clean: `git status --short` should show no output.
- [x] Run baseline tests for both ES3 and ES5 builds:
        ```
        timeout 600 ./build.sh es3
        timeout 600 ./build.sh es5
        ```

## Stage 1 – Guard `NuXJS.h`

- [x] Use `ES51_vs_main_NuXJS.diff` to locate header changes.
- [x] For each addition or modification:
        - Wrap ES5 declarations with `#if (NUXJS_ES5)` and `#endif`.
        - Provide an `#else` block when ES3 behavior must remain.
- Recommended order:
        1. ✅ Wrap `compileEvalCode`'s `strict` parameter and add an ES3-only overload.
        2. ☐ Guard accessor infrastructure (`ACCESSOR_FLAG`, `class Accessor`, and accessor-aware `Property` helpers`).
- After editing `NuXJS.h`, rebuild and test:
        ```
        timeout 600 ./build.sh es3
        timeout 600 ./build.sh es5
        ```

## Stage 2 – Guard `NuXJS.cpp`

- [x] Work through `ES51_vs_main_NuXJS.diff` sequentially.
        - Surround ES5-only code paths with `#if (NUXJS_ES5)` / `#endif`.
        - Preserve ES3 code in an `#else` block when needed.
- Tackle one logical chunk at a time and build after each:
        1. ✅ Guard object literal `get`/`set` syntax in `objectInitialiser()`.
        2. ✅ Guard `Runtime::compileEvalCode` implementation and callers.
        3. ☐ Add guards for accessor-aware property handling.
                - [x] Guard Object::getProperty/setProperty and interpreter opcodes
                - [ ] Guard remaining accessor classes and property helpers
- After completing each substep, compile and run tests:
        ```
        timeout 600 ./build.sh es3
        timeout 600 ./build.sh es5
        ```

## Stage 3 – Verify build scripts

- [x] Ensure `build.sh` and `build.cmd` pass `-DNUXJS_ES5=0` or `1` accordingly.
- [ ] If changes are required, run the combined build to validate both variants:
        ```
        timeout 600 ./build.sh
        ```

## Stage 4 – Final validation

- [ ] Compare the ES3 build output with `main` to confirm no unguarded differences.
- [ ] Run the full test suite for both variants one last time:
        ```
        timeout 600 ./build.sh es3
        timeout 600 ./build.sh es5
        ```

