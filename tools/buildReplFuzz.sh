#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

CPP_OPTIONS="${CPP_OPTIONS:-}"
cpp_compiler_was_default=0
if [ -z "${CPP_COMPILER+x}" ]; then
	cpp_compiler_was_default=1
fi
CPP_COMPILER="${CPP_COMPILER:-clang++}"

common_flags=(-std=c++17 -DLIBFUZZ -fsanitize=fuzzer,address)
mac_compile_flags=()
mac_link_flags=()
user_flags=()

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
	fi
	if command -v brew >/dev/null 2>&1; then
		llvm_prefix="$(brew --prefix llvm 2>/dev/null || true)"
		if [[ -n "$llvm_prefix" ]]; then
			if [[ $cpp_compiler_was_default -eq 1 && -x "$llvm_prefix/bin/clang++" ]]; then
				CPP_COMPILER="$llvm_prefix/bin/clang++"
			fi
			mac_link_flags+=(-L"$llvm_prefix/lib/c++" -L"$llvm_prefix/lib/unwind" -L"$llvm_prefix/lib")
			mac_link_flags+=(-Wl,-rpath,"$llvm_prefix/lib/c++" -Wl,-rpath,"$llvm_prefix/lib")
			mac_link_flags+=(-lunwind -lc++ -lc++abi)
		fi
	fi
fi

mkdir -p output

compile_cmd=("$CPP_COMPILER" "${common_flags[@]}" "${mac_compile_flags[@]}" "${user_flags[@]}" \
	tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp -o output/NuXJSFuzz "${mac_link_flags[@]}")

"${compile_cmd[@]}"
