# Fuzzing

Version: 2026-10-07b

How these projects fuzz with libFuzzer. Every copy of this file is identical apart from the "Local additions" section
at the end, which holds a project's targets, scripts and exceptions.

## Machines

- The Mac (clang, AddressSanitizer plus UndefinedBehaviorSanitizer) is the main fuzzing machine. It is the fastest per
  worker and the only one with both sanitizers by default.
- Windows runs MSVC `/fsanitize=address /fsanitize=fuzzer` by default. It adds capacity and covers what only Windows
  has: 32-bit `long`, the MSVC compiler and runtime, and the Win32 backends.
- clang-cl on Windows is allowed only for a build that has passed the throw test under "clang-cl on Windows".
- Check the load before starting (`uptime` on the Mac) and keep to about 4 workers per campaign while other projects
  are running. Watch free disk space: nothing stops a run when the disk fills.

## Building

Build optimized with asserts on: the release target plus `/U NDEBUG` (MSVC, clang-cl) or `-UNDEBUG` (clang). Never
`-O0`, which is several times slower. Release is required on Windows anyway, because libFuzzer links against the
static release runtime.

- Mac clang: `-fsanitize=fuzzer,address,undefined -fno-sanitize-recover=all -UNDEBUG`.
- MSVC: `/fsanitize=address /fsanitize=fuzzer /U NDEBUG`, and copy MSVC's `clang_rt.asan_dynamic-x86_64.dll` next to
  the executable. The two options must be separate: MSVC ignores clang's comma form with only a warning, and the link
  then fails with a misleading missing-entry-point error.

Link with an 8 MB stack on Windows (`/link /STACK:8388608`), since deep recursion otherwise overflows the 1 MB default
long before it would on the Mac.

### clang-cl on Windows

clang-cl's sanitizer instrumentation breaks MSVC C++ exception handling. A target that throws can crash inside
`__CxxFrameHandler3` (an access violation, often at `0xffffffffffffffff`), stop with exit code `0x80000003`, or
silently run the wrong code. A build needs all of the following:

- `/Ob0`: SanitizerCoverage puts callbacks in catch blocks without the funclet bundle, so the rest of the handler is
  replaced with unreachable code (llvm#212404). Without inlining, fewer comparisons land in catch blocks. This makes
  the bug rarer; it does not remove it.
- `-fsanitize-address-use-after-return=never`: ASan's fake stack breaks unwinding.
- `/D _DISABLE_STRING_ANNOTATION /D _DISABLE_VECTOR_ANNOTATION`: otherwise linking fails on `annotate_string`.
- The release target: libFuzzer needs the static release runtime (`/MT`).

Copy LLVM's `clang_rt.asan_dynamic-x86_64.dll` (from `lib\clang\<version>\lib\windows`), not MSVC's. With BuildCpp,
quote the compiler path because it contains a space:
`CPP_COMPILER="C:\Program Files\LLVM\bin\clang-cl.exe"`.

The throw test: before a clang-cl build is trusted, replay a corpus in which most inputs make the target throw through
both that build and a plain build of the same target without sanitizers, and require identical outcomes (status and
output) for every input. Zero crashes is not enough, since a handler cut short can run on to the wrong result without
crashing. The reference must be truly plain: with coverage instrumentation (`-fsanitize=fuzzer-no-link`) it breaks in
the same way, and the comparison proves nothing. Repeat the test whenever LLVM is updated.

## The harness

Remove every route to files, the console and the system from the target itself. Replacing a variable or a name is not
enough when the same function can still be reached another way.

A differential target, which compares implementations of the same thing, cannot find a bug they all share, such as a
range check that overflows the same way in each. It complements reading the bounds checks; it does not replace it.

Turn off CRT dialogs in `LLVMFuzzerInitialize`, or a failed assert hangs the worker on a message box:

```cpp
#if defined(_MSC_VER)
	_set_error_mode(_OUT_TO_STDERR);
	_set_abort_behavior(0, _WRITE_ABORT_MSG | _CALL_REPORTFAULT);
	_CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE);
	_CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDERR);
	_CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE);
	_CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDERR);
#endif
```

## Running

- Pass `-artifact_prefix=<folder>/`, or crash files land in the current directory, which is easy to commit by mistake.
- Pass a scratch folder as the first corpus directory, since libFuzzer writes new inputs there. Use forward slashes in
  `-dict` paths on Windows.
- Mac environment:
  ```bash
  symbolizer="$(brew --prefix llvm)/bin/llvm-symbolizer"
  export ASAN_OPTIONS="detect_container_overflow=0:external_symbolizer_path=$symbolizer"
  export UBSAN_OPTIONS="print_stacktrace=1:halt_on_error=1:external_symbolizer_path=$symbolizer"
  ```
  `detect_container_overflow=0` avoids false reports from uninstrumented system libraries. The explicit symbolizer
  avoids a deadlock in `atos`.
- Start runs longer than half an hour with `nohup caffeinate -i ... & disown`, so that neither sleep nor the end of the
  session that started them stops them.
- Do not raise `-rss_limit_mb` to reproduce an out-of-memory input on a shared machine. Swap comes out of the same
  disk, and one 8 GB reproduction took 3 GB of a nearly full Mac disk.

## Corpus and regression

- `tests/fuzz/` holds a minimized corpus archive per target, a dictionary and hand-made seeds.
- Refresh an archive only after a substantial run: merge with `-merge=1` into an empty folder, then pack
  deterministically:
  ```bash
  tar --sort=name --owner=0 --group=0 --numeric-owner --mtime='2000-01-01 00:00Z' -cf - corpus | gzip -9n
  ```
  GNU tar and bsdtar do not produce identical archives, so refresh with GNU tar. Use `xz -9` only where it saves a
  lot: the `tar.exe` that ships with Windows cannot read xz and hangs instead of failing.
- The normal build replays the corpus, the seeds and every past crash input through a plain `main()` that reads files
  and calls `LLVMFuzzerTestOneInput`. It is built without fuzzer instrumentation, with every compiler the project uses,
  and never with clang-cl's sanitizers, which would bring back the exception handling bugs above. Unpack each archive
  into an empty folder, or inputs left from the previous archive are replayed too.
- Commit the input of each fixed crash as a plain file in `tests/fuzz/<target>Crashes/`, outside the archives:
  `-merge=1` drops any input whose features others already cover, fixed crashes included. Mark these files `binary`
  in `.gitattributes`, so line-ending conversion cannot rewrite them.
- Keep a crash file from a Windows clang-cl build only if it also crashes with MSVC or on the Mac.

## Local additions

- **The harness reads its input as UTF-16LE.** `LLVMFuzzerTestOneInput` in `tools/NuXJSREPL.cpp` casts to `Char`,
  which is `UInt16`, and takes `Size / 2` code units. So `tests/fuzz/corpus.tar.gz` and `tests/fuzz/fuzz.dict` are
  UTF-16LE, and a dictionary or corpus tool taken from another project will load without complaint and then match
  nothing. Measured over equal 20000 run campaigns from one seed: no dictionary 4368 features, an ASCII dictionary
  4508, the UTF-16LE one 5110.
- **The dictionary is generated.** `tools/makeFuzzDict.pika` holds the tokens as readable text and writes
  `tests/fuzz/fuzz.dict`, because an entry with `\x00` after every character is not worth maintaining by hand.
- **The seeds are generated too, so there is no seeds folder.** `tools/makeCorpus.pika` extracts the input lines of
  every section of every `tests/**/*.io` file, which is a better seed set than anything hand-made would be.
- **Scripts.** `tools/buildReplFuzz.sh` and `.cmd` build the target, `tools/fuzzNuXJS.sh` and `.cmd` run it. Pass
  `stdlib` to either to reach the standard library: the default harness never calls `setupStandardLibrary()`, so only
  the lexer, parser, compiler and VM are reachable, and `String`, `Array`, `JSON`, `Math`, `Date` and the
  `Number.prototype` conversions are not. That build costs about 18x per input, 88 exec/s against 5 under MSVC,
  because every input recompiles and reruns the library, so it is for targeted runs rather than bulk.
- **The corpus replay lives inside `NuXJSTest` rather than a separate `main()`.** `buildAndTest` unpacks
  `tests/fuzz/corpus.tar.gz` into `output/fuzzReplay`, writes the file list, and passes it as `NuXJSTest`'s argument,
  which replays every input through the harness's own entry conditions. One binary fewer, and the corpus is exercised
  by the program that already runs on every build: about 8 seconds of a 62 second build for 2846 inputs on each
  target. The list comes from the scripts because enumerating a directory is not portable, and a replay that found
  nothing to replay would otherwise pass, so the test fails if it sees fewer than 2000 inputs.
- **Two clang-cl builds pass the differential throw test here.** `-fsanitize=fuzzer,undefined` at 500 exec/s and
  `-fsanitize=fuzzer,address,undefined` with `-fsanitize-address-use-after-return=never` at 800 exec/s, both also
  needing `/Ob0`, the two annotation defines and the release target. Every one of the 2847 corpus inputs executes under
  both, with no crash and no sanitizer report; most of them throw, since the harness rejects malformed source. For this
  engine `/Ob0` alone was not enough: ASan's fake stack was the cause, and every throwing input crashed until the
  use-after-return flag was added.
- **The outcome comparison is done without coverage instrumentation, which is what makes it possible.** A libFuzzer
  binary reports no per-input outcome, so for those two builds the differential is per-input status. To compare the
  answers themselves, the same replay source is built twice with clang-cl, once plain and once with
  `-fsanitize=address,undefined -fsanitize-address-use-after-return=never` and no fuzzer instrumentation, and each input's
  outcome line, `ran` or the exact exception text, is diffed. All 2847 match exactly.
- **Do not add coverage instrumentation to a replay main(), as the shared guide says.** Building the replay source
  with `-fsanitize=fuzzer-no-link` alongside the sanitizers crashes on the FIRST throwing input, while the same
  sanitizers without it return the correct exception and the real libFuzzer builds are unaffected. That isolates
  SanitizerCoverage in a non-libFuzzer main as the cause, which is llvm#212404, and it is why the rule exists.
- **No crash inputs are committed, by decision.** The ten artifacts the campaigns produced all reproduced one site,
  the INT_MIN negation in `Value::toInt`, so a `tests/fuzz/<target>Crashes/` folder would have held ten copies of one
  defect. `tests/conforming/numberLimits.io` pins it as `(-6442450944)|0` instead, which is readable, survives any
  change of corpus format, and runs in the ordinary suite. If a future crash is not reducible to a source line, it
  goes in that folder as the shared guide says.
