#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_SRC="$SCRIPT_DIR/nvim"
TMUX_SRC="$SCRIPT_DIR/tmux/tmux.conf"

NVIM_DEST="$HOME/.config/nvim"
TMUX_DEST_DIR="$HOME/.config/tmux"
TMUX_DEST="$TMUX_DEST_DIR/tmux.conf"
TPM_DIR="$HOME/.tmux/plugins/tpm"

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
        echo "Backing up $target → $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        echo "Removing existing symlink $target"
        rm "$target"
    fi
}

echo "==> Installing configs ($(uname -s))"

# -- Neovim / NvChad ----------------------------------------------------------

backup_if_exists "$NVIM_DEST"
mkdir -p "$(dirname "$NVIM_DEST")"
ln -s "$NVIM_SRC" "$NVIM_DEST"
echo "Linked $NVIM_SRC → $NVIM_DEST"

# -- tmux ----------------------------------------------------------------------

backup_if_exists "$TMUX_DEST"
mkdir -p "$TMUX_DEST_DIR"
ln -s "$TMUX_SRC" "$TMUX_DEST"
echo "Linked $TMUX_SRC → $TMUX_DEST"

# -- TPM (Tmux Plugin Manager) ------------------------------------------------

if [ ! -d "$TPM_DIR" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed at $TPM_DIR"
fi

# -- Done ----------------------------------------------------------------------

echo ""
echo "Done! Next steps:"
echo "  1. Install neovim if not already installed (https://github.com/neovim/neovim)"
echo "  2. Open nvim — NvChad and plugins will bootstrap automatically on first launch"
echo "  3. Open tmux, then press prefix + I (C-a + I) to install tmux plugins"
echo "  4. Test navigation: open nvim inside tmux, create splits, and use C-h/j/k/l"
