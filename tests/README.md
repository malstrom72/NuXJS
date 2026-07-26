# Test Suite

This folder contains regression tests written in `.io` format. Each file lists commands and expected output for the NuXJS interpreter. The helper script `tools/test.pika` reads these files, generates a temporary `.js` input file and checks that the interpreter output matches.

## Running the tests

The top-level `build.sh` script builds both configurations and runs all tests by calling `tools/buildAndTest.sh`. That script invokes `tools/test.pika` under `PikaCmd` to execute every `.io` file.

## `tools/test.pika`

`tools/test.pika` is a PikaCmd script that drives the tests. It accepts several command-line options:

- `-e` - validate sections that expect errors (lines starting with `!`). Without this flag such sections are skipped.
- `-k <dir>` - keep the generated input files in the given directory instead of using a temporary directory.
- `-x <exe>` - specify which interpreter executable to run. By default the debug build is used.
- `-h` - display a help message.

The script prints a summary and reports any failing files at the end.

## `.io` file format

Each test file uses simple single-character directives:

- `>` introduces a line of JavaScript to execute.
- `<` gives the expected output for the preceding input.
- `!` marks expected errors (only checked when `-e` is supplied).
- `-` ends a section so multiple input/output pairs can be placed in one file.
- `*` deliberately disables a section (used for not-yet-implemented `// todo` cases).
- `//` starts a comment that is ignored.

**Every line must begin with one of those characters.** A line that does not - a blank line, an indented
directive, a wrapped long line, or an expected-output line missing its `<` - makes the harness *discard the
section it is currently collecting*. That silently removes coverage: the expected output is built from the same
filtered list of sections, so a dropped section can never cause a mismatch and the file still reports success
while testing less than it appears to. Use a `//` comment rather than a blank line to separate groups.

The harness prints `Warning! Skipped N section(s)` when this happens, but it is easy to miss in a long run.
When adding or changing a test, confirm it really runs: break one expectation on purpose and check that the run
turns red. A test that passes proves nothing if its section was never collected in the first place.

Example lines from `tests/conforming/Array1.io`:

```text
> a=[1,2,3,4]
-
> z=0;for( i in a) z+=(1<<i); print(z)
< 15
```

A test with comments from `tests/conforming/dont-reinit-global-var.io`:

```text
// from v8 (0.3.9.5) test suite
> var foo = 'fisk';
> print(foo);
< fisk
```

Example error expectations from `tests/erroneous/badForInStatements.io`:

```text
> for (i = 0 in {}; i < 5; ++i) ;
! !!!! Line: 1
! !!!! SyntaxError: Expected ')'
```

And a runtime error case from `tests/regression/badZeroArgsNewCall.io`:

```text
> function f(){this.b={};new f}f()
! !!!! RangeError: Stack overflow
```
