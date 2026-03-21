#!/bin/bash
# Script to download LazyVim to ~/.config/lazy-java and set up Java development
# with JDTLS, DAP debugging, Lombok support, and all required extras

set -e

# 1. Download LazyVim starter template
if [ -d "$HOME/.config/lazy-java" ]; then
  echo "Directory ~/.config/lazy-java already exists."
  read -rp "Do you want to remove it and re-clone? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/lazy-java"
    echo "Removed ~/.config/lazy-java."
  else
    echo "Keeping existing directory. Continuing with current config."
  fi
fi

if [ ! -d "$HOME/.config/lazy-java" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/lazy-java
fi

# 2. Enable LazyVim extras for Java development
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup_lazyvim_plugins.sh"

JAVA_EXTRAS="lazyvim.plugins.extras.lang.java,lazyvim.plugins.extras.lang.yaml"
setup_lazyvim_plugins_for_config "$HOME/.config/lazy-java" "$JAVA_EXTRAS"

echo "LazyVim extras enabled for Java development."

# 3. Add custom Java plugins (enhanced treesitter, XML support)
mkdir -p ~/.config/lazy-java/lua/plugins

echo "Scanning SDKMAN for Java versions..."
JAVA_CANDIDATES="$HOME/.sdkman/candidates/java"
RUNTIMES_LUA=""
FIRST_VERSION=true

# Get distinct highest versions (e.g., if 17.0.14 and 17.0.5 exist, take 17.0.14)
VERSIONS=$(ls -1 "$JAVA_CANDIDATES" 2>/dev/null | grep -v "current" | sort -Vr | awk -F'[-.]' '!vis[$1]++') || ""

for entry in $VERSIONS; do
  MAJOR=$(echo "$entry" | cut -d'.' -f1)

  # Map Java 8 to JavaSE-1.8 as required by JDTLS
  if [ "$MAJOR" == "8" ]; then
    NAME="JavaSE-1.8"
  else
    NAME="JavaSE-$MAJOR"
  fi

  # Build the Lua table string
  RUNTIMES_LUA+="                {\n                  name = \"$NAME\",\n                  path = os.getenv(\"HOME\") .. \"/.sdkman/candidates/java/$entry\","

  if [ "$FIRST_VERSION" = true ]; then
    RUNTIMES_LUA+="\n                  default = true,\n                },\n"
    FIRST_VERSION=false
  else
    RUNTIMES_LUA+="\n                },\n"
  fi
done

echo "RUNTIMES_LUA"
echo $RUNTIMES_LUA

cat <<EOF >~/.config/lazy-java/lua/plugins/java.lua
return {
  -- Treesitter – ensure Java-related parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "java", "groovy", "xml", "html", "json", "jsonc",
        "yaml", "markdown", "markdown_inline", "regex", "properties",
      },
    },
  },

  -- XML support for pom.xml, Spring configs, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  -- JDTLS: Configured with your SDKMAN runtimes
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      jdtls = {
        settings = {
          java = {
            configuration = {
              runtimes = {
$(printf "$RUNTIMES_LUA")
              },
            },
          },
        },
      },
    },
  },
}
EOF

echo "Custom Java plugins installed."

# 4. Install colorscheme theme
"$SCRIPT_DIR/setup_theme.sh" \
  --config-dir "$HOME/.config/lazy-java" \
  --theme "savq/melange-nvim"

# 5. Install snacks.nvim with a Java-themed banner
"$SCRIPT_DIR/setup_snacks.sh" \
  --config-dir "$HOME/.config/lazy-java" \
  --banner '
    ╔═══════════════════════════════════════════════╗
    ║                                               ║
    ║        ██╗ █████╗ ██╗   ██╗ █████╗            ║
    ║        ██║██╔══██╗██║   ██║██╔══██╗           ║
    ║        ██║███████║██║   ██║███████║           ║
    ║   ██   ██║██╔══██║╚██╗ ██╔╝██╔══██║           ║
    ║   ╚█████╔╝██║  ██║ ╚████╔╝ ██║  ██║           ║
    ║    ╚════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝           ║
    ║                                               ║
    ║    ☕ JDTLS · Maven · Gradle  · DAP ☕          ║
    ║                                               ║
    ╚═══════════════════════════════════════════════╝'

# 6. Add alias to ~/.zshrc
if ! grep -q 'alias nvim-java=' ~/.zshrc 2>/dev/null; then
  echo "alias nvim-java='NVIM_APPNAME=lazy-java nvim'" >>~/.zshrc
  echo "Added alias 'nvim-java' to ~/.zshrc. Use 'nvim-java' to launch LazyVim for Java."
else
  echo "Alias 'nvim-java' already exists in ~/.zshrc."
fi

echo ""
echo "✅ LazyVim for Java is set up in ~/.config/lazy-java."
echo ""
echo "Enabled extras:"
echo "  • lang.java         – JDTLS LSP, nvim-jdtls, Lombok, java-debug-adapter, java-test"
echo "  • lang.json         – JSON LSP (schemastore)"
echo "  • lang.yaml         – YAML LSP (for Spring configs, CI/CD)"
echo "  • lang.markdown     – Markdown preview & editing"
echo "  • dap.core          – Debug Adapter Protocol UI"
echo "  • dap.nlua          – Lua debugging"
echo "  • test.core         – Test runner framework"
echo "  • editor.telescope  – Telescope fuzzy finder"
echo "  • coding.mini-surround – Surround text objects"
echo "  • util.mini-hipatterns – Highlight patterns (color codes, etc.)"
echo ""
echo "Custom plugins:"
echo "  • treesitter        – java, groovy, xml, yaml, json, properties parsers"
echo "  • nvim-autopairs    – Auto close brackets and quotes"
echo ""
echo "Run 'source ~/.zshrc' then 'nvim-java' to launch."
