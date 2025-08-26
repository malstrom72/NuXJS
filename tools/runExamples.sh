#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")/.."

mkdir -p output/examples
target=${1:-debug}
fail=0
exe=./output/examples/examples
examples=(
        asynchronous_example
        callback_example
        custom_object_example
        error_handling_example
        json_conversion_example
        object_creation_example
        property_enumeration_example
        time_memory_limits_example
)

echo "Building examples"
bash ./tools/BuildCpp.sh "$target" "$exe" examples/examples.cpp src/NuXJS.cpp src/stdlibJS.cpp || fail=1

if [ $fail -eq 0 ]; then
        echo "Running examples"
        if "$exe" > "output/examples/all.log" 2>&1; then
                for name in "${examples[@]}"; do
                        awk "/^=== ${name} ===/{flag=1;next}/^===/{flag=0}flag" "output/examples/all.log" > "output/examples/${name}.log"
                        if [ -f "examples/expected_${name}.txt" ]; then
                                if diff -u "examples/expected_${name}.txt" "output/examples/${name}.log"; then
                                        echo "${name} ok"
                                else
                                        echo "${name} output mismatch"
                                        fail=1
                                fi
                        else
                                echo "${name} ok (no expected output)"
                        fi
                done
        else
                echo "examples failed"
                cat "output/examples/all.log"
                fail=1
        fi
fi

exit $fail
