#!/usr/bin/env bash
# create-theme.sh
# Creates the enterprise Mermaid theme config files in ~/.config/mermaid/.
# Backs up any existing config files before overwriting them.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 2 -- Enterprise Theme Setup"
echo "============================================="
echo ""

CONFIG_DIR="$HOME/.config/mermaid"
LIGHT_CONFIG="$CONFIG_DIR/config.json"
DARK_CONFIG="$CONFIG_DIR/config-dark.json"

# ── Ensure the config directory exists ────────────────────────────────────────
mkdir -p "$CONFIG_DIR"
echo "[INFO] Config directory: $CONFIG_DIR"
echo ""

# ── Helper: back up a file if it already exists ───────────────────────────────
backup_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    echo "[INFO] Backed up existing $(basename "$file") to: $backup"
  fi
}

# ── Create light theme config ─────────────────────────────────────────────────
# The "base" theme is the most customizable Mermaid theme. All themeVariables
# below are overrides on top of the base defaults.
backup_if_exists "$LIGHT_CONFIG"
cat > "$LIGHT_CONFIG" << 'JSON'
{
  "theme": "base",
  "themeVariables": {
    "primaryColor": "#F0F4FC",
    "primaryTextColor": "#1F2329",
    "primaryBorderColor": "#2C5F8A",
    "lineColor": "#555555",
    "secondaryColor": "#E8F5E9",
    "tertiaryColor": "#FFF3E0",
    "fontFamily": "Inter, Segoe UI, Roboto, sans-serif",
    "fontSize": "14px"
  },
  "flowchart": {
    "curve": "basis",
    "htmlLabels": true,
    "rankSpacing": 60,
    "nodeSpacing": 40,
    "padding": 15
  }
}
JSON
echo "[PASS] Created light theme: $LIGHT_CONFIG"

# ── Create dark theme config ──────────────────────────────────────────────────
# The dark config overrides only the variables that change for dark mode.
# The mermaid-render-dark wrapper (Phase 2) also adds -b transparent so the
# SVG background is clear -- useful for embedding in dark-bg documents.
backup_if_exists "$DARK_CONFIG"
cat > "$DARK_CONFIG" << 'JSON'
{
  "theme": "base",
  "themeVariables": {
    "primaryColor": "#1E293B",
    "primaryTextColor": "#E2E8F0",
    "primaryBorderColor": "#60A5FA",
    "lineColor": "#94A3B8",
    "background": "#0F172A"
  }
}
JSON
echo "[PASS] Created dark theme: $DARK_CONFIG"

echo ""
echo "============================================="
echo "  Theme configs created."
echo "  Next: run create-dark-wrapper.sh, then test-themes.sh."
echo "============================================="
echo ""
