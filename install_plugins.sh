#!/bin/bash
# Common script to install Neovim plugins

set -e

# Function to install a colorscheme
install_colorscheme() {
  local config_dir="$1"
  local colorscheme_name="$2"
  local repo_url="$3"
  local opts_colorscheme="$4"

  mkdir -p "$config_dir/lua/plugins"
  cat <<EOF >"$config_dir/lua/plugins/colorscheme.lua"
return {
  { "$repo_url", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "$opts_colorscheme",
    },
  },
}
EOF
  echo "Installed $colorscheme_name colorscheme in $config_dir."
}

install_opencode_nvim() {
  local config_dir="$1"

  mkdir -p "$config_dir/lua/plugins"
  cat <<'EOF' >"$config_dir/lua/plugins/opencode.lua"
return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type or field for details
      -- This ensures the underlying opencode process always targets the current directory
      command = { "opencode", "." }, 
      
      -- Optional: If you want to ensure the AI always has the file tree context 
      -- in its system prompt, you can add an initial instruction here:
      system_prompt = "Always reference files in the current working directory (.).",
      
      -- Other options...
    }

    vim.o.autoread = true -- Required for `opts.events.reload`

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

    -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
    vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
    vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
  end,
}
EOF
  echo "Installed opencode.nvim in $config_dir."
}

# Command-line argument parsing
case "$1" in
install_colorscheme)
  install_colorscheme "$2" "$3" "$4" "$5"
  ;;
install_opencode_nvim)
  install_opencode_nvim "$2"
  ;;
*)
  echo "Usage: $0 {install_colorscheme|install_opencode_nvim} [args...]"
  exit 1
  ;;
esac
