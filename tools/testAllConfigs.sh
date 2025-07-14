#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"

tmp=$(mktemp /tmp/test.cppXXXX)
echo 'int main() { return 0; }' >"$tmp"

test_model() {
	if bash ./BuildCpp.sh debug "$1" ../output/tmp_"$1" "$tmp" >/dev/null 2>&1; then
		rm -f ../output/tmp_"$1"
		bash ./buildAndTest.sh debug "$1"
		bash ./buildAndTest.sh release "$1"
	else
		echo "Skipping $1 - compiler not available"
	fi
}

test_model x86
test_model x64
test_model arm64

rm -f "$tmp"
echo Success!
