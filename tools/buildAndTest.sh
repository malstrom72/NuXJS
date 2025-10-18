#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

target=${1:-debug}
model=${2:-x64}

# Build PikaCmd tools and update stdlibJS.cpp if needed (once per invocation)
cd ../externals/PikaCmd
if [ ! -e ./PikaCmd ]; then
	bash ./BuildCpp.sh ./PikaCmd -DPLATFORM_STRING=UNIX PikaCmdAmalgam.cpp
fi
bash ./BuildPikaCmd.sh
cd ../../tools
if [ "../src/stdlib.js" -nt "../src/stdlibJS.cpp" ] || \
   [ "../src/stdlibES5.js" -nt "../src/stdlibJS.cpp" ] || \
   [ "./stdlibToCpp.pika" -nt "../src/stdlibJS.cpp" ] || \
   [ "./stdlibMinifier.ppeg" -nt "../src/stdlibJS.cpp" ]; then
	../externals/PikaCmd/PikaCmd ./stdlibToCpp.pika ../src/stdlib.js ../src/stdlibJS.cpp
fi

if [ "${NUXJS_TEST_ES5_VARIANTS-0}" = "1" ]; then
	if [ "$target" = "release" ] && [ "${NUXJS_SKIP_RELEASE-0}" = "1" ]; then
		echo "Skipping release per NUXJS_SKIP_RELEASE=1"
		exit 0
	fi
	for es5 in 0 1; do
		echo "Building and testing with NUXJS_ES5=${es5} ($target $model)"
		bash ./buildAndTestOne.sh "$target" "$model" "$es5"
	done
else
	bash ./buildAndTestOne.sh "$target" "$model"
fi

echo Success!
