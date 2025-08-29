# NuXJS

A sandboxed, single C++ source-file JavaScript engine in vanilla C++03 with precise execution control.

## Features

- **Fully ECMAScript 3 compliant** with focused ECMAScript 5 additions (string indexing, JSON).
- Entire engine fits in **one .cpp file, one .h file, and a `stdlib.js`** (~7 000 LOC of C++).
- Written in standard, architecture-agnostic **C++03** – _no_ platform-specific code.
- Fully asynchronous, **non-blocking VM**; run as many cycles as you like between host calls.
- Simple but **fast stack machine**; competitive with other interpreted JS engines.
- **Sandboxed and secure** – guest JS cannot crash the host process.
- Instantiate **any number of engines** across as many threads as you wish.
- Re-entrant and **thread-safe by design** (no hidden globals, nothing implicitly shared).
- **Fast single-pass compiler** (hand-written recursive-descent / precedence parser).
- Mark-and-sweep, stop-the-world **GC** with adaptive trigger rate and memory cap.
- Uses the standard C++ heap with **object pools** for quick allocation of small blocks.
- **Zero external dependencies** (even STL containers are avoided).
- **Standard library and regexp compiler written in JavaScript** for safety and smaller footprint.
- **Easy-to-use high-level C++ API** for integrating and embedding the engine.
- **Extensive automated tests** – zero-tolerance for bugs.

## Sandboxing

- Runs scripts in a contained VM with no built-in file, network, or other system APIs.
- Ships a standard library written entirely in JavaScript; host applications inject native functions to expose capabilities.
- Each runtime keeps its own isolated state with nothing shared across runtimes or threads.
- Hosts may step execution and bound resources via `Runtime::setMemoryCap` and `Runtime::resetTimeOut`.
- All failures surface as managed exceptions, preventing crashes and keeping untrusted code within the sandbox.

## Why ECMAScript 3?

ECMAScript 3 was the first broadly adopted JS standard; it provides everything needed in a _scripting_ language without
a large runtime or a complex compiler. Staying with ES3 keeps the engine tiny and predictable. Selective ES5 features
are “back-ported” where they add essential value, e.g.:

- Character indexing on `String` via `str[i]`
- `JSON` support

## Why C++03?

This project began a few years before C++11. When I resumed work on it, I chose to keep the original C++03 style for
consistency. The code is simple, just basic templates and plain C++ classes, and has minimal dependencies, so updating
to a newer C++ standard didn’t feel necessary. Some C++11 features would be useful, especially in the high-level API,
but I have prioritized consistency.

## Prerequisites

You will need a standard C++ compiler with C++03 support.

- On **macOS** or **Linux**, use `g++` or `clang++`.
- On **Windows**, the build requires Microsoft Visual C++. Any version from Visual Studio 2008 (VC9.0) onward should
  work. The build script automatically locates the latest version using `vswhere.exe`, falling back to older versions
  if needed.

## Build & Test

Run `./build.sh` (or `build.cmd` on Windows) from the root. This calls `tools/buildAndTest.sh`, which builds both
the **beta** and **release** configurations and runs all tests.

Both the **beta** and **release** targets are compiled with optimizations enabled. The **beta** build retains runtime
assertions for debugging purposes, while the **release** build disables assertions for maximum performance.

During this process, `src/stdlib.js` is minified and converted into `src/stdlibJS.cpp`. See `docs/NuXJS
Documentation.md` for details.

The build outputs a console REPL named `NuXJS`. Type `help()` inside the REPL to see available helper functions and
commands.

## ECMAScript 3 Compliance

- Zero failures across 3,242 applicable ES3 tests (Test262).
- 1,349 tests are excluded by category and not counted toward ES3 support:
  - ES >3: 1,218 (modern features not targeted)
  - TBD: 112 (pending triage or harness compatibility)
  - BY DESIGN: 19 (intentional, documented deviations)

These results come from the Test262 harness included in this repo; see the dashboard below to reproduce.

About Test262: we use an older snapshot, the newest one we found that still runs ES3 engines. Newer Test262 assumes ES5+
semantics and a different harness, so it would mark out‑of‑scope features as failures.

## Test262 Dashboard

The Test262 suite is stored as an archive in `externals/` and extracted to `externals/test262-master/` on first use.

- Manual unpack (optional): `tar -xzf externals/test262-master.tar.gz -C externals`
- Start the dashboard server: `node tools/testdash.node.js` (opens a browser)
- CLI mode (headless summary): `node tools/testdash.node.js --cli`
- Include ignored categories in the summary: `node tools/testdash.node.js --cli --include-ignored`
- Reset category for all passing tests (does not touch failures; also includes ignored):
  `node tools/testdash.node.js --cli --reset-passed`

Python 2 requirement (for the Test262 harness):

- Install a self-contained Python 2 shim: `bash tools/setupPython2.sh`
- Add the shim to PATH in this terminal: `export PATH="$HOME/.local/bin:$PATH"`
- The script appends this to `~/.zshrc`/`~/.bashrc` for future shells.
- Verify: `python2 -V` → prints Python 2.7.x
- One-off run without editing PATH: `PATH="$HOME/.local/bin:$PATH" node tools/testdash.node.js --cli`

Apple Silicon note: Python 2 packages are only available for x86_64. The setup script creates an `osx-64` conda env that
runs under Rosetta 2. If needed, install Rosetta: `softwareupdate --install-rosetta --agree-to-license`.

Windows: use `tools/setupPython2.cmd` (wraps the bash script) and run the Node commands in a shell where `python2` resolves.

Notes:

- The dashboard auto-extracts `externals/test262-master.tar.gz` if `externals/test262-master/` is missing.

## ES3 vs ES5.1 Builds

This branch layers an ES5.1 feature set on top of the stable ES3 core. ES5.1 is controlled by the `NUXJS_ES5` compile‑time switch and is enabled by default in this branch.

- Default (ES5.1 on): run `./build.sh` (or `build.cmd`). ES5 tests under `tests/es5/` are included.
- Force ES3‑only: set `NUXJS_ES5=0` via `CPP_OPTIONS` to disable ES5.1 features and tests.
  - macOS/Linux: `CPP_OPTIONS='-DNUXJS_ES5=0' ./build.sh`
  - Windows (PowerShell): `$env:CPP_OPTIONS='/DNUXJS_ES5=0'; ./build.cmd`
  - Windows (cmd): `SET CPP_OPTIONS=/DNUXJS_ES5=0 && build.cmd`
- Explicit ES5.1: you can also pass it explicitly (not required):
  - macOS/Linux: `CPP_OPTIONS='-DNUXJS_ES5=1' ./build.sh`
  - Windows (cmd): `SET CPP_OPTIONS=/DNUXJS_ES5=1 && build.cmd`

### Test Both Variants (ES3 and ES5.1)

- Two‑pass mode: set `NUXJS_TEST_ES5_VARIANTS=1` to build and run the full suite twice (first with ES3, then with ES5.1):
  - `NUXJS_TEST_ES5_VARIANTS=1 ./build.sh`
- Faster inner loop: when using two‑pass mode during development, skip the release target:
  - macOS/Linux: `NUXJS_SKIP_RELEASE=1 NUXJS_TEST_ES5_VARIANTS=1 ./tools/buildAndTest.sh beta`
  - Windows (cmd): `SET NUXJS_SKIP_RELEASE=1 & SET NUXJS_TEST_ES5_VARIANTS=1 & tools\buildAndTest.cmd beta`

Notes:

- In single‑pass builds, ES5 tests are included unless you explicitly disable ES5 via `-DNUXJS_ES5=0`.
- See `docs/ES5.1 Roadmap.md` for current coverage, open items, and semantic notes (e.g. `Function.prototype.bind`, strict mode, accessors, and `Object.create`/`Object.defineProperties`).

## Example

Here’s a minimal example of embedding NuXJS using the high-level API:

```cpp
#include <NuXJS.h>
using namespace NuXJS;

int main(int argc, const char* argv[]) {
    Heap heap;                                          // We use the standard heap.
    Runtime rt(heap);                                   // Construct an empty engine.
    rt.setupStandardLibrary();                          // Install the ES3 standard library.
    Var helloWorld = rt.eval("'hello ' + 'world'");     // Evaluate a JS expression.
    std::wcout << helloWorld << std::endl;
    return 0;
}
```

## Helper Scripts

- `build.sh` / `build.cmd` – build both the **beta** and **release** targets and run all tests
- `tools/buildAndTest.sh` / `.cmd` – build and test a single configuration
- `tools/runExamples.sh` / `.cmd` – compile and run all example programs
- `tools/BuildCpp.sh` / `.cmd` – low-level wrapper around the C++ compiler

## Benchmarking

- `tools/benchmark.pika` – run NuXJS micro benchmarks or generate golden results
- `tools/compareEngines.sh` / `.cmd` – download Duktape and QuickJS and compare their performance to NuXJS
 
## Building the fuzz target

The `tools/buildReplFuzz.sh` script compiles `tools/NuXJSREPL.cpp` using clang and libFuzzer:

```bash
bash tools/buildReplFuzz.sh
```

The resulting binary is placed in `output/NuXJSFuzz` and can be run with a directory containing seed inputs:

```bash
./output/NuXJSFuzz corpus/
```

On macOS the default clang from Xcode does not ship the libFuzzer runtime. Install the `llvm` package via Homebrew and
invoke the script with that compiler:

```bash
CPP_COMPILER=$(brew --prefix llvm)/bin/clang++ bash tools/buildReplFuzz.sh
```

To seed the fuzzer with inputs derived from the existing test suite, generate a corpus from the `.io` files:

```bash
PikaCmd tools/makeCorpus.pika corpus
```

Each section of every test file is written as a separate entry in the specified directory.

## Documentation

- [NuXJS Documentation](docs/NuXJS%20Documentation.md)
- [Standard Library Guidelines](docs/Standard%20Library%20Guidelines.md)
- [ECMAScript Compatibility Notes](docs/notes/ECMAScript%20Compatibility%20Notes.md)
- [TypeScript Compatibility](docs/notes/TypeScript%20Compatibility.md)
- [ES5.1 Implementation Roadmap](docs/ES5.1%20Roadmap.md)

## AI Usage

AI tools (such as OpenAI Codex) have occasionally been used to assist with documentation, code comments, test
generation, and repetitive edits. All core source code has been written and refined by hand over many years.

This ES5.1 branch is an experiment informed by AI-assisted development (tests, porting helpers, and doc
scaffolding), layered on top of the long‑standing ES3 core. All non-trivial changes are code‑reviewed and
validated by the test suite.

## License

This project is released under the [BSD 2-Clause License](LICENSE).
