#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

variant=${1:-both}
model=${2:-native}
build_target=${3:-both}

case "$variant" in
	es3|ES3)
		export CPP_OPTIONS="${CPP_OPTIONS-} -DNUXJS_ES5=0"
		;;
	es5|ES5)
		export CPP_OPTIONS="${CPP_OPTIONS-} -DNUXJS_ES5=1"
		;;
	both|BOTH)
		export NUXJS_TEST_ES5_VARIANTS=1
		;;
	*)
		model="$variant"
		variant=both
		;;
esac

case "$build_target" in
	beta|release)
		targets="$build_target"
		;;
	both|BOTH)
		targets="beta release"
		;;
	*)
		targets="beta release"
		;;
esac

for target in $targets; do
	bash ./tools/buildAndTest.sh "$target" "$model"
done

if [ -f "output/NuXJS_release_${model}" ]; then
	mv -f "output/NuXJS_release_${model}" "output/NuXJS"
fi
echo "=== ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ==="
