#!/bin/bash
set -e

# --- New Function to Add Keymaps ---
add_lazyvim_keymap() {
  local config_dir="$1"
  local mode="$2"
  local lhs="$3"
  local rhs="$4"
  local desc="$5"
  local keymaps_file="$config_dir/lua/config/keymaps.lua"

  mkdir -p "$(dirname "$keymaps_file")"

  # Ensure the file exists
  [ ! -f "$keymaps_file" ] && touch "$keymaps_file"

  # Construct the lua line
  local map_line="vim.keymap.set(\"$mode\", \"$lhs\", $rhs, { desc = \"$desc\" })"

  # Append only if the mapping doesn't already exist in the file
  if ! grep -Fq "$lhs" "$keymaps_file"; then
    echo "$map_line" >>"$keymaps_file"
    echo "Added keymap: $lhs -> $desc"
  else
    echo "Keymap $lhs already exists, skipping."
  fi
}

enable_lazyvim_extras() {
  local config_dir="$1"
  local extras_to_enable="$2"
  local lazyvim_json_file="${3:-$config_dir/lazyvim.json}"

  mkdir -p "$(dirname "$lazyvim_json_file")"

  if [ ! -f "$lazyvim_json_file" ]; then
    cat <<'EOF' >"$lazyvim_json_file"
{
  "extras": [],
  "news": {
    "NEWS.md": ""
  },
  "version": 7
}
EOF
  fi

  if command -v jq >/dev/null 2>&1; then
    jq --arg extras "$extras_to_enable" \
      '.extras = ($extras | split(",") | map(select(length > 0)))' \
      "$lazyvim_json_file" >"$lazyvim_json_file.tmp" && mv "$lazyvim_json_file.tmp" "$lazyvim_json_file"
  else
    IFS=',' read -r -a extras_array <<<"$extras_to_enable"
    local json_items=""
    for i in "${!extras_array[@]}"; do
      item=$(echo "${extras_array[$i]}" | xargs)
      if [ -n "$item" ]; then
        json_items="$json_items\"$item\""
        if [ $i -lt $((${#extras_array[@]} - 1)) ]; then
          json_items="$json_items, "
        fi
      fi
    done

    cat <<EOF >"$lazyvim_json_file"
{
  "extras": [
    $json_items
  ],
  "news": {
    "NEWS.md": ""
  },
  "version": 7
}
EOF
  fi
  echo "Successfully updated LazyVim extras in $lazyvim_json_file"
}

COMMON_LAZYVIM_EXTRAS="lazyvim.plugins.extras.dap.core,lazyvim.plugins.extras.dap.nlua,lazyvim.plugins.extras.editor.telescope,lazyvim.plugins.extras.test.core,lazyvim.plugins.extras.lang.markdown,lazyvim.plugins.extras.ui.smear-cursor,lazyvim.plugins.extras.util.rest"

setup_lazyvim_plugins_for_config() {
  local config_dir="$1"
  local additional_plugins="$2"
  local combined_extras="$COMMON_LAZYVIM_EXTRAS"

  if [ -n "$additional_plugins" ]; then
    additional_plugins=$(echo "$additional_plugins" | sed 's/^,*//;s/,*$//')
    if [ -n "$additional_plugins" ]; then
      combined_extras="$combined_extras,$additional_plugins"
    fi
  fi

  enable_lazyvim_extras "$config_dir" "$combined_extras"

  # --- Apply the DAP Reset Mapping here ---
  add_lazyvim_keymap "$config_dir" "n" "<leader>dR" "function() require('dapui').open({ reset = true }) end" "Reset DAP UI Layout"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_lazyvim_plugins_for_config "${1:-$HOME/.config/nvim}" "$2"
fi
