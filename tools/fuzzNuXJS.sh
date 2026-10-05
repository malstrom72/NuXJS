#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

# Usage: fuzzNuXJS.sh [seconds = 600] [parallel jobs = 8] [stdlib]. Build output/NuXJSFuzz first with buildReplFuzz.sh,
# or output/NuXJSFuzzStdlib with `buildReplFuzz.sh stdlib` and pass stdlib here too.
# The committed corpus is unpacked into output/fuzz/corpus, which is where libFuzzer writes new inputs, so the archive
# in tests/fuzz/ stays untouched. Crashes land in output/fuzz/crashes.
DURATION="${1:-600}"
JOBS="${2:-8}"
WHICH="${3:-}"

binary=output/NuXJSFuzz
if [[ "$WHICH" == "stdlib" ]]; then
	binary=output/NuXJSFuzzStdlib
fi
if [[ ! -x "$binary" ]]; then
	echo "$binary not built; run tools/buildReplFuzz.sh ${WHICH} first"
	exit 1
fi

mkdir -p output/fuzz/corpus output/fuzz/crashes
if [[ -f tests/fuzz/corpus.tar.gz ]]; then
	tar -xzf tests/fuzz/corpus.tar.gz --strip-components=1 -C output/fuzz/corpus
elif [[ -f tests/fuzz/corpus.zip ]]; then
	# bsdtar reads zip, GNU tar does not, so fall back to unzip where tar refuses.
	tar -xf tests/fuzz/corpus.zip --strip-components=1 -C output/fuzz/corpus 2>/dev/null \
			|| { unzip -qo tests/fuzz/corpus.zip -d output/fuzz/unpack && mv output/fuzz/unpack/corpus/* output/fuzz/corpus/ \
			&& rm -rf output/fuzz/unpack; }
fi
if [[ -d tests/fuzz/seeds ]]; then
	cp tests/fuzz/seeds/* output/fuzz/corpus/
fi
# The archives have carried macOS metadata before now, and libFuzzer would feed it to the engine as an input. Only
# hash-named files belong here, so anything that arrived as a directory or a dotfile goes.
find output/fuzz/corpus -mindepth 1 -maxdepth 1 \( -type d -o -name '.*' \) -exec rm -rf {} +

# Run from output/fuzz, because -jobs writes its fuzz-<n>.log files into the working directory.
cd output/fuzz
"../../$binary" corpus -jobs="$JOBS" -workers="$JOBS" -max_total_time="$DURATION" -timeout=10 \
		-rss_limit_mb=4096 -dict=../../tests/fuzz/fuzz.dict -artifact_prefix=crashes/ -print_final_stats=1
