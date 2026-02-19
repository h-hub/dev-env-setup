#!/bin/bash
# Script to download LazyVim to ~/.config/lazy-react and set up React/TypeScript development
# with Tailwind CSS, Prettier, ESLint, DAP debugging, and all required extras

set -e

# 1. Download LazyVim starter template
if [ -d "$HOME/.config/lazy-react" ]; then
  echo "Directory ~/.config/lazy-react already exists."
  read -rp "Do you want to remove it and re-clone? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/lazy-react"
    echo "Removed ~/.config/lazy-react."
  else
    echo "Keeping existing directory. Continuing with current config."
  fi
fi

if [ ! -d "$HOME/.config/lazy-react" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/lazy-react
fi

# 2. Enable LazyVim extras for React/TypeScript development
cat <<'EOF' > ~/.config/lazy-react/lazyvim.json
{
  "extras": [
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.tailwind",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.markdown",
    "lazyvim.plugins.extras.linting.eslint",
    "lazyvim.plugins.extras.formatting.prettier",
    "lazyvim.plugins.extras.dap.core",
    "lazyvim.plugins.extras.dap.nlua",
    "lazyvim.plugins.extras.test.core",
    "lazyvim.plugins.extras.editor.telescope",
    "lazyvim.plugins.extras.coding.mini-surround",
    "lazyvim.plugins.extras.util.mini-hipatterns"
  ],
  "news": {
    "NEWS.md": ""
  },
  "version": 7
}
EOF

echo "LazyVim extras enabled for React/TypeScript development."

# 3. Add custom React plugins (emmet, autotag, TSX support)
mkdir -p ~/.config/lazy-react/lua/plugins

cat <<'EOF' > ~/.config/lazy-react/lua/plugins/react.lua
-- React / TypeScript / JSX / TSX enhancements
return {
  -- Auto close and auto rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- Emmet support for fast JSX/HTML authoring
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascriptreact", "typescriptreact", "jsx", "tsx" },
    init = function()
      vim.g.user_emmet_leader_key = "<C-z>"
      vim.g.user_emmet_settings = {
        javascriptreact = { extends = "jsx" },
        typescriptreact = { extends = "jsx" },
      }
    end,
  },

  -- Treesitter – ensure React-related parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "tsx",
        "typescript",
        "javascript",
        "html",
        "css",
        "json",
        "jsonc",
        "markdown",
        "markdown_inline",
        "graphql",
        "regex",
        "styled",
      },
    },
  },

  -- Tailwind CSS sorting for className attributes
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    build = "cd formatter && npm ci && npm run build",
    ft = { "html", "css", "javascriptreact", "typescriptreact", "jsx", "tsx", "svelte", "astro", "vue" },
    opts = {
      on_save_enabled = true,
    },
  },
}
EOF

echo "Custom React plugins installed."

# 4. Install colorscheme theme
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/setup_theme.sh" \
  --config-dir "$HOME/.config/lazy-react" \
  --theme "catppuccin/nvim" \
  --opts '{ flavour = "frappe" }'

# 5. Install snacks.nvim with a React-themed banner
"$SCRIPT_DIR/setup_snacks.sh" \
  --config-dir "$HOME/.config/lazy-react" \
  --banner '
    ⚛  ╔══════════════════════════════════════╗  ⚛
       ║                                      ║
       ║  ██████╗ ███████╗ █████╗  ██████╗████████╗  ║
       ║  ██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝  ║
       ║  ██████╔╝█████╗  ███████║██║        ██║     ║
       ║  ██╔══██╗██╔══╝  ██╔══██║██║        ██║     ║
       ║  ██║  ██║███████╗██║  ██║╚██████╗   ██║     ║
       ║  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝     ║
       ║                                      ║
       ║     ⚡ TypeScript · Tailwind · ESLint ⚡    ║
       ╚══════════════════════════════════════╝'

# 6. Add alias to ~/.zshrc
if ! grep -q 'alias nvim-react=' ~/.zshrc 2>/dev/null; then
  echo "alias nvim-react='NVIM_APPNAME=lazy-react nvim'" >> ~/.zshrc
  echo "Added alias 'nvim-react' to ~/.zshrc. Use 'nvim-react' to launch LazyVim for React."
else
  echo "Alias 'nvim-react' already exists in ~/.zshrc."
fi

echo ""
echo "✅ LazyVim for React/TypeScript is set up in ~/.config/lazy-react."
echo ""
echo "Enabled extras:"
echo "  • lang.typescript   – TypeScript/JavaScript LSP (vtsls), DAP adapters"
echo "  • lang.tailwind     – Tailwind CSS LSP + color previews"
echo "  • lang.json         – JSON LSP (schemastore)"
echo "  • lang.markdown     – Markdown preview & editing"
echo "  • linting.eslint    – ESLint LSP integration"
echo "  • formatting.prettier – Prettier auto-formatting"
echo "  • dap.core          – Debug Adapter Protocol UI"
echo "  • dap.nlua          – Lua debugging"
echo "  • test.core         – Test runner framework"
echo "  • editor.telescope  – Telescope fuzzy finder"
echo "  • coding.mini-surround – Surround text objects"
echo "  • util.mini-hipatterns – Highlight patterns (color codes, etc.)"
echo ""
echo "Custom plugins:"
echo "  • nvim-ts-autotag   – Auto close/rename HTML & JSX tags"
echo "  • emmet-vim         – Emmet abbreviations for JSX/HTML"
echo "  • tailwind-sorter   – Auto-sort Tailwind classes on save"
echo "  • treesitter        – tsx, typescript, javascript, html, css, json parsers"
echo ""
echo "Run 'source ~/.zshrc' then 'nvim-react' to launch."
