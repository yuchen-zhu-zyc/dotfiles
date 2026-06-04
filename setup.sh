#!/usr/bin/env bash
#
# One-shot bootstrap for this dotfiles repo on a fresh Linux/macOS host.
# Re-runnable: each step is idempotent.
#
#   1. Install zsh (apt with sudo, or build into ~/.local without root).
#   2. Make zsh the interactive shell (chsh, or bashrc auto-exec fallback).
#   3. Refresh dotbot symlinks (~/.zshrc, ~/.zsh, ~/.p10k.zsh).
#   4. Clone zsh plugins (oh-my-zsh, powerlevel10k, ...).
#   5. Optional: x-cmd CLI manager (best-effort, never blocks setup).

set -e
cd "$(dirname "$0")"

# Refresh apt indexes if we have passwordless sudo (purely a convenience for
# brew/install_app.sh users; setup itself doesn't depend on it).
if [ "$(uname)" = "Linux" ] && command -v sudo >/dev/null 2>&1; then
    if sudo -n apt update 2>/dev/null; then
        :
    else
        echo "ℹ️  Skipping apt update (no passwordless sudo on this host)."
    fi
fi

# 1. Ensure zsh is installed (no-root capable).
bash ./zsh/install_zsh.sh

# 2. Make zsh the login shell.
bash ./zsh/activate_zsh.sh

# 3. dotbot link. Drop existing top-level dotfile symlinks so dotbot's
#    `relink: true` re-creates them cleanly. Real (non-symlink) files are
#    NOT touched here — dotbot will fail loudly so we don't lose user data.
[ -L "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
[ -L "$HOME/.zsh"   ] && rm -f "$HOME/.zsh"
[ -L "$HOME/.p10k.zsh" ] && rm -f "$HOME/.p10k.zsh"
./install

# 4. zsh plugins.
bash ./zsh/install_plugins.sh

# 5. x-cmd is optional and may fail behind restrictive proxies; never block.
if [ -x ./x-cmd/install_x.sh ] || [ -f ./x-cmd/install_x.sh ]; then
    bash ./x-cmd/install_x.sh || echo "⚠️  x-cmd install skipped/failed (continuing)."
fi

echo
echo "🎉 dotfiles bootstrap complete."
echo
if [ ! -f "$HOME/.zshrc.local" ] && [ -f local.zshrc.template ]; then
    cat <<EOF
ℹ️  Optional: create your machine-local zsh config from the template:
        cp local.zshrc.template ~/.zshrc.local
        \$EDITOR ~/.zshrc.local
    \$HOME/.zshrc.local is not tracked here — put per-host env vars,
    secrets (e.g. tokens), and personal aliases there.

EOF
fi
echo "👉  Open a new terminal (or run: exec zsh -l) to enter zsh."
