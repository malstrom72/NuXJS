#!/bin/bash
set -e -o pipefail
cd "$(dirname "$0")"

model=${1:-native}

for target in beta release; do
	./tools/buildAndTest.sh "$target" "$model"
done

if [ -f "output/NuXJScript_release_${model}" ]; then
	mv -f "output/NuXJScript_release_${model}" "output/NuXJScript"
fi
