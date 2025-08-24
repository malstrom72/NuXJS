#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..
commit=b947715fdda79a420b253821c1cc52272a77222d
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
curl -L "https://github.com/tc39/test262/archive/${commit}.tar.gz" -o "$tmpdir/test262.tar.gz"
tar -xzf "$tmpdir/test262.tar.gz" -C "$tmpdir"
mv "$tmpdir/test262-${commit}" "$tmpdir/test262-master"
mkdir -p externals
tar -czf externals/test262-master.tar.gz -C "$tmpdir" test262-master
