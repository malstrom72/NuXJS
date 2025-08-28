#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

target=${1-debug}
model=${2-x64}

# Build PikaCmd tools and update stdlibJS.cpp if needed (once per invocation)
cd ../externals/PikaCmd
if [ ! -e ./PikaCmd ]; then
	bash ./BuildCpp.sh ./PikaCmd -DPLATFORM_STRING=UNIX PikaCmdAmalgam.cpp
fi
bash ./BuildPikaCmd.sh
cd ../../tools
# Rebuild stdlibJS.cpp when any relevant source changed (base stdlib, ES5 extras, or the minifier pipeline).
if [ "../src/stdlib.js" -nt "../src/stdlibJS.cpp" ] || \
   [ "../src/stdlibES5.js" -nt "../src/stdlibJS.cpp" ] || \
   [ "./stdlibToCpp.pika" -nt "../src/stdlibJS.cpp" ] || \
   [ "./stdlibMinifier.ppeg" -nt "../src/stdlibJS.cpp" ]; then
	../externals/PikaCmd/PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../src/stdlibJS.cpp
fi

# When NUXJS_TEST_ES5_VARIANTS=1, run tests twice with NUXJS_ES5=0 and 1.
if [ "${NUXJS_TEST_ES5_VARIANTS-0}" = "1" ]; then
	# Optionally skip release target to speed up dev iterations.
	if [ "$target" = "release" ] && [ "${NUXJS_SKIP_RELEASE-0}" = "1" ]; then
		echo "Skipping release per NUXJS_SKIP_RELEASE=1"
		exit 0
	fi

	CPP_OPTIONS_BASE="${CPP_OPTIONS-}"
	mkdir ../output >/dev/null 2>&1 || true
	for es5 in 0 1; do
		echo "Building and testing with NUXJS_ES5=${es5} ($target $model)"
		export CPP_OPTIONS="${CPP_OPTIONS_BASE} -DNUXJS_ES5=${es5}"
		if [ "$target" == "release" ]; then
			export CPP_OPTIONS="-fno-rtti ${CPP_OPTIONS}"
		fi
		bash ./BuildCpp.sh $target $model ../output/NuXJSTest_${target}_${model} ../tools/NuXJSTest.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
		../output/NuXJSTest_${target}_${model} -s >/dev/null 2>&1
		../output/NuXJSTest_${target}_${model}
		bash ./BuildCpp.sh $target $model ../output/NuXJS_${target}_${model} ../tools/NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
		# Select test directories; include ES5 tests only when ES5 is enabled.
		if [ "$es5" = "1" ]; then
			TEST_DIRS=(../tests/conforming ../tests/erroneous ../tests/es3only ../tests/es5 ../tests/extremes ../tests/from262 ../tests/migrated ../tests/regression ../tests/stdlib ../tests/unconforming ../tests/unsorted)
		else
			TEST_DIRS=(../tests/conforming ../tests/erroneous ../tests/es3only ../tests/extremes ../tests/from262 ../tests/migrated ../tests/regression ../tests/stdlib ../tests/unconforming ../tests/unsorted)
		fi
		../externals/PikaCmd/PikaCmd ./test.pika -e -x ../output/NuXJS_${target}_${model} "${TEST_DIRS[@]}"
		bash ./runExamples.sh "$target"
		echo "Done NUXJS_ES5=${es5} ($target $model)"
	done
	echo Success!
	exit 0
fi

# Default single-pass build and test
if [ "$target" == "release" ]; then
	export CPP_OPTIONS="-fno-rtti ${CPP_OPTIONS-}"
fi
mkdir ../output >/dev/null 2>&1 || true
bash ./BuildCpp.sh $target $model ../output/NuXJSTest_${target}_${model} ../tools/NuXJSTest.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
../output/NuXJSTest_${target}_${model} -s >/dev/null 2>&1
../output/NuXJSTest_${target}_${model}
bash ./BuildCpp.sh $target $model ../output/NuXJS_${target}_${model} ../tools/NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
../externals/PikaCmd/PikaCmd ./test.pika -e -x ../output/NuXJS_${target}_${model} ../tests/
bash ./runExamples.sh "$target"

echo Success!
