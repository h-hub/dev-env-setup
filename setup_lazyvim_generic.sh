#!/bin/bash
# Script to setup a generic Neovim config (nvim-text) with Black/Yellow theme and opencode.nvim

set -e

# 1. Prepare the directory
TARGET_DIR="$HOME/.config/nvim-text"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$TARGET_DIR" ]; then
  git clone https://github.com/LazyVim/starter "$TARGET_DIR"
fi

# 2. Enable LazyVim extras for JSON, YAML, and data editing
source "$SCRIPT_DIR/setup_lazyvim_plugins.sh"

# Only pass unique extras (not in COMMON_LAZYVIM_EXTRAS)
GENERIC_LAZYVIM_UNIQUE_EXTRAS="lazyvim.plugins.extras.lang.json,lazyvim.plugins.extras.lang.yaml,lazyvim.plugins.extras.formatting.prettier,lazyvim.plugins.extras.util.mini-hipatterns,lazyvim.plugins.extras.editor.aerial"
setup_lazyvim_plugins_for_config "$TARGET_DIR" "$GENERIC_LAZYVIM_UNIQUE_EXTRAS"

# 3. Add opencode.nvim configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/install_plugins.sh" install_opencode_nvim "$TARGET_DIR"

# 4. Apply Black and Yellow theme via setup_theme.sh

# Ensure the plugins directory exists
mkdir -p "$TARGET_DIR/lua/plugins"

# Remove existing colorscheme.lua to ensure a clean install of the new theme
rm -f "$TARGET_DIR/lua/plugins/colorscheme.lua"

"$SCRIPT_DIR/setup_theme.sh" \
  --config-dir "$TARGET_DIR" \
  --theme "rose-pine/neovim"

# 5. Apply Data/Text Dashboard via setup_snacks.sh
rm -f "$TARGET_DIR/lua/plugins/snacks.lua"
"$SCRIPT_DIR/setup_snacks.sh" \
  --config-dir "$TARGET_DIR" \
  --banner '
    ░░░░░░░  DATA  &  TEXT  EDITOR  ░░░░░░░
    
    ███╗   ██╗██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██║   ██║██║████╗ ████║
    ██╔██╗ ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
    
    >>  JSON  ·  YAML  ·  MD  ·  TXT  <<
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░'

# 6. Set the alias in ~/.zshrc
if grep -q "alias n=" ~/.zshrc; then
  sed -i '' 's|alias n=.*|alias n="NVIM_APPNAME=nvim-text nvim"|' ~/.zshrc
else
  echo 'alias n="NVIM_APPNAME=nvim-text nvim"' >>~/.zshrc
fi

echo "✅ Generic editor 'n' setup complete."
echo "✅ Theme: Black & Yellow"
echo "✅ Keymaps: <C-a>/<C-x> for OpenCode, +/- for numbers."
