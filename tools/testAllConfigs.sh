#!/bin/bash

set -e -o pipefail -u
cd "${0%/*}"

# export CPP_COMPILER=g++
./buildAndTest.sh debug x86
./buildAndTest.sh debug x64
./buildAndTest.sh debug arm64
./buildAndTest.sh release x86
./buildAndTest.sh release x64
./buildAndTest.sh release arm64

echo Success!
