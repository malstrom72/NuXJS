# Benchmarks

This directory contains micro benchmarks used to measure NuXJS performance.

## Running `tools/benchmark.pika`

Use `PikaCmd` to run the script:

```
./tools/benchmark.pika <test(s)> <exe>|<rev-range>|makegold ignoregold
```

- `<test(s)>` is a file name or glob pattern for the benchmarks.
  Use `-` or omit the parameter to run every `*.js` file.
- `<exe>|<rev-range>|makegold` can be the path to the
  already compiled `NuXJS` binary, a single revision number or revision range (e.g. `12345-12350`) checked out and built prior to running, or the literal `makegold` to generate reference output.
- `ignoregold` is optional and skips output comparison.

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
