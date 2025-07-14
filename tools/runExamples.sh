#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")/.."

mkdir -p output
target=${1:-debug}
fail=0
for src in examples/*.cpp; do
	name=$(basename "$src" .cpp)
	exe="./output/$name"
	echo "Building $name"
	bash ./tools/BuildCpp.sh "$target" "$exe" "$src" src/NuXJScript.cpp src/stdlibJS.cpp || fail=1
	if [ $fail -eq 0 ]; then
		echo "Running $name"
		if "$exe" > "output/${name}.log" 2>&1; then
			if [ -f "examples/expected_${name}.txt" ]; then
				if diff -u "examples/expected_${name}.txt" "output/${name}.log"; then
					echo "$name ok"
				else
					echo "$name output mismatch"
					fail=1
				fi
			else
				echo "$name ok (no expected output)"
			fi
		else
			echo "$name failed"
			cat "output/${name}.log"
			fail=1
		fi
	fi
done
exit $fail
