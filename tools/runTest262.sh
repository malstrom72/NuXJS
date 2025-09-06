#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..
node tools/testdash.node.js --cli "$@"
