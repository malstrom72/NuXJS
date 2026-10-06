# Fuzz corpus

`corpus.tar.gz` holds the seed corpus for the REPL fuzz harness (`tools/NuXJSREPL.cpp` built with `-DLIBFUZZ`).
`tools/fuzzNuXJS.sh` and `tools/fuzzNuXJS.cmd` unpack it into `output/fuzz/corpus`. Inputs are UTF-16LE: the harness
reads `Data` as `Char*` with `Size / 2` code units.

## Provenance

Built on 2026-10-05 from NuXJS `main` 58b9478 on an Apple M4 with Homebrew clang 22.1.8, using the repo's
`tools/buildReplFuzz.sh` harness unmodified and asserts live (the script does not define `NDEBUG`).

| Campaign | Build | Executions | Artifacts |
|---|---|---|---|
| A | `-O1 -g`, ASan | 98,487,619 | none |
| B | `-O1 -g`, ASan + UBSan | 52,807,340 | 10, all one site: signed negation in `Value::toInt`, fixed in c1c2c00 |

Each campaign ran for about 6 hours with `-fork=5`.

The corpus is `-merge=1` with the campaign A binary over three inputs: the previous committed seeds (2,658 files),
campaign A's corpus and campaign B's corpus, 9,466 files in all. The result is 2,847 files, 11.8 MB uncompressed.

Coverage when replayed with `-runs=0`:

| | A build | B build |
|---|---|---|
| previous seeds | cov 2151, ft 10558 | cov 3152, ft 17538 |
| this corpus | cov 2299, ft 12305 | cov 3229, ft 18697 |

## Archive format

The archive contains `corpus/<sha1>` with names sorted, uid and gid 0, every mtime 2000-01-01, and gzip `-9` without a
timestamp. It was packed with Python's `tarfile` in GNU format, so it is deterministic but not byte-identical to GNU
tar's output. Its sha256 is `3d949b7e3e15019635a0f327e86f9f8ffd4f81a056c1619f89f9a80ee4d53c43`.
