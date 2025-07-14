# NuXJS
A sandboxed, single C++ source-file JavaScript engine in vanilla C++03 with fine-grained execution control.

## Features

- **Fully ECMAScript 3 compliant** with focused ECMAScript 5 additions (string indexing, JSON).  
- Entire engine fits in **one .cpp file, one .h file, and a `stdlib.js`** (~7 000 LOC of C++).  
- Written in standard, architecture-agnostic **C++03** – *no* platform-specific code or STL containers.  
- Fully asynchronous, **non-blocking VM**; run as many cycles as you like between host calls.  
- Simple but **fast stack machine**; competitive with other interpreted JS engines.  
- **Sandboxed and secure** – guest JS cannot crash the host process.  
- Instantiate **any number of engines** across as many threads as you wish.  
- Re-entrant and **thread-safe by design** (no hidden globals, nothing implicitly shared).  
- **Fast single-pass compiler** (hand-written recursive-descent / precedence parser).  
- Mark-and-sweep, stop-the-world **GC** with adaptive trigger rate and memory cap.  
- Uses the standard C++ heap with **object pools** for quick allocation of small blocks.  
- **Zero external dependencies** (even STL containers are avoided).
- **Standard library and regexp compiler written in JavaScript** for safety and clarity.
- **Easy-to-use high-level C++ API** for integrating and embedding the engine.
- **Extensive automated tests** – zero-tolerance for bugs.

## Why ECMAScript 3?

ECMAScript 3 was the first broadly adopted JS standard; it provides everything needed in a *scripting* language without
a large runtime or a complex compiler. Staying with ES3 keeps the engine tiny and predictable. Selective ES5 features are
“back-ported” where they add clear value:

- Character indexing on `String` via `str[i]`
- `JSON` support

## Why C++03?

This project began a few years before C++11. When I resumed work on it, I chose to keep the original C++03 style for consistency. The code is simple — just basic templates and plain C++ classes — and has minimal dependencies, so updating to a newer C++ standard didn’t feel necessary. Some C++11 features would be useful, especially in the high-level API, but I have prioritized consistency.

## Prerequisites

You will need a standard C++ compiler with C++03 support.

- On **macOS** or **Linux**, use `g++` or `clang++`.
- On **Windows**, the build requires Microsoft Visual C++. Any version from Visual Studio 2008 (VC9.0) onward should work. The build script automatically locates the latest version using `vswhere.exe`, falling back to older versions if needed.

## Build & Test

Run `./build.sh` (or `build.cmd` on Windows) from the root. This calls `tools/buildAndTest.sh`, which builds both the **beta** and **release** configurations and runs all tests.

Both the **beta** and **release** targets are compiled with optimizations enabled. The **beta** build retains runtime assertions for debugging purposes, while the **release** build disables assertions for maximum performance.

During this process, `src/stdlib.js` is minified and converted into `src/stdlibJS.cpp`. See `docs/NuXJS Documentation.md` for details.

## Example

Here’s a minimal example of embedding NuXJS using the high-level API:

```cpp
#include <NuXJScript.h>
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
- `tools/testAllConfigs.sh` / `.cmd` – exercise every debug and release build for each CPU model
- `tools/BuildCpp.sh` / `.cmd` – low-level wrapper around the C++ compiler

 ## Documentation

 - [NuXJS Documentation](docs/NuXJS%20Documentation.md)
 - [Changes for ES5](docs/ChangesForES5.txt)
 - [Native Call Thoughts](docs/NativeCallThoughts.txt)

## AI Usage

AI tools (such as OpenAI Codex) have occasionally been used to assist with documentation, code comments, test generation, and repetitive edits. All core source code has been written and refined by hand over many years.

## License

This project is released under the [BSD 2-Clause License](LICENSE).

