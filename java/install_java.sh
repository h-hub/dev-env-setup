#!/bin/bash
# Install a Java version using SDKMAN!
#
# Usage:
#   ./install_java.sh <major-version>
#
# Examples:
#   ./install_java.sh 8
#   ./install_java.sh 11
#   ./install_java.sh 17
#   ./install_java.sh 21
#   ./install_java.sh 25
#
# The script will:
#   1. Install SDKMAN! if not already installed
#   2. Find the latest Temurin (Eclipse Adoptium) build for the given major version
#   3. Install it via SDKMAN!

set -e

JAVA_VERSION="$1"

# ── Install SDKMAN! if not present ───────────────────────────────────────────
if [[ ! -d "$HOME/.sdkman" ]]; then
  echo "SDKMAN! not found. Installing..."
  curl -s "https://get.sdkman.io" | bash
  echo "SDKMAN! installed."
fi

# Source SDKMAN! so we can use it in this script
export SDKMAN_DIR="$HOME/.sdkman"
# shellcheck source=/dev/null
source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ── Find the latest Temurin identifier for the requested version ─────────────
echo "Looking for Java $JAVA_VERSION (Temurin) in SDKMAN!..."

CANDIDATE=$(sdk list java 2>/dev/null \
  | grep -E "tem$" \
  | grep -E "^\s+\|.*\|\s+${JAVA_VERSION}\." \
  | head -1 \
  | awk '{print $NF}')

if [[ -z "$CANDIDATE" ]]; then
  echo "Error: No Temurin distribution found for Java $JAVA_VERSION." >&2
  echo ""
  echo "Available Temurin versions:"
  sdk list java 2>/dev/null | grep -E "tem$" || true
  exit 1
fi

echo "Found: $CANDIDATE"

# ── Install the JDK ─────────────────────────────────────────────────────────
if sdk list java 2>/dev/null | grep -q "installed.*${CANDIDATE}"; then
  echo "Java $CANDIDATE is already installed."
else
  echo "Installing Java $CANDIDATE..."
  sdk install java "$CANDIDATE"
fi

# ── Print summary ────────────────────────────────────────────────────────────
JAVA_HOME_PATH="$SDKMAN_DIR/candidates/java/$CANDIDATE"

echo ""
echo "✅ Java $JAVA_VERSION installed via SDKMAN!"
echo ""
echo "  Identifier : $CANDIDATE"
echo "  JAVA_HOME  : $JAVA_HOME_PATH"
echo ""
echo "To use this version:"
echo "  sdk use java $CANDIDATE       # for this shell session"
echo "  sdk default java $CANDIDATE   # set as global default"
