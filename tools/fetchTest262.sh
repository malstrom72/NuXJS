#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
curl -L "https://github.com/tc39/test262/archive/refs/heads/main.tar.gz" -o "$tmpdir/test262.tar.gz"
tar -xzf "$tmpdir/test262.tar.gz" -C "$tmpdir"
mv "$tmpdir/test262-main" "$tmpdir/test262-master"
mkdir -p externals
tar -czf externals/test262-master.tar.gz -C "$tmpdir" test262-master
