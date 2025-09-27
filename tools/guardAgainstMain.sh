#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

usage() {
	cat <<'EOF'
Usage: guardAgainstMain.sh [OPTIONS] [DIFFGUARD_ARGS...]

Options:
	--branch <branch>	Use <branch> as the baseline instead of "main".
	--macro <macro>		Set the guard macro (default: NUXJS_NOT_MAIN).
	--remove		Remove existing guards from the destination files.
	--help			Show this help message and exit.
EOF
}

branch=main
macro=NUXJS_NOT_MAIN
remove=false
declare -a passthrough=()

run_diffguard() {
        local src=$1
        local dest=$2
        local -a args=("python3" "tools/diffguard.py" "$macro")

        if ((${#passthrough[@]})); then
                args+=("${passthrough[@]}")
        fi

        args+=("$src" "$dest" "$dest")
        "${args[@]}"
}

while [[ $# -gt 0 ]]; do
	case $1 in
		--branch)
			if [[ $# -lt 2 ]]; then
				echo "Missing argument for --branch" >&2
				exit 1
			fi
			branch=$2
			shift 2
			;;
		--macro)
			if [[ $# -lt 2 ]]; then
				echo "Missing argument for --macro" >&2
				exit 1
			fi
			macro=$2
			shift 2
			;;
		--remove)
			remove=true
			shift
			;;
		--help|-h)
			usage
			exit 0
			;;
		--)
			shift
			passthrough+=("$@")
			break
			;;
		*)
			passthrough+=("$1")
			shift
			;;
	esac
done

if $remove; then
	python3 tools/diffguard.py "$macro" --remove src/NuXJS.cpp src/NuXJS.cpp
	python3 tools/diffguard.py "$macro" --remove src/NuXJS.h src/NuXJS.h
	exit 0
fi

tmp_cpp=$(mktemp)
tmp_h=$(mktemp)
trap 'rm -f "$tmp_cpp" "$tmp_h"' EXIT

git show "$branch:src/NuXJS.cpp" >"$tmp_cpp"
git show "$branch:src/NuXJS.h" >"$tmp_h"

run_diffguard "$tmp_cpp" src/NuXJS.cpp
run_diffguard "$tmp_h" src/NuXJS.h

