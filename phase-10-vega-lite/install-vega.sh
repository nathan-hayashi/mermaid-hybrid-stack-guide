#!/usr/bin/env bash
# install-vega.sh
# Installs Vega-Lite, Vega CLI, and the canvas package globally via npm.
#
# Three packages are installed:
#   vega-lite  -- the Vega-Lite specification library
#   vega-cli   -- provides the vl2svg and vl2png command-line tools
#   vega       -- the core Vega rendering engine (vega-cli peer dependency)
#   canvas     -- required for PNG rendering (Error 8 without it)
#
# NOTE: SVG rendering works without canvas. If canvas fails to install
# (common due to native compilation requirements), you can still generate
# SVGs with vl2svg. Install canvas separately later when you need PNGs.
#
# Usage:
#   ./install-vega.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 10: Install Vega-Lite ==="
echo ""

# ── Check that npm is available ───────────────────────────────────────────────
if ! command -v npm &>/dev/null; then
  echo "ERROR: npm is not installed or not on PATH."
  echo "  Install Node.js v20+ from https://nodejs.org first."
  exit 1
fi

echo "npm found: $(npm --version)"
echo ""

# ── Install core Vega packages ────────────────────────────────────────────────
# These three packages together provide the vl2svg and vl2png CLI tools.
echo "Installing vega-lite, vega-cli, and vega globally..."
echo "(This may take a minute on first install)"
echo ""

sudo npm install -g vega-lite vega-cli vega

CORE_EXIT=$?
if [ "$CORE_EXIT" -ne 0 ]; then
  echo ""
  echo "ERROR: Core Vega packages failed to install (exit code $CORE_EXIT)."
  echo "  Check npm output above for details."
  exit 1
fi

echo ""
echo "PASS: vega-lite, vega-cli, and vega installed."

# ── Install canvas (required for PNG output) ──────────────────────────────────
# canvas is a native Node.js module. It requires build tools (python, gcc, etc.)
# On WSL 2 Ubuntu, these are usually available. On minimal Docker images, you
# may need: sudo apt-get install -y build-essential libcairo2-dev libpango1.0-dev
echo ""
echo "Installing canvas (required for PNG/vl2png rendering)..."
echo "NOTE: If this fails, SVG rendering still works. See README for details."
echo ""

sudo npm install -g canvas

CANVAS_EXIT=$?
if [ "$CANVAS_EXIT" -ne 0 ]; then
  echo ""
  echo "WARN: canvas failed to install (exit code $CANVAS_EXIT)."
  echo "  PNG rendering (vl2png) will not work until canvas is installed."
  echo "  SVG rendering (vl2svg) is unaffected -- continue with Phase 10."
  echo ""
  echo "  To fix canvas on Ubuntu/WSL 2, try:"
  echo "    sudo apt-get install -y build-essential libcairo2-dev libpango1.0-dev"
  echo "    sudo npm install -g canvas"
else
  echo ""
  echo "PASS: canvas installed. PNG rendering available."
fi

# ── Verify vl2svg is accessible ───────────────────────────────────────────────
echo ""
if command -v vl2svg &>/dev/null; then
  echo "PASS: vl2svg is on PATH."
  vl2svg --version 2>/dev/null && true  # version flag may not exist; ignore error
else
  echo "WARN: vl2svg not found on PATH after install."
  echo "  This can happen if npm global bin dir is not in PATH."
  echo "  Add this to your ~/.bashrc or ~/.zshrc:"
  echo "    export PATH=\"\$(npm config get prefix)/bin:\$PATH\""
fi

echo ""
echo "=== Vega-Lite install complete. Run create-vega-wrapper.sh next. ==="
