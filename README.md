# NuXJS

A sandboxed, single C++ source-file JavaScript engine in vanilla C++03 with precise execution control.

## Features

- **Fully ECMAScript 5.1 compliant** (the es5 build): strict mode, accessors, the complete `Object` reflection API and ES5 library. An **es3 build** of the same sources remains fully ECMAScript 3 compliant and byte-for-byte stable.
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

## Two editions: ES5.1 and ES3

The engine builds from one source tree into two editions, selected with the `NUXJS_ES5` compile switch:

- The **es5 build** implements ECMAScript 5.1 in full: strict mode, getters and setters, `Object.defineProperty`
  and the rest of the reflection statics, `Function.prototype.bind`, the Array iteration methods, the URI handlers,
  and the ES5 `Date` and `JSON` refinements. ES5.1 is the last edition that is still a small _scripting_ language,
  everything after it grows the runtime and the grammar substantially, and staying there keeps the engine tiny
  and predictable.
- The **es3 build** is the original, fully ECMAScript 3 compliant core, with a handful of ES5 conveniences it has
  always carried (character indexing on `String` via `str[i]`, `JSON` support). It is kept byte-for-byte identical
  while the es5 build evolves: the es3 object files must compile to the same bytes as the `main` branch, a gate
  verified on every change, so embedders who depend on the frozen core lose nothing.

The two builds share the interpreter, the compiler and most of `stdlib.js`; the ES5 additions live behind the
`NUXJS_ES5` guard and `//#if ES5` fences.

## Why C++03?

This project began a few years before C++11. When I resumed work on it, I chose to keep the original C++03 style for
consistency. The code is simple, just basic templates and plain C++ classes, and has minimal dependencies, so updating
to a newer C++ standard didn’t feel necessary. Some C++11 features would be useful, especially in the high-level API,
but I have prioritized consistency.

## Prerequisites

You will need a standard C++ compiler with C++03 support.

- On **macOS** or **Linux**, use `g++` or `clang++`.
- On **Windows**, the build requires Microsoft Visual C++. Any version from Visual Studio 2008 (VC9.0) onward should
  work for the **es3** edition. The **es5** edition needs **Visual Studio 2019 or later**: its standard library
  arrives as one string literal of 65,865 characters, and compilers up to and including Visual Studio 2017 cap a
  literal at 65,535 bytes after concatenation, rejecting it with `C1091`. The build script automatically locates the
  latest version using `vswhere.exe`, falling back to older versions if needed.

## Build & Test

Run `./build.sh` (or `build.cmd` on Windows) from the root. By default this builds **both editions** (es3 and es5)
in both the **beta** and **release** configurations and runs each build's tests; `./build.sh es5 release` builds a
single combination (arguments are recognized by value and may appear in any order). The release REPLs land in
`output/` as `NuXJS` (es3) and `NuXJS_ES5` (es5).

Both the **beta** and **release** targets are compiled with optimizations enabled. The **beta** build retains runtime
assertions for debugging purposes, while the **release** build disables assertions for maximum performance.

During this process, `src/stdlib.js` is minified and converted into `src/stdlibJS.cpp`. See `docs/NuXJS
Documentation.md` for details.

The build and test helpers that perform tasks like minifying the standard library or executing the `.io`
suite run under PikaScript (`PikaCmd`). Relying on PikaScript for these critical steps keeps the project
bootstrappable on a fresh machine without first installing other language runtimes such as Node or Python.
We still leverage Node for auxiliary tooling—most notably the Test262 dashboard in `tools/testdash.*`—but
those utilities are optional once the core engine has been built.

The build outputs console REPLs named `NuXJS` (es3) and `NuXJS_ES5` (es5). Type `help()` inside the REPL to see available helper functions and
commands.

## ECMAScript Compliance

**ES5.1 (es5 build)**, measured with the Test262 harness in this repo, strict-mode runs included
(`node tools/testdash.node.js --cli --include-strict`):

- **Zero failures across 11353 applicable ES5.1 tests** out of 16255 in the snapshot.
- 4902 tests are excluded by category and not counted toward ES5.1 support:
  - ES >5.1: 4656 (the test's own `es6id`/missing `es5id` frontmatter, or verified ES2015+ semantics under an
    `es5id`, each of the latter recorded with a clause citation in `tools/testdash.json`)
  - BAD TEST: 199 (contradict the ES5.1, and usually also the ES3, spec text; each recorded with a citation)
  - BY DESIGN: 47 (intentional deviations, documented in `docs/notes/ECMAScript Compatibility Notes.md`)

**ES3 (es3 build)**, measured the same way on the `main` branch with ES3 scoping:

- Zero failures across 6542 applicable ES3 tests.
- 9239 tests are excluded by category: ES >3: 8943, BAD TEST: 101, BY DESIGN: 195.

See `docs/Test262 Dashboard.md` for the developer-focused dashboard that reproduces these numbers, including the audit
methodology behind every exclusion.

About Test262: we use the newest snapshot we found that still runs pre-ES6 engines; the current suite assumes an ES6+
harness. Each test's scope is derived from its own edition-id frontmatter.

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
    rt.setupStandardLibrary();                          // Install the standard library.
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
- [ECMAScript Compatibility Notes](docs/notes/ECMAScript%20Compatibility%20Notes.md)
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

The ES3 core, the engine, compiler, VM and original standard library, was written and refined by hand over many
years. The ES5.1 lift is a different story: it was implemented in collaboration with an AI assistant (Anthropic's
Claude), working from a clean-room roadmap under close human direction and review. Every change was gated on the
es3 build staying byte-for-byte identical, both test suites, differential comparison against V8, and the Test262
dashboard.

## License

This project is released under the [BSD 2-Clause License](LICENSE).
