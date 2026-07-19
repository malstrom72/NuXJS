#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

# Usage: ./build.sh [es3|es5|both] [model] [beta|release]
# Arguments are recognized by value and may appear in any order. Defaults: both, native, beta+release.
variant=both
model=native
targets="beta release"

for arg in "$@"; do
	case "$arg" in
		es3|es5|both) variant="$arg" ;;
		beta|release) targets="$arg" ;;
		*) model="$arg" ;;
	esac
done

variants="$variant"
if [ "$variant" == "both" ]; then
	variants="es3 es5"
fi

for v in $variants; do
	for target in $targets; do
		bash ./tools/buildAndTest.sh "$target" "$model" "$v"
	done
done

if [ -f "output/NuXJS_release_${model}" ]; then
	mv -f "output/NuXJS_release_${model}" "output/NuXJS"
fi
if [ -f "output/NuXJS_es5_release_${model}" ]; then
	mv -f "output/NuXJS_es5_release_${model}" "output/NuXJS_ES5"
fi
echo "=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ==="
