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

OS="$(uname -s)"
echo "==> Installing on $OS"

# -- Helper: install a package if its command is missing -----------------------

install_pkg() {
    local cmd="$1"
    shift
    # remaining args: pacman_pkg apt_pkg dnf_pkg brew_pkg
    local pacman_pkg="$1" apt_pkg="$2" dnf_pkg="$3" brew_pkg="$4"

    if command -v "$cmd" &>/dev/null; then
        echo "$cmd already installed"
        return
    fi

    echo "Installing $cmd..."
    case "$OS" in
        Linux)
            if command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm $pacman_pkg
            elif command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y $apt_pkg
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y $dnf_pkg
            else
                echo "Error: No supported package manager found (pacman/apt/dnf)."
                echo "Install $cmd manually."
                exit 1
            fi
            ;;
        Darwin)
            if command -v brew &>/dev/null; then
                brew install $brew_pkg
            else
                echo "Error: Homebrew not found. Install it first: https://brew.sh"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# -- Prerequisites (https://nvchad.com/docs/quickstart/install/) ---------------

#                cmd       pacman          apt                 dnf             brew
install_pkg     nvim      "neovim"        "neovim"            "neovim"        "neovim"
install_pkg     gcc       "gcc"           "gcc"               "gcc"           "gcc"
install_pkg     make      "make"          "make"              "make"          "make"
install_pkg     rg        "ripgrep"       "ripgrep"           "ripgrep"       "ripgrep"
install_pkg     tree-sitter "tree-sitter"  "tree-sitter-cli"  "tree-sitter-cli" "tree-sitter"

echo ""

# -- Nerd Font -----------------------------------------------------------------

FONT_NAME="JetBrainsMono"
FONT_DIR_LINUX="$HOME/.local/share/fonts"
FONT_DIR_MAC="$HOME/Library/Fonts"

has_nerd_font() {
    if command -v fc-list &>/dev/null; then
        fc-list | grep -qi "nerd" && return 0
    fi
    # fallback: check font directories directly
    case "$OS" in
        Linux)  ls "$FONT_DIR_LINUX"/*NerdFont* &>/dev/null 2>&1 && return 0 ;;
        Darwin) ls "$FONT_DIR_MAC"/*NerdFont* &>/dev/null 2>&1 && return 0 ;;
    esac
    return 1
}

if has_nerd_font; then
    echo "Nerd Font detected"
else
    echo "Installing $FONT_NAME Nerd Font..."
    case "$OS" in
        Darwin)
            if command -v brew &>/dev/null; then
                brew install --cask font-jetbrains-mono-nerd-font
            else
                echo "Error: Homebrew not found. Install it first: https://brew.sh"
                exit 1
            fi
            ;;
        Linux)
            FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.tar.xz"
            FONT_TMP="$(mktemp -d)"
            echo "Downloading from $FONT_URL..."
            curl -fsSL "$FONT_URL" -o "$FONT_TMP/${FONT_NAME}.tar.xz"
            mkdir -p "$FONT_DIR_LINUX"
            tar -xf "$FONT_TMP/${FONT_NAME}.tar.xz" -C "$FONT_DIR_LINUX"
            rm -rf "$FONT_TMP"
            if command -v fc-cache &>/dev/null; then
                fc-cache -f "$FONT_DIR_LINUX"
            fi
            echo "Installed $FONT_NAME Nerd Font to $FONT_DIR_LINUX"
            ;;
    esac
    echo "NOTE: Set your terminal font to \"JetBrainsMono Nerd Font\" for icons to display."
fi

# -- Clean old Neovim state (recommended for fresh NvChad installs) -----------

for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -d "$dir" ]; then
        echo "Removing old Neovim data: $dir"
        rm -rf "$dir"
    fi
done

# -- NvChad config -------------------------------------------------------------

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

# -- Bootstrap Neovim plugins --------------------------------------------------

echo ""
echo "Bootstrapping Neovim plugins (this may take a minute)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null
echo "Plugins installed."

echo "Running MasonInstallAll..."
nvim --headless "+MasonInstallAll" +qa 2>/dev/null || true
echo "Mason packages installed."

echo "Running TSInstallAll..."
nvim --headless "+TSInstallAll" +qa 2>/dev/null || true
echo "Tree-sitter parsers installed."

# -- Done ----------------------------------------------------------------------

echo ""
echo "Done! Next steps:"
echo "  1. Open tmux, then press prefix + I (C-a + I) to install tmux plugins"
echo "  2. Test navigation: open nvim inside tmux, create splits, and use C-h/j/k/l"
