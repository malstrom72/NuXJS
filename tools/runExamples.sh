#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")/.."

mkdir -p output/examples
target=${1:-debug}
fail=0
exe=./output/examples/examples

echo "Building examples"
bash ./tools/BuildCpp.sh "$target" "$exe" examples/examples.cpp src/NuXJS.cpp src/stdlibJS.cpp || fail=1

if [ $fail -eq 0 ]; then
	echo "Running examples"
	if "$exe" > output/examples/all.log 2>&1; then
		if [ -f examples/expected_examples.txt ]; then
			if diff -u examples/expected_examples.txt output/examples/all.log; then
				echo "examples ok"
			else
				echo "examples output mismatch"
				fail=1
			fi
		else
			echo "examples ok (no expected output)"
		fi
	else
		echo "examples failed"
		cat output/examples/all.log
		fail=1
	fi
fi

exit $fail
