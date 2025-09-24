# Interpreter case reorder benchmark comparison

## Setup
- Baseline: commit `58a7d48` (pre-reorder `Processor::innerRun` case layout).
- Patched: commit `546e551` (`Reorder hot opcode cases in interpreter`).
- Command: `./externals/PikaCmd/PikaCmd tools/benchmark.pika - --runs 1` (one run per benchmark as recommended for the heavy suite).
- Both revisions were rebuilt beforehand with `timeout 180 ./build.sh`.

## Results
| Benchmark | Before (s) | After (s) | Δ (s) |
|-----------|-----------|-----------|-----------|
| `bigArray` | 2.05423 | 2.09039 | +0.03616 |
| `bigObject` | 4.51776 | 4.83154 | +0.31378 |
| `buildStringBuffered` | 0.65206 | 0.74558 | +0.09352 |
| `buildStringNaive` | 0.45736 | 0.51800 | +0.06064 |
| `chess_bm` | 10.57610 | 10.97800 | +0.40190 |
| `evalCalced` | 1.26361 | 1.57757 | +0.31396 |
| `evalString` | 2.44089 | 2.38876 | -0.05213 |
| `eval_bm_1` | 3.47812 | 3.24079 | -0.23733 |
| `eval_bm_2` | 0.36225 | 0.33803 | -0.02422 |
| `for_loop_bm_1` | 2.59800 | 2.38705 | -0.21095 |
| `for_loop_bm_2` | 3.15014 | 2.88245 | -0.26769 |
| `for_loop_bm_3` | 2.23658 | 2.24413 | +0.00755 |
| `function_bm_1` | 0.95755 | 0.97265 | +0.01510 |
| `gc_bm_1` | 2.94475 | 2.72722 | -0.21753 |
| `hash_bm_1` | FAIL | 4.13437 |  |
| `lotsOfWaste` | 5.73936 | 5.63610 | -0.10326 |
| `lz4_bm_1` | 1.19511 | 1.31511 | +0.12000 |
| `math_bm_1` | FAIL | 3.08623 |  |
| `math_bm_2` | 1.10876 | 1.05829 | -0.05047 |
| `math_bm_3` | 1.25773 | 1.20833 | -0.04940 |
| `minimum` | 1.53127 | 1.48450 | -0.04677 |
| `minimumAsFunc` | 1.24160 | 1.17732 | -0.06428 |
| `navierStokes_bm` | 6.28697 | 5.67970 | -0.60727 |
| `noEval` | 0.87227 | 0.88753 | +0.01525 |
| `recursion_bm_1` | 3.48487 | 3.71523 | +0.23036 |
| `regexp` | 8.93824 | 11.40510 | +2.46686 |
| `string_bm_1` | 2.04810 | 2.17414 | +0.12604 |
| `string_bm_2` | 1.76545 | 1.76396 | -0.00149 |
| `xorshift_bm_1` | 1.52643 | 1.53913 | +0.01270 |

Overall median before: **2.05423s**  
Overall median after: **2.17414s**  
Overall delta: **+0.11991s**

## Observations
- The reorder did not yield a net win for the one-run benchmark sweep: the overall median increased by ~5.8%.
- Several hot microbenchmarks regressed (e.g., `regexp`, `chess_bm`, `buildStringBuffered`), while the eval and simple loop tests improved modestly.
- `hash_bm_1` and `math_bm_1` reported `FAIL` under the baseline layout but produced valid medians after the reorder.
- Memory usage columns were unchanged between runs (not shown here for brevity); refer to the raw logs if needed (`/tmp/benchmark_before.txt`, `/tmp/benchmark_after.txt`).
