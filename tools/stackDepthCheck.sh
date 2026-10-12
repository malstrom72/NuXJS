#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

# The compile-depth tests, built with the flags products ship and run on a 512 KB stack, the size of a secondary
# thread on macOS and iOS, so the default compile limit is shown to fit where the stack is tightest.
cd ../externals/PikaCmd
if [ ! -e ./PikaCmd ]; then
	bash ./BuildCpp.sh ./PikaCmd -DPLATFORM_STRING=UNIX PikaCmdAmalgam.cpp
fi
cd ../../tools
mkdir ../output >/dev/null 2>&1 || true
CPP_OPTIONS="-O3 -flto -fno-rtti" bash ./BuildCpp.sh release native ../output/NuXJS_depth ../tools/NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
ulimit -s 512
../externals/PikaCmd/PikaCmd ./test.pika -e -x "../output/NuXJS_depth -s --legacy-exceptions" ../tests/extremes/compileDepth.io
