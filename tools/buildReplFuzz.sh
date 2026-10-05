#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

CPP_OPTIONS="${CPP_OPTIONS:-}"
cpp_compiler_was_default=0
if [ -z "${CPP_COMPILER+x}" ]; then
	cpp_compiler_was_default=1
fi
CPP_COMPILER="${CPP_COMPILER:-clang++}"

# -O1 rather than no optimization at all: measured 295 exec/s against 1330 over the same corpus. NDEBUG is never
# defined here, so asserts stay live, which is the point of fuzzing an engine that is full of them.
common_flags=(-std=c++17 -O1 -g -DLIBFUZZ -fsanitize=fuzzer,address)
declare -a mac_compile_flags=()
declare -a mac_link_flags=()
declare -a user_flags=()
declare -a fuzz_flags=()
fuzz_output=output/NuXJSFuzz
if [[ "${1:-}" == "stdlib" ]]; then
	fuzz_flags+=(-DLIBFUZZ_STDLIB)	# reaches src/stdlib.js and its bindings, which the default harness cannot
	fuzz_output=output/NuXJSFuzzStdlib
	shift
fi

if [[ -n "$CPP_OPTIONS" ]]; then
	eval "set -- $CPP_OPTIONS"
	user_flags=("$@")
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
	sdk_path=""
	if command -v xcrun >/dev/null 2>&1; then
		sdk_path="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
	fi
	if [[ -n "$sdk_path" ]]; then
		mac_compile_flags+=(-isysroot "$sdk_path" -stdlib=libc++)
		mac_link_flags+=(-isysroot "$sdk_path" -stdlib=libc++)
	fi
	if command -v brew >/dev/null 2>&1; then
		llvm_prefix="$(brew --prefix llvm 2>/dev/null || true)"
		if [[ -n "$llvm_prefix" ]]; then
			if [[ $cpp_compiler_was_default -eq 1 && -x "$llvm_prefix/bin/clang++" ]]; then
				CPP_COMPILER="$llvm_prefix/bin/clang++"
			fi
			mac_link_flags+=(-L "$llvm_prefix/lib/c++" -L "$llvm_prefix/lib/unwind" -L "$llvm_prefix/lib")
			mac_link_flags+=("-Wl,-rpath,$llvm_prefix/lib/c++" "-Wl,-rpath,$llvm_prefix/lib")
			mac_link_flags+=(-lunwind -lc++ -lc++abi)
		fi
	fi
fi

mkdir -p output

compile_cmd=("$CPP_COMPILER")
compile_cmd+=("${common_flags[@]}")
if (( ${#mac_compile_flags[@]} )); then
	compile_cmd+=("${mac_compile_flags[@]}")
fi
if (( ${#user_flags[@]} )); then
	compile_cmd+=("${user_flags[@]}")
fi
if (( ${#fuzz_flags[@]} )); then
	compile_cmd+=("${fuzz_flags[@]}")
fi
compile_cmd+=(tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp -o "$fuzz_output")
if (( ${#mac_link_flags[@]} )); then
	compile_cmd+=("${mac_link_flags[@]}")
fi

"${compile_cmd[@]}"
