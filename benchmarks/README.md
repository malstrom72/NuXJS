# Benchmarks

This directory contains micro benchmarks used to measure NuXJS performance.

## Running `tools/benchmark.node.js`

Run the Node.js benchmark harness from the repository root:

```
node tools/benchmark.node.js <test(s)> <exe>|makegold ignoregold [--runs <count>]
```

- `<test(s)>` is a file name or glob pattern for the benchmarks.
  Use `-` or omit the parameter to run every `*.js` file.
- `<exe>|makegold` can be the path to the already compiled `NuXJS` binary
  or the literal `makegold` to generate reference output.
- `ignoregold` is optional and skips output comparison.
- `--runs <count>` (or `-r <count>`) overrides the number of
  executions collected before computing the median. The default is 5.
- `--flip` transposes the final summary so each row shows a benchmark,
  the recorded run samples, and the aggregate statistics.

## Output

Each benchmark prints its runtime and the memory statistics reported by
running `NuXJS` with the `-t` flag:

- `median` – median CPU time from the collected samples.
- `mem1` – heap usage (MiB) when the benchmark finished.
- `mem2` – peak heap usage (MiB) observed during the run.
- `mem3` – peak memory reserved by the allocator (MiB), including pooled blocks.

By default the summary table lists benchmarks as columns with the
statistics above as rows. When `--flip` is supplied the harness instead
prints one row per benchmark, followed by the individual run samples,
and then the same median and memory columns.

After the table the harness prints both the overall median and the
arithmetic mean across all benchmark medians.

## Golden results

Benchmark output is normally checked against the files in `benchmarks/golden/`.  Differences create `failed.txt` and `expected.txt` in the current directory.

## Building the engine for benchmarking

Compile the binary using the regular `./build.sh` wrapper or call the low-level helper directly:

```
bash tools/BuildCpp.sh release x64 ./output/NuXJS \
    tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp
```

Either approach leaves `output/NuXJS` ready for benchmarking.

## Running `tools/compareEngines.sh`

To compare NuXJS with other engines, run the helper script from the repository root:

```
bash tools/compareEngines.sh
```

Pass specific benchmark files to limit the run:

```
bash tools/compareEngines.sh benchmarks/bigArray.js benchmarks/bigObject.js
```

The script downloads and builds Duktape and QuickJS, runs each benchmark, and reports execution times alongside NuXJS.
