#!/usr/bin/env bash
set -e -o pipefail -u
cd "$(dirname "$0")"/..

WORKDIR="output/benchmarks_engines"
mkdir -p "$WORKDIR"
# Determine number of CPU cores for parallel builds
if command -v nproc >/dev/null 2>&1; then
	CPUS=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
	CPUS=$(sysctl -n hw.ncpu)
else
	CPUS=1
fi

# Select Python interpreter for timestamping
if command -v python3 >/dev/null 2>&1; then
	PYTHON=python3
else
	PYTHON=python
fi

now_ms() {
	"$PYTHON" - <<'PY'
import time, sys; sys.stdout.write(str(int(time.time()*1000)))
PY
}

strip_cr() {
	LC_ALL=C tr -d '\r'
}

safe_sed() {
	LC_ALL=C sed "$@"
}

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
	make -C "$WORKDIR/quickjs" -j"$CPUS" >/dev/null
fi
QJS="$WORKDIR/quickjs/qjs"

# JerryScript
if [ ! -x "$WORKDIR/jerryscript/build/bin/jerry" ]; then
	echo "Installing JerryScript..."
	if command -v cmake >/dev/null 2>&1; then
	        git clone --depth 1 https://github.com/jerryscript-project/jerryscript.git "$WORKDIR/jerryscript"
	        pushd "$WORKDIR/jerryscript" >/dev/null
	        # Ensure bundled tools use Python 3 even when `python` is Python 2
	        while IFS= read -r -d '' file; do
	                read -r first < "$file"
	                if [ "$first" = "#!/usr/bin/env python" ]; then
	                        {
	                                echo "#!/usr/bin/env python3"
	                                tail -n +2 "$file"
	                        } > "$file.tmp"
	                        mv "$file.tmp" "$file"
	                fi
	        done < <(find tools -name '*.py' -print0)
	        "$PYTHON" tools/build.py --clean --install=local >/dev/null
	        popd >/dev/null
	else
	        echo "cmake not found; skipping JerryScript build" >&2
	fi
fi


engines=("NuXJS:./output/NuXJS" "Duktape:$DUK" "QuickJS:$QJS")
if [ -x "$WORKDIR/jerryscript/build/bin/jerry" ]; then
	engines+=("JerryScript:$WORKDIR/jerryscript/build/bin/jerry")
fi

for pair in "${engines[@]}"; do
	IFS=':' read -r name exe <<< "$pair"
	echo "## $name"
	if [ $# -gt 0 ]; then
		files="$@"
	else
		files=benchmarks/*.js
	fi
       for bm in $files; do
               start=$(now_ms)
               cmd=("$exe" "$bm")
               if out="$("${cmd[@]}" 2>&1)"; then
                       end=$(now_ms)
                       result=$(( end - start ))
                       base=$(basename "$bm" .js)
                       golden="benchmarks/golden/$base.txt"
                       out_norm=$(printf '%s' "$out" | strip_cr | safe_sed '/^[[:space:]]*=undefined$/d')
                       if [ "$name" = "NuXJS" ]; then
                               mkdir -p benchmarks/golden
                               printf '%s' "$out_norm" > "$golden"
                               printf "%-25s %s\n" "$(basename "$bm")" "$result"
                       else
                               if [ -f "$golden" ]; then
                                       golden_norm=$(strip_cr < "$golden")
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
                       fi
               else
                       status=$?
                       end=$(now_ms)
                       printf "%-25s ERR(%d)\n" "$(basename "$bm")" "$status"
                       echo "$out" | safe_sed 's/^/    /' | head -n 20
               fi
       done
       echo
done
