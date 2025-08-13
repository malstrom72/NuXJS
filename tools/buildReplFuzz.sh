#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

CPP_COMPILER="${CPP_COMPILER:-clang++}"
mkdir -p output
"$CPP_COMPILER" -std=c++17 -DLIBFUZZ -fsanitize=fuzzer,address \
  tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp \
  -o output/NuXJSFuzz
