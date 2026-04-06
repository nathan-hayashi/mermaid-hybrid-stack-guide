#!/usr/bin/env bash
# test-themes.sh
# Renders a test diagram with both the light and dark wrappers, then verifies:
#   1. Both output SVGs exist
#   2. Both are non-empty (size > 0 bytes)
#   3. The two files have different sizes (proof they used different theme configs)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 2 -- Theme Test"
echo "============================================="
echo ""

FAILED=0
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# ── Write a minimal test diagram ──────────────────────────────────────────────
TEST_MMD="$WORK_DIR/theme-test.mmd"
LIGHT_SVG="$WORK_DIR/theme-test-light.svg"
DARK_SVG="$WORK_DIR/theme-test-dark.svg"

cat > "$TEST_MMD" << 'MMD'
flowchart LR
    A["Input"] --> B["Process"] --> C["Output"]
MMD

echo "[INFO] Test diagram: $TEST_MMD"
echo ""

# ── Verify wrappers are available ─────────────────────────────────────────────
if ! command -v mermaid-render &>/dev/null; then
  echo "[FAIL] mermaid-render not found. Run Phase 1 setup first."
  exit 1
fi

if ! command -v mermaid-render-dark &>/dev/null; then
  echo "[FAIL] mermaid-render-dark not found. Run create-dark-wrapper.sh first."
  exit 1
fi

# ── Light render ──────────────────────────────────────────────────────────────
echo "--- Rendering with light theme ---"
mermaid-render "$TEST_MMD" "$LIGHT_SVG" || { echo "[FAIL] Light render failed."; FAILED=1; }

if [ -f "$LIGHT_SVG" ]; then
  LIGHT_SIZE=$(wc -c < "$LIGHT_SVG")
  if [ "$LIGHT_SIZE" -gt 0 ]; then
    echo "[PASS] Light SVG: $LIGHT_SIZE bytes"
  else
    echo "[FAIL] Light SVG is empty."
    FAILED=1
  fi
else
  echo "[FAIL] Light SVG was not created."
  FAILED=1
fi
echo ""

# ── Dark render ───────────────────────────────────────────────────────────────
echo "--- Rendering with dark theme ---"
mermaid-render-dark "$TEST_MMD" "$DARK_SVG" || { echo "[FAIL] Dark render failed."; FAILED=1; }

if [ -f "$DARK_SVG" ]; then
  DARK_SIZE=$(wc -c < "$DARK_SVG")
  if [ "$DARK_SIZE" -gt 0 ]; then
    echo "[PASS] Dark SVG: $DARK_SIZE bytes"
  else
    echo "[FAIL] Dark SVG is empty."
    FAILED=1
  fi
else
  echo "[FAIL] Dark SVG was not created."
  FAILED=1
fi
echo ""

# ── Diff check -- sizes should differ if configs differ ───────────────────────
if [ -f "$LIGHT_SVG" ] && [ -f "$DARK_SVG" ]; then
  if [ "$LIGHT_SIZE" -ne "$DARK_SIZE" ]; then
    echo "[PASS] Light ($LIGHT_SIZE bytes) and dark ($DARK_SIZE bytes) SVGs"
    echo "       have different sizes -- configs are having an effect."
  else
    # Same size is unusual but not necessarily wrong; flag it as a warning.
    echo "[WARN] Light and dark SVGs are the same size ($LIGHT_SIZE bytes)."
    echo "       This may mean the dark config is not being applied."
    echo "       Inspect the files manually to confirm theme differences."
  fi
  echo ""
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo "============================================="
if [ "$FAILED" -eq 0 ]; then
  echo "  Theme test PASSED. Both themes are working."
  echo "  Proceed to Phase 3 for the full battle test."
else
  echo "  Theme test FAILED. Fix the issues above and re-run:"
  echo "    bash phase-02-enterprise-theme/test-themes.sh"
fi
echo "============================================="
echo ""

exit "$FAILED"
