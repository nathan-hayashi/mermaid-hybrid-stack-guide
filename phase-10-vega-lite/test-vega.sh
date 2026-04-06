#!/usr/bin/env bash
# test-vega.sh
# Creates a simple Vega-Lite bar chart spec, renders it to SVG and PNG,
# and verifies the outputs exist.
#
# Usage:
#   ./test-vega.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 10: Test Vega-Lite Rendering ==="
echo ""

PASS=true

# ── Check that vl2svg is available ────────────────────────────────────────────
if ! command -v vl2svg &>/dev/null; then
  echo "ERROR: vl2svg not found on PATH."
  echo "  Run install-vega.sh first, then add npm global bin to PATH."
  exit 1
fi
echo "PASS: vl2svg found: $(which vl2svg)"

# ── Create a temporary working directory ──────────────────────────────────────
TEST_DIR="$(mktemp -d)"
TEST_SPEC="$TEST_DIR/test-chart.vl.json"
TEST_SVG="$TEST_DIR/test-chart.svg"
TEST_PNG="$TEST_DIR/test-chart.png"

echo "Working in temp dir: $TEST_DIR"
echo ""

# ── Write a minimal Vega-Lite bar chart spec ──────────────────────────────────
# This spec produces a simple bar chart showing diagram tool usage counts.
# The structure mirrors configs/vega-spec.example for consistency.
cat > "$TEST_SPEC" << 'SPEC_EOF'
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Vega-Lite test chart -- diagram tool usage",
  "width": 400,
  "height": 300,
  "data": {
    "values": [
      {"category": "Mermaid",   "count": 6},
      {"category": "Vega-Lite", "count": 2},
      {"category": "D2",        "count": 1},
      {"category": "Markdown",  "count": 1}
    ]
  },
  "mark": "bar",
  "encoding": {
    "x": {"field": "category", "type": "nominal",      "title": "Diagram Tool"},
    "y": {"field": "count",    "type": "quantitative", "title": "Number of Diagrams"},
    "color": {"field": "category", "type": "nominal", "legend": null}
  }
}
SPEC_EOF

echo "Wrote test spec: $TEST_SPEC"

# ── Render to SVG ─────────────────────────────────────────────────────────────
echo ""
echo "Rendering SVG..."
vl2svg "$TEST_SPEC" "$TEST_SVG"
SVG_EXIT=$?

if [ "$SVG_EXIT" -eq 0 ] && [ -f "$TEST_SVG" ]; then
  SVG_SIZE=$(wc -c < "$TEST_SVG")
  echo "PASS: SVG created ($SVG_SIZE bytes): $TEST_SVG"
else
  echo "FAIL: SVG rendering failed (exit code $SVG_EXIT)."
  PASS=false
fi

# ── Render to PNG (optional -- requires canvas) ───────────────────────────────
echo ""
echo "Rendering PNG (requires canvas npm package)..."
vl2png "$TEST_SPEC" "$TEST_PNG" -s 3
PNG_EXIT=$?

if [ "$PNG_EXIT" -eq 0 ] && [ -f "$TEST_PNG" ]; then
  PNG_SIZE=$(wc -c < "$TEST_PNG")
  echo "PASS: PNG created ($PNG_SIZE bytes): $TEST_PNG"
else
  echo "WARN: PNG rendering failed (exit code $PNG_EXIT)."
  echo "  This is expected if the canvas package is not installed."
  echo "  SVG rendering is sufficient to continue."
fi

# ── Clean up ──────────────────────────────────────────────────────────────────
# Remove temp files after verification. Comment out if you want to inspect them.
rm -rf "$TEST_DIR"
echo ""
echo "Temp files cleaned up."

# ── Final result ──────────────────────────────────────────────────────────────
echo ""
if [ "$PASS" = true ]; then
  echo "=== Vega-Lite test passed. Phase 10 complete. ==="
  echo ""
  echo "Next step: write your own specs (see configs/vega-spec.example)"
  echo "and render with: vegalite-render my-chart.vl.json"
else
  echo "=== Test failed. Check output above for details. ==="
  exit 1
fi
