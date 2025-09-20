#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

target=${1-debug}
model=${2-x64}

cd ../externals/PikaCmd
if [ ! -e ./PikaCmd ]; then
	bash ./BuildCpp.sh ./PikaCmd -DPLATFORM_STRING=UNIX PikaCmdAmalgam.cpp
fi
bash ./BuildPikaCmd.sh
cd ../../tools
if [ "../src/stdlib.js" -nt "../src/stdlibJS.cpp" ]; then
	../externals/PikaCmd/PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../src/stdlibJS.cpp
fi
if [ "$target" == "release" ]; then
	export CPP_OPTIONS="-fno-rtti ${CPP_OPTIONS-}"
fi
mkdir ../output >/dev/null 2>&1 || true
bash ./BuildCpp.sh $target $model ../output/NuXJSTest_${target}_${model} ../tools/NuXJSTest.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
../output/NuXJSTest_${target}_${model} -s >/dev/null 2>&1
../output/NuXJSTest_${target}_${model}
bash ./BuildCpp.sh $target $model ../output/NuXJS_${target}_${model} ../tools/NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
test_dirs=()
for dir in ../tests/*; do
	if [ -d "$dir" ]; then
		test_dirs+=("$dir")
	fi
done
../externals/PikaCmd/PikaCmd ./test.pika -e -x ../output/NuXJS_${target}_${model} "${test_dirs[@]}"

mkdir -p ../output/examples
exe=../output/examples/examples

echo "Building examples"
bash ./BuildCpp.sh "$target" "$exe" ../examples/examples.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp

echo "Running examples"
"$exe" > ../output/examples/all.log 2>&1

if [ -f ../examples/expected_examples.txt ]; then
	diff -u ../examples/expected_examples.txt ../output/examples/all.log
fi

echo Success!
