#!/bin/bash
# Reusable script to add folke/snacks.nvim to a LazyVim configuration.
#
# Usage:
#   ./setup_snacks.sh [OPTIONS]
#
# Options:
#   -c, --config-dir DIR    Neovim config directory (default: ~/.config/lazy-c)
#   -b, --banner TEXT       Custom dashboard banner text (multiline, use \n for newlines)
#   -B, --banner-file FILE  Read banner from a file
#   -h, --help              Show this help message
#
# Examples:
#   # Use default config dir and a simple banner
#   ./setup_snacks.sh --banner '🚀 My Neovim'
#
#   # Custom config dir with a multi-line banner
#   ./setup_snacks.sh -c ~/.config/lazy-rust -b '  ____            _\n |  _ \ _   _ ___| |_\n | |_) | | | / __| __|\n |  _ <| |_| \__ \ |_\n |_| \_\\\\__,_|___/\__|'
#
#   # Read banner from a file
#   ./setup_snacks.sh -c ~/.config/lazy-c -B ./my_banner.txt

set -e

# ── Defaults ──────────────────────────────────────────────────────────────────
CONFIG_DIR="$HOME/.config/lazy-c"
BANNER=""
BANNER_FILE=""

# ── Default banner (used when no banner is provided) ─────────────────────────
DEFAULT_BANNER='
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝'

# ── Parse arguments ──────────────────────────────────────────────────────────
usage() {
  sed -n '2,/^$/s/^# //p' "$0"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -c | --config-dir)
    CONFIG_DIR="$2"
    shift 2
    ;;
  -b | --banner)
    BANNER="$2"
    shift 2
    ;;
  -B | --banner-file)
    BANNER_FILE="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage
    ;;
  esac
done

# ── Resolve banner ───────────────────────────────────────────────────────────
if [[ -n "$BANNER_FILE" ]]; then
  if [[ ! -f "$BANNER_FILE" ]]; then
    echo "Error: Banner file '$BANNER_FILE' not found." >&2
    exit 1
  fi
  BANNER="$(cat "$BANNER_FILE")"
fi

if [[ -z "$BANNER" ]]; then
  BANNER="$DEFAULT_BANNER"
fi

# ── Validate config dir ─────────────────────────────────────────────────────
PLUGINS_DIR="$CONFIG_DIR/lua/plugins"
if [[ ! -d "$CONFIG_DIR" ]]; then
  echo "Error: Config directory '$CONFIG_DIR' does not exist."
  echo "Run your LazyVim setup script first (e.g. setup_lazyvim_c.sh)."
  exit 1
fi

mkdir -p "$PLUGINS_DIR"

# ── Build the Lua banner string ──────────────────────────────────────────────
# Convert the banner text into a Lua multiline string with proper escaping.
lua_banner_lines=""
while IFS= read -r line; do
  # Escape any backslashes and double-quotes for Lua strings
  escaped=$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')
  lua_banner_lines="${lua_banner_lines}          \"${escaped}\",\n"
done <<<"$BANNER"

# ── Write the snacks.nvim plugin spec ────────────────────────────────────────
SNACKS_FILE="$PLUGINS_DIR/snacks.lua"

if [[ -f "$SNACKS_FILE" ]]; then
  echo "snacks.nvim plugin file already exists at $SNACKS_FILE."
  read -rp "Do you want to replace it? [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Keeping existing snacks.lua. Skipping."
    exit 0
  fi
  echo "Replacing existing snacks.lua..."
fi

cat >"$SNACKS_FILE" <<LUAEOF
-- snacks.nvim – A collection of QoL plugins for Neovim
-- https://github.com/folke/snacks.nvim
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- ── UI / Eye-candy ────────────────────────────────────────────────
    bigfile    = { enabled = true },
    dashboard  = {
      enabled = true,
      preset = {
        header = table.concat({
$(printf "%b" "$lua_banner_lines")        }, "\n"),
      },
    },
    indent     = { enabled = false }, -- disabled due to race condition causing "Invalid window id" errors
    input      = { enabled = true },
    notifier   = { enabled = true, timeout = 3000 },
    scroll     = { enabled = true },
    statuscolumn = { enabled = true },
    words      = { enabled = true },

    -- ── Pickers / Navigation ──────────────────────────────────────────
    picker     = { enabled = true },
    explorer   = { enabled = true },
    scope      = { enabled = true },

    -- ── Utility ───────────────────────────────────────────────────────
    quickfile  = { enabled = true },
    rename     = { enabled = true },
    bufdelete  = { enabled = true },
    git        = { enabled = true },
    gitbrowse  = { enabled = true },
    lazygit    = { enabled = true },
    toggle     = { enabled = true },
    terminal = {
      enabled = true,
      win = {
        split = "below",
        height = 12,
        focusable = true,
        wo = {
              winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
            },
      }
    },
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end,               desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end,             desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.grep() end,                desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end,     desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,       desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end,                   desc = "File Explorer" },
    -- Find
    { "<leader>fb",      function() Snacks.picker.buffers() end,             desc = "Buffers" },
    { "<leader>ff",      function() Snacks.picker.files() end,               desc = "Find Files" },
    { "<leader>fg",      function() Snacks.picker.git_files() end,           desc = "Find Git Files" },
    { "<leader>fp",      function() Snacks.picker.projects() end,            desc = "Projects" },
    { "<leader>fr",      function() Snacks.picker.recent() end,              desc = "Recent" },
    -- Git
    { "<leader>gb",      function() Snacks.git.blame_line() end,             desc = "Git Blame Line" },
    { "<leader>gB",      function() Snacks.gitbrowse() end,                  desc = "Git Browse (open)" },
    { "<leader>gl",      function() Snacks.picker.git_log() end,             desc = "Git Log" },
    { "<leader>gL",      function() Snacks.picker.git_log_line() end,        desc = "Git Log Line" },
    { "<leader>gs",      function() Snacks.picker.git_status() end,          desc = "Git Status" },
    { "<leader>gd",      function() Snacks.picker.git_diff() end,            desc = "Git Diff (Hunks)" },
    { "<leader>gS",      function() Snacks.picker.git_stash() end,           desc = "Git Stash" },
    -- Search
    { "<leader>sb",      function() Snacks.picker.lines() end,               desc = "Buffer Lines" },
    { "<leader>sB",      function() Snacks.picker.grep_buffers() end,        desc = "Grep Open Buffers" },
    { "<leader>sg",      function() Snacks.picker.grep() end,                desc = "Grep" },
    { "<leader>sw",      function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Visual selection or word" },
    { "<leader>sd",      function() Snacks.picker.diagnostics() end,         desc = "Diagnostics" },
    { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,  desc = "Buffer Diagnostics" },
    { "<leader>sh",      function() Snacks.picker.help() end,                desc = "Help Pages" },
    { "<leader>sk",      function() Snacks.picker.keymaps() end,             desc = "Keymaps" },
    { "<leader>sm",      function() Snacks.picker.marks() end,               desc = "Marks" },
    -- LSP
    { "gd",              function() Snacks.picker.lsp_definitions() end,     desc = "Goto Definition" },
    { "gD",              function() Snacks.picker.lsp_declarations() end,    desc = "Goto Declaration" },
    { "gr",              function() Snacks.picker.lsp_references() end,      desc = "References",                nowait = true },
    { "gI",              function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy",              function() Snacks.picker.lsp_type_definitions() end,desc = "Goto T[y]pe Definition" },
    { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,        desc = "LSP Symbols" },
    { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    -- Other
    { "<leader>gg",      function() Snacks.lazygit() end,                    desc = "Lazygit" },
    { "<leader>un",      function() Snacks.notifier.hide() end,              desc = "Dismiss All Notifications" },
    { "<leader>bd",      function() Snacks.bufdelete() end,                  desc = "Delete Buffer" },
    { "<leader>bo",      function() Snacks.bufdelete.other() end,            desc = "Delete Other Buffers" },
    { "<c-/>",           function() Snacks.terminal() end,                   desc = "Toggle Terminal" },
    { "]]",              function() Snacks.words.jump(vim.v.count1) end,     desc = "Next Reference",            mode = { "n", "t" } },
    { "[[",              function() Snacks.words.jump(-vim.v.count1) end,    desc = "Prev Reference",            mode = { "n", "t" } },
  },
}
LUAEOF

echo "✅ snacks.nvim installed to $SNACKS_FILE"
echo "   Launch Neovim with your config to see it in action."
