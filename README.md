# NuXJS

A sandboxed, single C++ source-file JavaScript engine in vanilla C++03 with precise execution control.

## Features

- **Fully ECMAScript 3 compliant** with focused ECMAScript 5 additions (string indexing, JSON).
- Entire engine fits in **one .cpp file, one .h file, and a `stdlib.js`** (~7 000 LOC of C++); the `stdlib.js` is also generated into a `stdlibJS.cpp` array for embedding.
- Written in portable, standard **C++03** – no OS-specific code, just a few small compiler shims (e.g. MSVC math intrinsics). Tested with GCC and Clang (x86-64 and ARM) and MSVC.
- Fully asynchronous, **non-blocking VM**; run as many cycles as you like between host calls.
- Simple but **fast stack machine**; competitive with other interpreted JS engines.
- **Sandboxed and secure** – guest JS cannot crash the host process.
- Instantiate **any number of engines** across as many threads as you wish.
- Re-entrant and **thread-safe by design** (no hidden globals, nothing implicitly shared).
- **Fast single-pass compiler** (hand-written recursive-descent / precedence parser).
- Mark-and-sweep, stop-the-world **GC** with adaptive trigger rate and memory cap.
- Uses the standard C++ heap with **object pools** for quick allocation of small blocks.
- **Zero external dependencies** – the engine core uses its own containers; STL types (`std::string`/`std::vector`) appear only at the C++ API boundary.
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

The build and test helpers that perform tasks like minifying the standard library or executing the `.io`
suite run under PikaScript (`PikaCmd`). Relying on PikaScript for these critical steps keeps the project
bootstrappable on a fresh machine without first installing other language runtimes such as Node or Python.
We still leverage Node for auxiliary tooling—most notably the Test262 dashboard in `tools/testdash.*`—but
those utilities are optional once the core engine has been built.

The build outputs a console REPL named `NuXJS`. Type `help()` inside the REPL to see available helper functions and
commands.

## ECMAScript 3 Compliance

- Zero failures across 6542 applicable ES3 tests (Test262).
- 9239 tests are excluded by category and not counted toward ES3 support:
  - ES >3: 8943 (modern features not targeted for ES3, main)
  - BAD TEST: 101 (tests depend on features not available in ES3)
  - BY DESIGN: 195 (intentional, documented deviations)

These results come from the Test262 harness included in this repo; see `docs/Test262 Dashboard.md` for the developer-focused
dashboard that reproduces them.

About Test262: we use an older snapshot, the newest one we found that still runs ES3 engines. Newer Test262 assumes ES5+
semantics and a different harness, so it would mark out-of-scope features as failures.

In addition, the build script performs regression tests written in C++ and JavaScript (over 4500 source code files with
various tests at the moment).

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
- `tools/buildAndTest.sh` / `.cmd` – build and test a single configuration, including the examples
- `tools/benchmark.node.js` – run NuXJS micro benchmarks or generate golden results
 
## Documentation

- [NuXJS Documentation](docs/NuXJS%20Documentation.md)
- [TypeScript Compatibility](docs/notes/TypeScript%20Compatibility.md)

## Building the fuzz target

The `tools/buildReplFuzz.sh` script compiles `tools/NuXJSREPL.cpp` using clang and libFuzzer:

```bash
bash tools/buildReplFuzz.sh
```

The resulting binary is placed in `output/NuXJSFuzz` and can be run with a directory containing seed inputs:

```bash
./output/NuXJSFuzz corpus/
```

To seed the fuzzer with inputs derived from the existing test suite, generate a corpus from the `.io` files:

```bash
PikaCmd tools/makeCorpus.pika corpus
```

Each section of every test file is written as a separate entry in the specified directory.

## AI Usage

AI tools (such as OpenAI Codex) have occasionally been used to assist with documentation, code comments, test
generation, and repetitive edits. All core source code has been written and refined by hand over many years.

## License

This project is released under the [BSD 2-Clause License](LICENSE).
