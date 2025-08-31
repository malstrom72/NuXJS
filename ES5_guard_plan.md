# Plan to Guard ES5 Differences in NuXJS

## Stage 0 – Baseline

- Ensure the working tree is clean: `git status --short` should show no output.
- Run baseline tests for both ES3 and ES5 builds:
	```
	timeout 600 ./build.sh es3
	timeout 600 ./build.sh es5
	```

## Stage 1 – Guard `NuXJS.h`

- Use `ES51_vs_main_NuXJS.diff` to locate header changes.
- For each addition or modification:
	- Wrap ES5 declarations with `#if (NUXJS_ES5)` and `#endif`.
	- Provide an `#else` block when ES3 behavior must remain.
- After editing `NuXJS.h`, rebuild and test:
	```
	timeout 600 ./build.sh es3
	timeout 600 ./build.sh es5
	```

## Stage 2 – Guard `NuXJS.cpp`

- Work through `ES51_vs_main_NuXJS.diff` sequentially.
        - Surround ES5-only code paths with `#if (NUXJS_ES5)` / `#endif`.
        - Preserve ES3 code in an `#else` block when needed.
- Tackle one logical chunk at a time and build after each:
        1. Guard object literal `get`/`set` syntax in `objectInitialiser()`.
        2. [next step] Guard remaining diff sections.
- After completing each substep, compile and run tests:
        ```
        timeout 600 ./build.sh es3
        timeout 600 ./build.sh es5
        ```

## Stage 3 – Verify build scripts

- Ensure `build.sh` and `build.cmd` pass `-DNUXJS_ES5=0` or `1` accordingly.
- If changes are required, run the combined build to validate both variants:
	```
	timeout 600 ./build.sh
	```

## Stage 4 – Final validation

- Compare the ES3 build output with `main` to confirm no unguarded differences.
- Run the full test suite for both variants one last time:
	```
	timeout 600 ./build.sh es3
	timeout 600 ./build.sh es5
	```

