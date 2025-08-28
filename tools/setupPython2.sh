#!/usr/bin/env bash
set -e -o pipefail -u

# Run from this script's folder so relative paths behave consistently
cd "$(dirname "$0")"

# Install dirs and names
PREFIX="$HOME/miniforge"
BINDIR="$HOME/.local/bin"
ENVNAME="py27"
PY2SHIM="$BINDIR/python2"

mkdir -p "$BINDIR"

arch="$(uname -m)"
kernel="$(uname -s)"

# Select Miniforge installer per OS/arch
case "$kernel" in
	Linux)
		case "$arch" in
			x86_64)   miniforge_file="Miniforge3-Linux-x86_64.sh" ;;
			aarch64)  miniforge_file="Miniforge3-Linux-aarch64.sh" ;;
			*) echo "Unsupported Linux architecture: $arch"; exit 1 ;;
		esac
		;;
	Darwin)
		case "$arch" in
			x86_64) miniforge_file="Miniforge3-MacOSX-x86_64.sh" ;;
			arm64)  miniforge_file="Miniforge3-MacOSX-arm64.sh" ;;
			*) echo "Unsupported macOS architecture: $arch"; exit 1 ;;
		esac
		;;
	*)
		echo "Unsupported OS: $kernel"; exit 1 ;;
esac

# 1) Install Miniforge if missing (non-interactive)
if [ ! -x "$PREFIX/bin/conda" ]; then
	tmp="$(mktemp -d)"
	curl -fsSL "https://github.com/conda-forge/miniforge/releases/latest/download/${miniforge_file}" -o "$tmp/miniforge.sh"
	bash "$tmp/miniforge.sh" -b -p "$PREFIX"
	rm -rf "$tmp"
fi

# 2) Load conda for this shell (no init needed)
. "$PREFIX/etc/profile.d/conda.sh"

# Helper: create a shim that directly execs the env's python
make_shim_to_env() {
	local env_python="$PREFIX/envs/$ENVNAME/bin/python"
	cat > "$PY2SHIM" <<EOF
#!/usr/bin/env bash
exec "$env_python" "\$@"
EOF
	chmod +x "$PY2SHIM"
}

# 3) Provision Python 2.7 depending on platform
if [ "$kernel" = "Linux" ]; then
	if [ "$arch" = "x86_64" ]; then
		# CPython 2.7 from conda-forge archival label
		if [ ! -d "$PREFIX/envs/$ENVNAME" ]; then
			conda create -y -n "$ENVNAME" \
				-c conda-forge/label/cf202003 -c conda-forge \
				"python=2.7" "pip<21" "setuptools<45" "wheel<1.0"
		fi
		make_shim_to_env
	else
		# Linux aarch64: CPython 2.7 unavailable → use PyPy2.7
		PYPY_VER="7.3.9"
		tarname="pypy2.7-v${PYPY_VER}-aarch64.tar.bz2"
		dest="$HOME/.opt/pypy2.7-v${PYPY_VER}"
		if [ ! -x "$dest/bin/pypy" ]; then
			mkdir -p "$HOME/.opt"
			tmp="$(mktemp -d)"
			curl -fsSL "https://downloads.python.org/pypy/${tarname}" -o "$tmp/$tarname"
			tar -xjf "$tmp/$tarname" -C "$HOME/.opt"
			rm -rf "$tmp"
			"$dest/bin/pypy" -m ensurepip --upgrade || true
			"$dest/bin/pypy" -m pip install -U 'pip<21' 'setuptools<45' 'wheel<1.0'
		fi
		cat > "$PY2SHIM" <<EOF
#!/usr/bin/env bash
exec "$dest/bin/pypy" "\$@"
EOF
		chmod +x "$PY2SHIM"
	fi
else
	# macOS
	if [ "$arch" = "x86_64" ]; then
		# Native macOS x86_64: CPython 2.7 via conda-forge archival label
		if [ ! -d "$PREFIX/envs/$ENVNAME" ]; then
			conda create -y -n "$ENVNAME" \
				-c conda-forge/label/cf202003 -c conda-forge \
				"python=2.7" "pip<21" "setuptools<45" "wheel<1.0"
		fi
		make_shim_to_env
	else
		# Apple Silicon: create an x86_64 (osx-64) env and run under Rosetta 2
		if [ ! -d "$PREFIX/envs/$ENVNAME" ]; then
			CONDA_SUBDIR=osx-64 conda create -y -n "$ENVNAME" \
				-c conda-forge/label/cf202003 -c conda-forge \
				"python=2.7" "pip<21" "setuptools<45" "wheel<1.0"
			# Persist the subdir setting so future solves use osx-64
			conda run -n "$ENVNAME" conda config --env --set subdir osx-64 || true
		fi
		make_shim_to_env
	fi
fi

# 4) Ensure ~/.local/bin is on PATH for future shells; also export for current
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
	if [ -e "$rc" ]; then
		if ! grep -qs 'HOME/.local/bin' "$rc" 2>/dev/null; then
			printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
		fi
	else
		printf 'export PATH="$HOME/.local/bin:$PATH"\n' > "$rc"
	fi
done
export PATH="$HOME/.local/bin:$PATH"

# 5) Smoke test (non-fatal)
set +e
python2 -V || "$PY2SHIM" -V || true

