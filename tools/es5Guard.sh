#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

branch=main
if [[ ${1-} == "--branch" ]]; then
	branch=$2
	shift 2
fi

remove=false
for arg in "$@"; do
	if [[ $arg == "--remove" ]]; then
		remove=true
		break
	fi
done

if $remove; then
	python3 tools/diffguard.py NUXJS_ES5 --remove src/NuXJS.cpp src/NuXJS.cpp
	python3 tools/diffguard.py NUXJS_ES5 --remove src/NuXJS.h src/NuXJS.h
	exit 0
fi

tmp_cpp=$(mktemp)
tmp_h=$(mktemp)
trap 'rm -f "$tmp_cpp" "$tmp_h"' EXIT

git show "$branch:src/NuXJS.cpp" >"$tmp_cpp"
git show "$branch:src/NuXJS.h" >"$tmp_h"

python3 tools/diffguard.py NUXJS_ES5 "$@" "$tmp_cpp" src/NuXJS.cpp src/NuXJS.cpp
python3 tools/diffguard.py NUXJS_ES5 "$@" "$tmp_h" src/NuXJS.h src/NuXJS.h

