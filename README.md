# nvim-conf

Shared NvChad + tmux configuration for Linux and macOS with seamless pane navigation.

## Features

- **NvChad v2.5** starter config with additional plugins
- **Seamless vim-tmux navigation** — `Ctrl+h/j/k/l` moves between vim splits and tmux panes
- **Cross-platform** — single install script for Linux (pacman/apt/dnf) and macOS (Homebrew)
- **LSP support** — TypeScript, Tailwind CSS, ESLint, HTML, CSS
- **Prettier** formatting for TS/JS/CSS/HTML/JSON via conform.nvim

## Prerequisites

- **macOS**: [Homebrew](https://brew.sh)
- **Linux**: pacman, apt, or dnf

Everything else is installed automatically by the script.

## Install

```bash
git clone git@github.com:edrpls/nvim-conf.git
cd nvim-conf
./install.sh
```

The installer will:

1. Install neovim, tmux, gcc, make, ripgrep, tree-sitter-cli
2. Install JetBrainsMono Nerd Font
3. Clean old nvim state and symlink configs
4. Clone TPM (Tmux Plugin Manager)
5. Bootstrap nvim plugins via Lazy

## Post-install

1. Open nvim and run `:MasonInstallAll` and `:TSInstallAll`
2. Restart nvim for theme cache to load
3. Open tmux, press `C-a I` to install tmux plugins
4. Set your terminal font to **JetBrainsMono Nerd Font**

## Key bindings

### tmux (prefix: `C-a`)

| Key | Action |
|---|---|
| `C-a \|` | Split pane vertically |
| `C-a -` | Split pane horizontally |
| `C-a r` | Reload tmux config |
| `C-a C-l` | Clear terminal (since `C-l` is used for navigation) |

### Navigation (works across vim and tmux)

| Key | Action |
|---|---|
| `C-h` | Move left |
| `C-j` | Move down |
| `C-k` | Move up |
| `C-l` | Move right |

### nvim (leader: `Space`)

| Key | Action |
|---|---|
| `Space ch` | NvChad cheatsheet |
| `Space ff` | Find files (Telescope) |
| `Space fw` | Find word (ripgrep) |
| `Space e` | Toggle file tree |

See `Space ch` inside nvim for the full list.

## Structure

```
nvim-conf/
├── nvim/                        # Symlinked to ~/.config/nvim
│   ├── init.lua                 # Entry point, bootstraps lazy.nvim
│   ├── lua/
│   │   ├── chadrc.lua           # NvChad theme (chadracula)
│   │   ├── options.lua          # Editor options
│   │   ├── autocmds.lua         # Autocommands (nvim-tree on startup)
│   │   ├── mappings.lua         # Key bindings
│   │   ├── plugins/
│   │   │   └── init.lua         # Plugin specs
│   │   └── configs/
│   │       ├── conform.lua      # Formatter config (prettier, stylua)
│   │       ├── lspconfig.lua    # LSP servers
│   │       └── lazy.lua         # Lazy.nvim options
├── tmux/
│   └── tmux.conf                # Symlinked to ~/.config/tmux/tmux.conf
└── install.sh                   # Cross-platform installer
```

## License

See [LICENSE](LICENSE).
