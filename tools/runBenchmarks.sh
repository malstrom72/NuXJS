#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

WORKDIR="output/benchmarks_engines"
mkdir -p "$WORKDIR"

# Build NuXJS if needed
if [ ! -x "output/NuXJS" ]; then
	echo "Building NuXJS..."
	bash tools/BuildCpp.sh release x64 ./output/NuXJS \
	tools/NuXJSREPL.cpp src/NuXJS.cpp src/stdlibJS.cpp >/dev/null
fi

# Duktape
if [ ! -x "$WORKDIR/duktape/duk" ]; then
	echo "Installing Duktape..."
	curl -L https://github.com/svaarala/duktape/releases/download/v2.7.0/duktape-2.7.0.tar.xz \
	| tar -C "$WORKDIR" -xJ
	mv "$WORKDIR/duktape-2.7.0" "$WORKDIR/duktape"
	gcc -std=c99 -O2 -DDUK_CMDLINE_PRINTALERT_SUPPORT -I"$WORKDIR/duktape/src" -I"$WORKDIR/duktape/extras/print-alert" -o "$WORKDIR/duktape/duk" \
	"$WORKDIR/duktape/examples/cmdline/duk_cmdline.c" \
	"$WORKDIR/duktape/extras/print-alert/duk_print_alert.c" \
	"$WORKDIR/duktape/src/duktape.c" -lm >/dev/null
fi
DUK="$WORKDIR/duktape/duk"

# QuickJS
if [ ! -x "$WORKDIR/quickjs/qjs" ]; then
	echo "Installing QuickJS..."
	git clone --depth 1 https://github.com/bellard/quickjs.git "$WORKDIR/quickjs"
	make -C "$WORKDIR/quickjs" -j"$(nproc)" >/dev/null
fi
QJS="$WORKDIR/quickjs/qjs"

# JerryScript
if [ ! -x "$WORKDIR/jerryscript/build/bin/jerry" ]; then
	echo "Installing JerryScript..."
	git clone --depth 1 https://github.com/jerryscript-project/jerryscript.git "$WORKDIR/jerryscript"
	pushd "$WORKDIR/jerryscript" >/dev/null
	python tools/build.py --clean --install=local >/dev/null
	popd >/dev/null
fi
JERRY="$WORKDIR/jerryscript/build/bin/jerry"

engines=("NuXJS:./output/NuXJS" "Duktape:$DUK" "QuickJS:$QJS" "JerryScript:$JERRY")

for pair in "${engines[@]}"; do
	IFS=':' read -r name exe <<< "$pair"
	echo "## $name"
	if [ $# -gt 0 ]; then
		files="$@"
	else
		files=benchmarks/*.js
	fi
	for bm in $files; do
		start=$(date +%s%N)
		if out="$("$exe" "$bm" 2>&1)"; then
			end=$(date +%s%N)
			result=$(( (end - start) / 1000000 ))
			base=$(basename "$bm" .js)
			golden="benchmarks/golden/$base.txt"
			out_norm=$(printf '%s' "$out" | tr -d '\r')
			if [ -f "$golden" ]; then
				golden_norm=$(tr -d '\r' < "$golden")
				if [ "$out_norm" = "$golden_norm" ]; then
					printf "%-25s %s\n" "$(basename "$bm")" "$result"
				else
					printf "%-25s WRONG\n" "$(basename "$bm")"
					diff -u <(printf '%s' "$golden_norm") <(printf '%s' "$out_norm") | head -n 20 || true
				fi
			else
				printf "%-25s %s\n" "$(basename "$bm")" "$result"
				echo "    (no golden file)"
			fi
		else
			status=$?
			end=$(date +%s%N)
			printf "%-25s ERR(%d)\n" "$(basename "$bm")" "$status"
			echo "$out" | sed 's/^/    /' | head -n 20
		fi
	done
	echo
done
