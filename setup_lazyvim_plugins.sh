#!/bin/bash
set -e

enable_lazyvim_extras() {
  local config_dir="$1"
  local extras_to_enable="$2"
  local lazyvim_json_file="${3:-$config_dir/lazyvim.json}"

  mkdir -p "$(dirname "$lazyvim_json_file")"

  # Initialize lazyvim.json if it doesn't exist
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
    # Use jq to split the string into a JSON array and merge without duplicates
    jq --arg extras "$extras_to_enable" \
      '.extras = ($extras | split(",") | map(select(length > 0)))' \
      "$lazyvim_json_file" >"$lazyvim_json_file.tmp" && mv "$lazyvim_json_file.tmp" "$lazyvim_json_file"
  else
    # Manual Bash reconstruction (Reliable version)
    IFS=',' read -r -a extras_array <<<"$extras_to_enable"

    # Build the JSON array string: "item1", "item2"
    local json_items=""
    for i in "${!extras_array[@]}"; do
      # Trim whitespace if any
      item=$(echo "${extras_array[$i]}" | xargs)
      if [ -n "$item" ]; then
        json_items="$json_items\"$item\""
        if [ $i -lt $((${#extras_array[@]} - 1)) ]; then
          json_items="$json_items, "
        fi
      fi
    done

    # Rewrite the file with the new array
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

COMMON_LAZYVIM_EXTRAS="lazyvim.plugins.extras.dap.core,lazyvim.plugins.extras.dap.nlua,lazyvim.plugins.extras.editor.telescope,lazyvim.plugins.extras.test.core,lazyvim.plugins.extras.lang.markdown,lazyvim.plugins.extras.ui.smear-cursor"

# Accept additional LazyVim plugins and combine with COMMON_LAZYVIM_EXTRAS
setup_lazyvim_plugins_for_config() {
  local config_dir="$1"
  local additional_plugins="$2"
  local combined_extras="$COMMON_LAZYVIM_EXTRAS"
  if [ -n "$additional_plugins" ]; then
    # Remove leading/trailing commas and combine
    additional_plugins=$(echo "$additional_plugins" | sed 's/^,*//;s/,*$//')
    if [ -n "$additional_plugins" ]; then
      combined_extras="$combined_extras,$additional_plugins"
    fi
  fi
  enable_lazyvim_extras "$config_dir" "$combined_extras"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_lazyvim_plugins_for_config "${1:-$HOME/.config/nvim}" "$2"
fi
