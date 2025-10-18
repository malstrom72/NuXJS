#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"
cd ..

target=${1-}

if [ -d "examples" ]; then
	echo "runExamples.sh: executing NuXJS example suite"
	find "examples" -maxdepth 1 -type f -name '*.io' | while IFS= read -r example; do
		echo "- Skipping placeholder for ${example##*/} (no runner defined)"
	done
else
	if [ -n "${target}" ]; then
		echo "runExamples.sh: no examples directory found for target '${target}', skipping"
	else
		echo "runExamples.sh: no examples directory found, skipping"
	fi
fi
