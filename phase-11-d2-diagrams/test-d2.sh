#!/usr/bin/env bash
# test-d2.sh
# Creates a simple D2 diagram with nested containers, renders it to SVG and PNG,
# and verifies the outputs exist.
#
# Usage:
#   ./test-d2.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 11: Test D2 Rendering ==="
echo ""

PASS=true

# ── Check that d2 is available ────────────────────────────────────────────────
if ! command -v d2 &>/dev/null; then
  echo "ERROR: d2 not found on PATH."
  echo "  Run install-d2.sh first."
  exit 1
fi
echo "PASS: d2 found: $(which d2)"
d2 --version

# ── Create a temporary working directory ──────────────────────────────────────
TEST_DIR="$(mktemp -d)"
TEST_D2="$TEST_DIR/test-arch.d2"
TEST_SVG="$TEST_DIR/test-arch.svg"
TEST_PNG="$TEST_DIR/test-arch.png"

echo ""
echo "Working in temp dir: $TEST_DIR"
echo ""

# ── Write a minimal D2 diagram with nested containers ─────────────────────────
# This mirrors the structure of configs/d2-sample.d2.example.
# Two nested containers with an edge between them.
cat > "$TEST_D2" << 'D2_EOF'
direction: down

config: {
  label: "Configuration Layer"
  style: {
    fill: "#F0F4FC"
    stroke: "#2C5F8A"
  }

  claude-md: "CLAUDE.md"
  rules: "Rules Files"
  memory: "Auto Memory"
}

enforce: {
  label: "Enforcement Layer"
  style: {
    fill: "#E8F5E9"
    stroke: "#2E7D32"
  }

  hooks: "Hooks System"
  router: "Threshold Router"
}

config -> enforce: "feeds into"
D2_EOF

echo "Wrote test diagram: $TEST_D2"

# ── Render to SVG ─────────────────────────────────────────────────────────────
echo ""
echo "Rendering SVG with --layout=elk..."
d2 --layout=elk "$TEST_D2" "$TEST_SVG"
SVG_EXIT=$?

if [ "$SVG_EXIT" -eq 0 ] && [ -f "$TEST_SVG" ]; then
  SVG_SIZE=$(wc -c < "$TEST_SVG")
  echo "PASS: SVG created ($SVG_SIZE bytes): $TEST_SVG"
else
  echo "FAIL: SVG rendering failed (exit code $SVG_EXIT)."
  PASS=false
fi

# ── Render to PNG ─────────────────────────────────────────────────────────────
echo ""
echo "Rendering PNG with --layout=elk --scale 3..."
echo "(Requires Playwright + libasound2t64 on WSL 2)"
d2 --layout=elk "$TEST_D2" "$TEST_PNG" --scale 3
PNG_EXIT=$?

if [ "$PNG_EXIT" -eq 0 ] && [ -f "$TEST_PNG" ]; then
  PNG_SIZE=$(wc -c < "$TEST_PNG")
  echo "PASS: PNG created ($PNG_SIZE bytes): $TEST_PNG"
else
  echo "WARN: PNG rendering failed (exit code $PNG_EXIT)."
  echo "  This is expected if libasound2t64 is missing."
  echo "  Fix: sudo apt-get install -y libasound2t64"
fi

# ── Clean up ──────────────────────────────────────────────────────────────────
rm -rf "$TEST_DIR"
echo ""
echo "Temp files cleaned up."

# ── Final result ──────────────────────────────────────────────────────────────
echo ""
if [ "$PASS" = true ]; then
  echo "=== D2 test passed. Phase 11 complete. ==="
  echo ""
  echo "Next step: write your own diagrams (see configs/d2-sample.d2.example)"
  echo "and render with: d2-render my-diagram.d2"
else
  echo "=== Test failed. Check output above for details. ==="
  exit 1
fi
