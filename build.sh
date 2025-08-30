#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

model=${1:-native}

for target in beta release; do
        bash ./tools/buildAndTest.sh "$target" "$model"
done

if [ -f "output/NuXJS_release_${model}" ]; then
        mv -f "output/NuXJS_release_${model}" "output/NuXJS"
fi
