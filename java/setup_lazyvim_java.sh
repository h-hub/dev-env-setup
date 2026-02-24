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
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/setup_lazyvim_plugins.sh"
JAVA_EXTRAS="lazyvim.plugins.extras.lang.java,lazyvim.plugins.extras.lang.yaml"
setup_lazyvim_plugins_for_config "$HOME/.config/lazy-java" "$JAVA_EXTRAS"

echo "LazyVim extras enabled for Java development."

# 3. Add custom Java plugins (enhanced treesitter, XML support)
mkdir -p ~/.config/lazy-java/lua/plugins

cat <<'EOF' >~/.config/lazy-java/lua/plugins/java.lua
-- Java development enhancements
return {
  -- Treesitter – ensure Java-related parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "java",
        "groovy",
        "xml",
        "html",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "markdown_inline",
        "regex",
        "properties",
      },
    },
  },

  -- XML support for pom.xml, Spring configs, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
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
