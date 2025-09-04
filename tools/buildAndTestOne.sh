#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

target=${1:-debug}
model=${2:-x64}
es5=${3-}

if [[ "$target" == "release" ]]; then
	CPP_OPTIONS="-fno-rtti ${CPP_OPTIONS-}"
fi
if [[ -n "$es5" ]]; then
	CPP_OPTIONS="${CPP_OPTIONS-} -DNUXJS_ES5=${es5}"
fi

export CPP_OPTIONS

mkdir ../output >/dev/null 2>&1 || true
bash ./BuildCpp.sh "$target" "$model" ../output/NuXJSTest_${target}_${model} ./NuXJSTest.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
../output/NuXJSTest_${target}_${model} -s >/dev/null 2>&1
../output/NuXJSTest_${target}_${model}
bash ./BuildCpp.sh "$target" "$model" ../output/NuXJS_${target}_${model} ./NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp

if [[ -n "$es5" ]]; then
	ES5_ENABLED="$es5"
else
	if echo " ${CPP_OPTIONS-} " | grep -q -- "-DNUXJS_ES5=0"; then
		ES5_ENABLED=0
	else
		ES5_ENABLED=1
	fi
fi

TEST_DIRS=(../tests/conforming/ ../tests/erroneous/ ../tests/es3only/)
if [[ "$ES5_ENABLED" == "0" ]]; then
	TEST_DIRS+=(../tests/es3/)
fi
if [[ "$ES5_ENABLED" == "1" ]]; then
	TEST_DIRS+=(../tests/es5/)
fi
TEST_DIRS+=(../tests/extremes/)
if [[ "$ES5_ENABLED" == "1" ]]; then
	TEST_DIRS+=(../tests/from262/)
fi
TEST_DIRS+=(../tests/migrated/ ../tests/regression/ ../tests/stdlib/ ../tests/unconforming/ ../tests/unsorted/)

../externals/PikaCmd/PikaCmd ./test.pika -e -x ../output/NuXJS_${target}_${model} "${TEST_DIRS[@]}"
bash ./runExamples.sh "$target"

if [[ -n "$es5" ]]; then
	echo "Done NUXJS_ES5=${es5} (${target} ${model})"
fi
