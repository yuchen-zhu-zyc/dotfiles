#!/bin/sh
#
# Make zsh the interactive login shell.
#
# Logic:
#   1. If $SHELL already points at zsh, exit success.
#   2. Locate a zsh binary. Prefer $PATH; fall back to $HOME/.local/bin/zsh.
#      If neither is present, print install hints and exit non-zero.
#   3. Try `chsh` (uses sudo non-interactively if necessary). If chsh works,
#      we are done.
#   4. Otherwise, install an idempotent auto-launch block into ~/.bashrc that
#      exec's into the located zsh for interactive bash sessions. This is
#      the no-root path: chsh requires updating /etc/passwd which is
#      privileged, but ~/.bashrc is owned by the user.
#
# The block written to ~/.bashrc is delimited by markers so re-running this
# script just replaces the previous block instead of stacking duplicates.

set -u

is_zsh_path() {
    case "$1" in
        */zsh) [ -x "$1" ] ;;
        *)     return 1 ;;
    esac
}

current_shell="${SHELL:-}"
if [ -n "$current_shell" ] && is_zsh_path "$current_shell"; then
    zsh_version=$("$current_shell" --version 2>/dev/null | cut -d' ' -f2)
    echo "✅ \$SHELL is already zsh: $current_shell (version ${zsh_version:-unknown})"
    exit 0
fi

# ----- Locate zsh -----
zsh_path=""
if command -v zsh >/dev/null 2>&1; then
    zsh_path=$(command -v zsh)
elif [ -x "$HOME/.local/bin/zsh" ]; then
    zsh_path="$HOME/.local/bin/zsh"
fi

if [ -z "$zsh_path" ]; then
    cat <<'EOF' >&2
❌ zsh not found in PATH or $HOME/.local/bin.

Install hints:
  - Ubuntu/Debian (with root): sudo apt install zsh
  - macOS (with Homebrew):     brew install zsh
  - Without root (Linux):      build from source into $HOME/.local
                               (see https://github.com/romkatv/zsh-bin)
Re-run this script after installing.
EOF
    exit 1
fi

zsh_version=$("$zsh_path" --version 2>/dev/null | cut -d' ' -f2)
echo "🔄 Found zsh: $zsh_path (version ${zsh_version:-unknown})"

# ----- Step 1: try chsh -----
chsh_done=0
if command -v chsh >/dev/null 2>&1; then
    # zsh must be listed in /etc/shells for non-root chsh to succeed.
    if [ -r /etc/shells ] && ! grep -qxF "$zsh_path" /etc/shells; then
        echo "ℹ️  $zsh_path is not in /etc/shells; skipping chsh."
    elif [ "$(id -u)" = "0" ]; then
        if chsh -s "$zsh_path" "${LOGNAME:-$USER}" 2>/dev/null; then chsh_done=1; fi
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        if sudo chsh -s "$zsh_path" "${LOGNAME:-$USER}" 2>/dev/null; then chsh_done=1; fi
    else
        echo "ℹ️  No root / passwordless sudo; skipping chsh."
    fi
fi

if [ "$chsh_done" = "1" ]; then
    echo "✅ Login shell changed to $zsh_path via chsh."
    echo "🔔 Log out and log back in for the change to take effect."
    exit 0
fi

# ----- Step 2: fallback — idempotent auto-exec block in ~/.bashrc -----
bashrc="$HOME/.bashrc"
marker_begin="# >>> dotfiles activate_zsh >>>"
marker_end="# <<< dotfiles activate_zsh <<<"

# Make sure ~/.bashrc exists.
[ -f "$bashrc" ] || : > "$bashrc"

# Strip any previous block so this script is idempotent.
if grep -qF "$marker_begin" "$bashrc"; then
    awk -v b="$marker_begin" -v e="$marker_end" '
        $0 == b { skip = 1; next }
        skip && $0 == e { skip = 0; next }
        !skip { print }
    ' "$bashrc" > "$bashrc.tmp" && mv "$bashrc.tmp" "$bashrc"
fi

# $zsh_path is expanded NOW (concrete path baked into bashrc).
# Other $-references are escaped so they're evaluated at bashrc load time.
cat >> "$bashrc" <<EOF
$marker_begin
# Managed by ~/.dotfiles/zsh/activate_zsh.sh — do not edit between markers.
# Ensure user-local binaries (incl. zsh) are reachable.
case ":\$PATH:" in
    *":\$HOME/.local/bin:"*) ;;
    *) export PATH="\$HOME/.local/bin:\$PATH" ;;
esac
# Auto-launch zsh for interactive bash sessions. Set NO_AUTO_ZSH=1 to bypass.
if [ -z "\$ZSH_VERSION" ] && [ -z "\$NO_AUTO_ZSH" ] && [ -x "$zsh_path" ] && case "\$-" in *i*) true;; *) false;; esac; then
    export SHELL="$zsh_path"
    exec "\$SHELL" -l
fi
$marker_end
EOF

echo "✅ Installed auto-launch block in $bashrc"
echo "🔔 Open a new terminal (or run: exec \"$zsh_path\" -l) to enter zsh."
