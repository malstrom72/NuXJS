#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

python_cmd="${PYTHON:-}"
if [[ -z "$python_cmd" ]]; then
	if command -v python3 >/dev/null 2>&1; then
		python_cmd=python3
	elif command -v python >/dev/null 2>&1; then
		python_cmd=python
	else
		echo "Unable to locate python interpreter." >&2
		exit 1
	fi
fi

"$python_cmd" tools/makeCorpus.py "$@"
