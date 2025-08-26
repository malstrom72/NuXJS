#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")/.."

mkdir -p output/examples
target=${1:-debug}
exe=./output/examples/examples

echo "Building examples"
bash ./tools/BuildCpp.sh "$target" "$exe" examples/examples.cpp src/NuXJS.cpp src/stdlibJS.cpp

echo "Running examples"
"$exe" > output/examples/all.log 2>&1

[ -f examples/expected_examples.txt ] && diff -u examples/expected_examples.txt output/examples/all.log
