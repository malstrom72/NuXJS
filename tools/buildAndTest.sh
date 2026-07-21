#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

target=${1-debug}
model=${2-x64}
variant=${3-es3}

# The es5 variant compiles the ECMAScript 5.1 extensions (guarded by NUXJS_ES5) and gets an "_es5" binary
# suffix. The es3 variant is the pristine ES3 engine, built exactly as before.
suffix=""
if [ "$variant" == "es5" ]; then
	suffix="_es5"
fi

cd ../externals/PikaCmd
if [ ! -e ./PikaCmd ]; then
	bash ./BuildCpp.sh ./PikaCmd -DPLATFORM_STRING=UNIX PikaCmdAmalgam.cpp
fi
bash ./BuildPikaCmd.sh
cd ../../tools
if [ "../src/stdlib.js" -nt "../src/stdlibJS.cpp" ] || [ "../src/stdlibES5.js" -nt "../src/stdlibJS.cpp" ] \
		|| [ "./stdlibToCpp.pika" -nt "../src/stdlibJS.cpp" ] || [ "./stdlibMinifier.ppeg" -nt "../src/stdlibJS.cpp" ]; then
	../externals/PikaCmd/PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../src/stdlibJS.cpp
fi
opts=""
if [ "$variant" == "es5" ]; then
	opts="-DNUXJS_ES5=1"
fi
if [ "$target" == "release" ]; then
	opts="-fno-rtti $opts"
fi
export CPP_OPTIONS="$opts"	# always reset so a CPP_OPTIONS inherited from the environment cannot leak into a build
mkdir ../output >/dev/null 2>&1 || true
bash ./BuildCpp.sh $target $model ../output/NuXJSTest${suffix}_${target}_${model} ../tools/NuXJSTest.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp
../output/NuXJSTest${suffix}_${target}_${model} -s >/dev/null 2>&1
../output/NuXJSTest${suffix}_${target}_${model}
bash ./BuildCpp.sh $target $model ../output/NuXJS${suffix}_${target}_${model} ../tools/NuXJSREPL.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp

# Select test directories for the variant: tests/es5 runs only under es5, tests/es3only only under es3.
testDirs=""
for d in ../tests/*/; do
	name=$(basename "$d")
	if [ "$name" == "es5" ] && [ "$variant" != "es5" ]; then
		continue
	fi
	if [ "$name" == "es3only" ] && [ "$variant" == "es5" ]; then
		continue
	fi
	testDirs="$testDirs $d"
done
../externals/PikaCmd/PikaCmd ./test.pika -e -x "../output/NuXJS${suffix}_${target}_${model} -s --legacy-exceptions" $testDirs

mkdir -p ../output/examples
exe=../output/examples/examples

echo "Building examples"
bash ./BuildCpp.sh "$target" "$exe" ../docs/examples/examples.cpp ../src/NuXJS.cpp ../src/stdlibJS.cpp

echo "Running examples"
"$exe" > ../output/examples/all.log 2>&1

if [ -f ../docs/examples/expected_examples.txt ]; then
	diff -u ../docs/examples/expected_examples.txt ../output/examples/all.log
fi

echo Success!
