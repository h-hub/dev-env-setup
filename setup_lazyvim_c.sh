#!/bin/bash
# Script to download LazyVim to ~/.config/lazy-c and set up C language support with DAP UI and debugging features

set -e

# 1. Download LazyVim starter template
if [ -d "$HOME/.config/lazy-c" ]; then
  echo "Directory ~/.config/lazy-c already exists."
  read -rp "Do you want to remove it and re-clone? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/lazy-c"
    echo "Removed ~/.config/lazy-c."
  else
    echo "Keeping existing directory. Continuing with current config."
  fi
fi

if [ ! -d "$HOME/.config/lazy-c" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/lazy-c
fi

# 2. Enable LazyVim extras for C, DAP, and DAP UI
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup_lazyvim_plugins.sh"
GENERIC_LAZYVIM_UNIQUE_EXTRAS="lazyvim.plugins.extras.lang.clangd,lazyvim.plugins.extras.linting.eslint,lazyvim.plugins.extras.lang.json,lazyvim.plugins.extras.lang.yaml,lazyvim.plugins.extras.formatting.prettier,lazyvim.plugins.extras.util.mini-hipatterns,lazyvim.plugins.extras.editor.aerial"
setup_lazyvim_plugins_for_config "$HOME/.config/lazy-c" "$GENERIC_LAZYVIM_UNIQUE_EXTRAS"

echo "LazyVim for C with DAP and debug UI is set up in ~/.config/lazy-c."

# 3. Install colorscheme: vim-256noir
"$SCRIPT_DIR/setup_theme.sh" \
  --config-dir "$HOME/.config/lazy-c" \
  --theme "ellisonleao/gruvbox.nvim" \
  --opts '{priority = 1000}'

"$SCRIPT_DIR/install_plugins.sh" install_opencode_nvim "$HOME/.config/lazy-c"

# 4. Install snacks.nvim with a C-themed banner
"$SCRIPT_DIR/setup_snacks.sh" \
  --config-dir "$HOME/.config/lazy-c" \
  --banner '
    ┌─────────────────────────────────────────┐
    │  ░█████╗░  ░██╗░░░░░░░██╗░░░███╗░░  │
    │  ██╔══██╗  ░██║░░██╗░░██║░░████║░░  │
    │  ██║░░╚═╝  ░╚██╗████╗██╔╝░░██╔██║░░  │
    │  ██║░░██╗  ░░████╔═████║░░░╚═╝██║░░  │
    │  ╚█████╔╝  ░░╚██╔╝░╚██╔╝░░███████╗  │
    │  ░╚════╝░  ░░░╚═╝░░░╚═╝░░░╚══════╝  │
    │                                         │
    │    >> clangd · GDB · Make · Valgrind <<  │
    │         [ K&R style since 1978 ]         │
    └─────────────────────────────────────────┘'

# 5. Add alias to ~/.zshrc
if ! grep -q 'alias nvim-c=' ~/.zshrc 2>/dev/null; then
  echo "alias nvim-c='NVIM_APPNAME=lazy-c nvim'" >>~/.zshrc
  echo "Added alias 'nvim-c' to ~/.zshrc. Use 'nvim-c' to launch LazyVim for C."
else
  echo "Alias 'nvim-c' already exists in ~/.zshrc."
fi
