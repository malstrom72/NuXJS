#!/bin/bash

set -e -o pipefail -u
cd "${0%/*}"

target=${1-debug}
model=${2-x64}

cd ./PikaCmd
./BuildPikaCmd.sh
cd ..
if [ "../src/stdlib.js" -nt "../src/stdlibJS.cpp" ]; then
	./PikaCmd/PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../src/stdlibJS.cpp
fi
export CPP_OPTIONS="-std=c++03 -fno-threadsafe-statics -fstrict-aliasing ${CPP_OPTIONS-}"
if [ "$target" == "release" ]; then
	export CPP_OPTIONS="-fno-rtti $CPP_OPTIONS"
fi
mkdir ../output >/dev/null 2>&1 || true
./BuildCpp.sh $target $model ../output/NuXJSTest_${target}_${model} ../tools/NuXJSTest.cpp ../src/NuXJScript.cpp ../src/stdlibJS.cpp
../output/NuXJSTest_${target}_${model} -s >/dev/null 2>&1
../output/NuXJSTest_${target}_${model}
./BuildCpp.sh $target $model ../output/NuXJScript_${target}_${model} ../tools/NuXJSREPL.cpp ../src/NuXJScript.cpp ../src/stdlibJS.cpp
./PikaCmd/PikaCmd ./test.pika -e -x ../output/NuXJScript_${target}_${model} ../tests/
./runExamples.sh "$target"

echo Success!
