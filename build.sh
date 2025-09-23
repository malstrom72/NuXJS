#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

model=${1:-native}

run_suite() {
	local label="$1"
	local extra_cpp="$2"
	echo "=== Running ${label} build matrix ==="
	(
		set -e -o pipefail -u
		base_cpp="${CPP_OPTIONS-}"
		if [ -n "$extra_cpp" ]; then
			if [ -n "$base_cpp" ]; then
				export CPP_OPTIONS="$base_cpp $extra_cpp"
			else
				export CPP_OPTIONS="$extra_cpp"
			fi
		elif [ -n "$base_cpp" ]; then
			export CPP_OPTIONS="$base_cpp"
		else
			unset CPP_OPTIONS || true
		fi
		for target in beta release; do
			bash ./tools/buildAndTest.sh "$target" "$model"
		done
	)
}

run_suite "NaN-boxed" "-DNUXJS_USE_NAN_BOXING"
run_suite "legacy" ""

if [ -f "output/NuXJS_release_${model}" ]; then
	mv -f "output/NuXJS_release_${model}" "output/NuXJS"
fi
echo "=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ==="
