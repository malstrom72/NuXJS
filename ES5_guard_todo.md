# ES5 Guard TODO

- **Important:** `timeout 600 ./build.sh es3` and `timeout 600 ./build.sh es5` must run to completion. If either build is interrupted or fails, roll back to the last working commit and fix before committing.

## Completed
- Guarded `Runtime::compileEvalCode` so ES3 builds keep the single-argument signature.

## Remaining
- Guard remaining diffs noted in `tools/diffs/whitespace_ignored_diff_from_main.patch` with `#if (NUXJS_ES5)`.

