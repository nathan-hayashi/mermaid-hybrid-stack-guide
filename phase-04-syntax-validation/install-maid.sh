#!/usr/bin/env bash
# install-maid.sh
# Installs @probelabs/maid globally for fast Mermaid syntax validation.
#
# Why sudo for WSL 2?
#   Global npm installs (npm install -g) write to /usr/lib/node_modules which
#   is owned by root in most WSL 2 setups. sudo is required unless you have
#   configured a user-local npm prefix (npm config set prefix ~/.npm-global).
#   If you use nvm or fnm, drop the sudo -- those tools install to ~/.nvm or
#   ~/.local/share/fnm which your user already owns.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "==> Checking for maid..."

# Check if maid is already installed to avoid a redundant network round-trip.
if command -v maid >/dev/null 2>&1; then
    CURRENT_VERSION="$(maid --version 2>/dev/null || echo 'unknown')"
    echo "    maid is already installed: $CURRENT_VERSION"
    echo "    Nothing to do. Run 'sudo npm install -g @probelabs/maid' to upgrade."
    exit 0
fi

echo "==> Installing @probelabs/maid globally..."
echo "    NOTE: 'sudo' is needed for system-wide npm installs in WSL 2."
echo "    If you use nvm/fnm, remove 'sudo' from the command below."
echo ""

# The actual install. Pinning to a known-good range; adjust if a new major
# version is released and tested.
sudo npm install -g @probelabs/maid

echo ""
echo "==> Verifying install..."
if command -v maid >/dev/null 2>&1; then
    echo "    OK -- maid $(maid --version 2>/dev/null || echo '(version unknown)') is ready."
else
    echo "    ERROR: maid command not found after install. Check your PATH."
    echo "    Try: echo \$PATH and ensure the npm global bin dir is included."
    exit 1
fi
