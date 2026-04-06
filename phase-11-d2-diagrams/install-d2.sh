#!/usr/bin/env bash
# install-d2.sh
# Installs the D2 diagram language via its official install script.
# Also installs libasound2t64, required by Playwright/Chromium for PNG
# rendering on WSL 2 Ubuntu.
#
# What gets installed:
#   d2           -- the D2 CLI (diagram compiler)
#   libasound2t64 -- ALSA audio library required by Chromium on WSL 2
#                    (PNG rendering uses a headless browser internally)
#
# Usage:
#   ./install-d2.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 11: Install D2 ==="
echo ""

# ── Install D2 via official installer ─────────────────────────────────────────
# The official D2 installer detects your OS and installs the correct binary.
# On Linux/WSL 2, it places d2 in /usr/local/bin.
# Source: https://d2lang.com/tour/install
echo "Installing D2 via official installer..."
echo "(This downloads and runs: https://d2lang.com/install.sh)"
echo ""

curl -fsSL https://d2lang.com/install.sh | sh -s --

D2_EXIT=$?
if [ "$D2_EXIT" -ne 0 ]; then
  echo ""
  echo "ERROR: D2 install failed (exit code $D2_EXIT)."
  echo "  Check your internet connection and try again."
  echo "  Manual install: https://github.com/terrastruct/d2/releases"
  exit 1
fi

echo ""
echo "PASS: D2 installed."

# ── Install libasound2t64 (Playwright/Chromium dependency) ────────────────────
# Chromium (used by Playwright for PNG rendering) requires ALSA on Linux.
# libasound2t64 is the Ubuntu 24.04 package name (was libasound2 on older Ubuntu).
# Without this, PNG rendering fails with a cryptic Chromium launch error.
echo ""
echo "Installing libasound2t64 (required for PNG rendering via Chromium/Playwright)..."
sudo apt-get install -y libasound2t64

APT_EXIT=$?
if [ "$APT_EXIT" -ne 0 ]; then
  echo ""
  echo "WARN: libasound2t64 install failed (exit code $APT_EXIT)."
  echo "  PNG rendering may not work. SVG rendering is unaffected."
  echo "  Try manually: sudo apt-get install -y libasound2t64"
else
  echo "PASS: libasound2t64 installed."
fi

# ── Verify d2 is on PATH ──────────────────────────────────────────────────────
echo ""
if command -v d2 &>/dev/null; then
  echo "PASS: d2 is on PATH."
  d2 --version
else
  echo "WARN: d2 not found on PATH immediately after install."
  echo "  This may require a shell restart. Try:"
  echo "    source ~/.bashrc"
  echo "  or open a new terminal, then run: d2 --version"
fi

echo ""
echo "=== D2 install complete. Run create-d2-wrapper.sh next. ==="
