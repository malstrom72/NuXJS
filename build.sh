#!/bin/bash
set -e -o pipefail
cd "$(dirname "$0")"

target=${1:-release}
model=${2:-native}

./tools/buildAndTest.sh "$target" "$model"

if [ -f "output/NuXJScript_${target}_${model}" ]; then
	mv -f "output/NuXJScript_${target}_${model}" "output/NuXJScript"
fi
