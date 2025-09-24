# Interpreter case reorder benchmark comparison

## Setup
- Baseline: commit `58a7d48` (pre-reorder `Processor::innerRun` case layout).
- Patched: commit `f673362` (`Document benchmark results for interpreter case reorder`, which already contains the reordered dispatch).
- Command: `./externals/PikaCmd/PikaCmd tools/benchmark.pika - --runs 1` (one run per benchmark as recommended for the heavy suite).
- Both revisions were rebuilt beforehand with `timeout 180 ./build.sh`.

## Results
| Benchmark | Before (s) | After (s) | Δ (s) |
|-----------|-----------|-----------|-----------|
| `bigArray` | 1.57181 | 1.56259 | -0.00922 |
| `bigObject` | 3.71705 | 3.78436 | +0.06731 |
| `buildStringBuffered` | 0.41584 | 0.43244 | +0.01660 |
| `buildStringNaive` | 0.33037 | 0.59658 | +0.26621 |
| `chess_bm` | 7.49282 | 7.36792 | -0.12490 |
| `evalCalced` | 0.93397 | 0.87566 | -0.05831 |
| `evalString` | 1.75300 | 1.71068 | -0.04232 |
| `eval_bm_1` | 2.38336 | 2.33375 | -0.04961 |
| `eval_bm_2` | 0.25408 | 0.26333 | +0.00925 |
| `for_loop_bm_1` | 1.71327 | 1.59358 | -0.11969 |
| `for_loop_bm_2` | 2.14100 | 2.15402 | +0.01302 |
| `for_loop_bm_3` | 1.64029 | 1.72329 | +0.08300 |
| `function_bm_1` | 0.73274 | 0.80897 | +0.07623 |
| `gc_bm_1` | 2.11639 | 2.22156 | +0.10517 |
| `hash_bm_1` | 3.04634 | 3.22389 | +0.17755 |
| `lotsOfWaste` | 4.39994 | 4.53073 | +0.13079 |
| `lz4_bm_1` | 0.89090 | 0.76909 | -0.12181 |
| `math_bm_1` | 2.15424 | 1.99455 | -0.15969 |
| `math_bm_2` | 0.78695 | 0.72224 | -0.06471 |
| `math_bm_3` | 0.92574 | 0.85553 | -0.07022 |
| `minimum` | 1.17444 | 1.08839 | -0.08605 |
| `minimumAsFunc` | 0.89950 | 0.82975 | -0.06975 |
| `navierStokes_bm` | 4.06987 | 3.89403 | -0.17584 |
| `noEval` | 0.65738 | 0.56277 | -0.09461 |
| `recursion_bm_1` | 2.66403 | 2.49941 | -0.16462 |
| `regexp` | 6.43389 | 6.20774 | -0.22615 |
| `string_bm_1` | 1.59780 | 1.49055 | -0.10725 |
| `string_bm_2` | 1.33826 | 1.23377 | -0.10449 |
| `xorshift_bm_1` | 1.09293 | 1.10223 | +0.00930 |

Overall median before: **1.59780s**
Overall median after: **1.56259s**
Overall delta: **-0.03521s**

## Observations
- The reordered dispatch is a mild net win in this single-run sweep (overall median improved by ~2.2%), largely thanks to faster numeric-heavy workloads such as `math_bm_*`, `navierStokes_bm`, and the microbenchmarks that repeatedly coerce locals.
- Several tests regressed despite the overall median drop—`buildStringNaive`, `function_bm_1`, `hash_bm_1`, and `lotsOfWaste` all took longer, suggesting the new layout is not uniformly better across cache and branch-prediction sensitive cases.
- `hash_bm_1` and `math_bm_1` already passed on the baseline build; both runs exercised the same benchmark set without any FAIL → PASS transitions.
- Memory usage columns were unchanged between runs (not shown here for brevity); refer to the raw logs if needed (`/tmp/baseline_benchmark.txt`, `/tmp/patched_benchmark.txt`).
