#!/bin/bash
# Script to download LazyVim to ~/.config/lazy-python and set up Python development
# with LSP, linting, formatting, DAP debugging, and all required extras

set -e

# 1. Download LazyVim starter template
if [ -d "$HOME/.config/lazy-python" ]; then
  echo "Directory ~/.config/lazy-python already exists."
  read -rp "Do you want to remove it and re-clone? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/lazy-python"
    echo "Removed ~/.config/lazy-python."
  else
    echo "Keeping existing directory. Continuing with current config."
  fi
fi

if [ ! -d "$HOME/.config/lazy-python" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/lazy-python
fi

# 2. Install fd (used by telescope for file finding)
if ! command -v fd &>/dev/null; then
  echo "Installing fd..."
  brew install fd
else
  echo "fd is already installed."
fi

# 3. Enable LazyVim extras for Python development
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup_lazyvim_plugins.sh"
PYTHON_EXTRAS="lazyvim.plugins.extras.lang.python,lazyvim.plugins.extras.lang.json,lazyvim.plugins.extras.lang.yaml,lazyvim.plugins.extras.lang.toml,lazyvim.plugins.extras.lang.markdown"
setup_lazyvim_plugins_for_config "$HOME/.config/lazy-python" "$PYTHON_EXTRAS"

echo "LazyVim extras enabled for Python development."

# 4. Add custom Python plugins (virtual env selector, docstrings, etc.)
mkdir -p ~/.config/lazy-python/lua/plugins

cat <<'EOF' >~/.config/lazy-python/lua/plugins/python.lua
-- Python development enhancements
return {
  -- Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    cmd = "VenvSelect",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
    },
  },

  -- Python docstring generator
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    cmd = "Neogen",
    keys = {
      { "<leader>cn", "<cmd>Neogen<cr>", desc = "Generate docstring" },
    },
    opts = {
      snippet_engine = "luasnip",
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    },
  },

  -- Treesitter – ensure Python-related parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
        "toml",
        "yaml",
        "json",
        "jsonc",
        "markdown",
        "markdown_inline",
        "regex",
        "rst",
        "ninja",
      },
    },
  },

  -- Python indent
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  -- Python test runner integration
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = ".venv/bin/python",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Disable only ruff_lsp, keep anything else
      opts.servers = opts.servers or {}
      opts.servers["ruff_lsp"] = { enabled = false }
      -- Ensure basedpyright is enabled
      opts.servers["basedpyright"] = opts.servers["basedpyright"] or {}
      opts.servers["basedpyright"].enabled = true
    end,
  }
}
EOF

echo "Custom Python plugins installed."

# 5. Install colorscheme theme
"$SCRIPT_DIR/setup_theme.sh" \
  --config-dir "$HOME/.config/lazy-python" \
  --theme "rebelot/kanagawa.nvim" \
  --opts '{ theme = "dragon" }'

"$SCRIPT_DIR/install_plugins.sh" install_opencode_nvim "$HOME/.config/lazy-python"

# 6. Install snacks.nvim with a Python-themed banner
"$SCRIPT_DIR/setup_snacks.sh" \
  --config-dir "$HOME/.config/lazy-python" \
  --banner '
    🐍 ╔══════════════════════════════════════╗  🐍
       ║                                      ║
       ║  ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗  ║
       ║  ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║  ║
       ║  ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║  ║
       ║  ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║  ║
       ║  ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║  ║
       ║  ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝  ║
       ║                                      ║
       ║     ⚡ Ruff · Black · Pytest · LSP ⚡    ║
       ╚══════════════════════════════════════╝'

# 7. Add alias to ~/.zshrc
if ! grep -q 'alias nvim-python=' ~/.zshrc 2>/dev/null; then
  echo "alias nvim-python='NVIM_APPNAME=lazy-python nvim'" >>~/.zshrc
  echo "Added alias 'nvim-python' to ~/.zshrc. Use 'nvim-python' to launch LazyVim for Python."
else
  echo "Alias 'nvim-python' already exists in ~/.zshrc."
fi

echo ""
echo "✅ LazyVim for Python is set up in ~/.config/lazy-python."
echo ""
echo "Enabled extras:"
echo "  • lang.python       – Python LSP (pyright), ruff linter/formatter, debugpy"
echo "  • lang.json         – JSON LSP (schemastore)"
echo "  • lang.yaml         – YAML LSP support"
echo "  • lang.toml         – TOML LSP support (for pyproject.toml)"
echo "  • lang.markdown     – Markdown preview & editing"
echo ""
echo "Custom plugins:"
echo "  • venv-selector     – Virtual environment selector (<leader>cv)"
echo "  • neogen            – Docstring generator (<leader>cn)"
echo "  • vim-python-pep8-indent – PEP8 indentation"
echo "  • neotest-python    – Pytest integration"
echo "  • treesitter        – python, toml, yaml, json parsers"
echo ""
echo "Run 'source ~/.zshrc' then 'nvim-python' to launch."
