# Test Suite

This folder contains regression tests written in `.io` format. Each file lists commands and expected output for the NuXJS interpreter. The helper script `tools/test.pika` reads these files, generates a temporary `.js` input file and checks that the interpreter output matches.

## Running the tests

The top-level `build.sh` script builds both configurations and runs all tests by calling `tools/buildAndTest.sh`. That script invokes `tools/test.pika` under `PikaCmd` to execute every `.io` file.

## `tools/test.pika`

`tools/test.pika` is a PikaCmd script that drives the tests. It accepts several command-line options:

- `-e` – validate sections that expect errors (lines starting with `!`). Without this flag such sections are skipped.
- `-k <dir>` – keep the generated input files in the given directory instead of using a temporary directory.
- `-x <exe>` – specify which interpreter executable to run. By default the debug build is used.
- `-h` – display a help message.

The script prints a summary and reports any failing files at the end.

## `.io` file format

Each test file uses simple single-character directives:

- `>` introduces a line of JavaScript to execute.
- `<` gives the expected output for the preceding input.
- `!` marks expected errors (only checked when `-e` is supplied).
- `-` ends a section so multiple input/output pairs can be placed in one file.
- `//` starts a comment that is ignored.

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
