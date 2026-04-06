#!/usr/bin/env bash
# setup-path.sh
# Checks whether ~/bin is on your PATH. If not, adds it to the correct
# shell RC file and tells you how to apply the change immediately.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 1 -- PATH Setup"
echo "============================================="
echo ""

# ── Check if ~/bin is already on PATH ─────────────────────────────────────────
BIN_DIR="$HOME/bin"

if echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  echo "[PASS] $BIN_DIR is already on your PATH. Nothing to do."
  echo ""
  exit 0
fi

# ── ~/bin is NOT on PATH -- add it ────────────────────────────────────────────
# platform-detect.sh sets SHELL_RC to the correct RC file for your shell
# (e.g., ~/.bashrc for bash, ~/.zshrc for zsh).
echo "[INFO] $BIN_DIR is not on your PATH."
echo "[INFO] Adding it to: $SHELL_RC"
echo ""

# Append the PATH export to the shell RC file
cat >> "$SHELL_RC" << 'PATH_BLOCK'

# Added by mermaid-hybrid-stack-guide setup-path.sh
# Makes ~/bin scripts (including mermaid-render) available as commands.
export PATH="$HOME/bin:$PATH"
PATH_BLOCK

echo "[PASS] Added PATH export to $SHELL_RC"
echo ""
echo "Apply the change in your current terminal by running:"
echo "  source $SHELL_RC"
echo ""
echo "Or open a new terminal -- it will pick up the change automatically."
echo ""
echo "============================================="
echo "  PATH setup complete. Re-run this script"
echo "  anytime to check the status."
echo "============================================="
echo ""
