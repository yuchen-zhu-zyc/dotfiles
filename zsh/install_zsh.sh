#!/usr/bin/env bash
#
# Install zsh into $PREFIX (default $HOME/.local) without requiring root.
#
# Strategy (first match wins):
#   1. zsh already in PATH or at $PREFIX/bin/zsh         → no-op.
#   2. macOS                                             → hint: use brew.
#   3. apt-get + passwordless sudo                       → sudo apt install zsh.
#   4. dnf / yum + passwordless sudo                     → corresponding install.
#   5. Source build from github.com/romkatv/zsh-bin      → vendored zsh-5.8 +
#      ncurses-6.2 tarballs; no GitHub-release-CDN dependency.
#
# Source build needs: gcc, make, git, tar.
# Builds ncurses 6.2 only when no system curses headers are available.
#
# Override the install location:
#     PREFIX=$HOME/opt/zsh bash zsh/install_zsh.sh
#
# Re-running this script is safe (idempotent): it skips work that's done.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
ZSH_BIN_REPO="${ZSH_BIN_REPO:-https://github.com/romkatv/zsh-bin.git}"

# ----- 1. Already installed? -----
if existing="$(command -v zsh 2>/dev/null)"; then
    echo "✅ zsh already in PATH: $existing"
    "$existing" --version
    exit 0
fi

if [ -x "$PREFIX/bin/zsh" ]; then
    echo "✅ zsh already at $PREFIX/bin/zsh"
    "$PREFIX/bin/zsh" --version
    exit 0
fi

# ----- 2. macOS -----
if [ "$(uname)" = "Darwin" ]; then
    cat >&2 <<'EOF'
ℹ️  macOS detected. zsh ships with macOS by default. To upgrade:
      brew install zsh
EOF
    exit 0
fi

# ----- 3-4. Package manager (only if passwordless sudo) -----
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "🔧 Installing zsh via apt..."
        sudo apt-get update || true
        sudo apt-get install -y zsh
        exit 0
    fi
    if command -v dnf >/dev/null 2>&1; then
        echo "🔧 Installing zsh via dnf..."
        sudo dnf install -y zsh
        exit 0
    fi
    if command -v yum >/dev/null 2>&1; then
        echo "🔧 Installing zsh via yum..."
        sudo yum install -y zsh
        exit 0
    fi
fi

# ----- 5. Source build -----
echo "🔨 No root / no apt; building zsh from source into $PREFIX"

for cmd in gcc make git tar; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "❌ Required build tool missing: $cmd" >&2
        echo "   Install build essentials and retry." >&2
        exit 1
    }
done

work="$(mktemp -d -t zsh-build.XXXXXX)"
trap 'rm -rf "$work"' EXIT
cd "$work"

echo "⬇️  Cloning bundled sources (zsh-5.8 + ncurses-6.2) from $ZSH_BIN_REPO ..."
git clone --depth=1 "$ZSH_BIN_REPO" zsh-bin
src="$work/zsh-bin/src"

# Build our own ncurses if no system headers are available.
need_ncurses=0
if [ ! -e /usr/include/ncurses.h ] \
   && [ ! -e /usr/include/ncursesw/ncurses.h ] \
   && [ ! -e "$PREFIX/include/ncursesw/ncurses.h" ]; then
    need_ncurses=1
fi

if [ "$need_ncurses" = "1" ]; then
    echo "🔨 Building ncurses 6.2 (system headers not found)..."
    tar --no-same-owner -xzf "$src/ncurses-6.2.tar.gz"
    (
        cd ncurses-6.2
        ./configure --prefix="$PREFIX" \
            --without-debug --without-ada --without-tests --without-manpages \
            --enable-pc-files \
            --with-pkg-config-libdir="$PREFIX/lib/pkgconfig" \
            --enable-widec --with-shared --with-termlib --with-cxx-shared
        make -j"$(nproc)"
        make install
    )
    export CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncursesw"
    export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
    export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
    extra_cfg=(--with-term-lib="ncursesw tinfow")
else
    echo "✅ Using system ncurses headers"
    extra_cfg=()
fi

echo "🔨 Building zsh 5.8..."
tar --no-same-owner -xzf "$src/zsh-5.8.tar.gz"
(
    cd zsh-zsh-5.8
    ./Util/preconfig
    ./configure --prefix="$PREFIX" \
        --enable-cap --enable-pcre --enable-multibyte \
        --with-tcsetpgrp \
        --enable-function-subdirs \
        --enable-fndir="$PREFIX/share/zsh/functions" \
        --enable-scriptdir="$PREFIX/share/zsh/scripts" \
        --enable-site-fndir="$PREFIX/share/zsh/site-functions" \
        --enable-site-scriptdir="$PREFIX/share/zsh/site-scripts" \
        "${extra_cfg[@]}"
    make -j"$(nproc)"
    # Skip install.man — would need yodl, which we don't bundle.
    make install.bin install.modules install.fns
)

echo
echo "✅ Built zsh: $PREFIX/bin/zsh"
"$PREFIX/bin/zsh" --version
echo
echo "ℹ️  Make sure $PREFIX/bin is in your PATH. Running zsh/activate_zsh.sh"
echo "    next will append the necessary block to ~/.bashrc."
