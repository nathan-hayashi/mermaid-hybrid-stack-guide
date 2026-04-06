#!/usr/bin/env bash
# render-and-compare.sh
# Renders the threshold escalation flowchart to both SVG (light theme) and
# PNG at 3x scale (for crisp display on retina / high-DPI screens).
# After rendering, prints instructions for visual comparison with the PDF.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 3 -- Render and Compare"
echo "============================================="
echo ""

DIAGRAMS_DIR="$SCRIPT_DIR/diagrams"
MMD_FILE="$DIAGRAMS_DIR/threshold-escalation.mmd"
SVG_FILE="$DIAGRAMS_DIR/threshold-escalation.svg"
PNG_FILE="$DIAGRAMS_DIR/threshold-escalation.png"

FAILED=0

# ── Verify source file exists ─────────────────────────────────────────────────
if [ ! -f "$MMD_FILE" ]; then
  echo "[FAIL] Diagram source not found: $MMD_FILE"
  echo "  Run create-test-diagram.sh first."
  exit 1
fi

echo "[INFO] Source: $MMD_FILE"
echo ""

# ── Verify mermaid-render is available ────────────────────────────────────────
if ! command -v mermaid-render &>/dev/null; then
  echo "[FAIL] mermaid-render not found. Complete Phase 1 first."
  exit 1
fi

# ── Render 1: SVG (light theme, enterprise config) ───────────────────────────
echo "--- Rendering SVG (light theme) ---"
mermaid-render "$MMD_FILE" "$SVG_FILE"

if [ -f "$SVG_FILE" ] && [ "$(wc -c < "$SVG_FILE")" -gt 0 ]; then
  SVG_SIZE=$(wc -c < "$SVG_FILE")
  echo "[PASS] SVG rendered: $SVG_FILE ($SVG_SIZE bytes)"
else
  echo "[FAIL] SVG render failed or produced empty file."
  FAILED=1
fi
echo ""

# ── Render 2: PNG at 3x scale (high-DPI, good for PDF comparison) ────────────
# The -s 3 flag scales the output to 3x resolution. Useful for side-by-side
# comparison with the runbook PDF at high zoom levels.
echo "--- Rendering PNG at 3x scale ---"
mermaid-render "$MMD_FILE" "$PNG_FILE" -s 3

if [ -f "$PNG_FILE" ] && [ "$(wc -c < "$PNG_FILE")" -gt 0 ]; then
  PNG_SIZE=$(wc -c < "$PNG_FILE")
  echo "[PASS] PNG rendered: $PNG_FILE ($PNG_SIZE bytes)"
else
  echo "[FAIL] PNG render failed or produced empty file."
  FAILED=1
fi
echo ""

# ── Visual comparison instructions ────────────────────────────────────────────
echo "============================================="
echo "  VISUAL COMPARISON CHECKLIST"
echo "  Open both the PNG and the runbook PDF and check:"
echo ""
echo "  [ ] START node at top, round-rectangle shape"
echo "  [ ] PARSE node below START"
echo "  [ ] SCORE diamond fans out to 4 scoring nodes (S1-S4)"
echo "  [ ] All 4 scoring nodes feed into SUM"
echo "  [ ] SUM feeds into ROUTE diamond"
echo "  [ ] ROUTE has 3 output edges with correct threshold labels:"
echo "        Score <= 4  →  TIER 1"
echo "        Score 5-8   →  TIER 2"
echo "        Score >= 9  →  TIER 3"
echo "  [ ] No overlapping nodes"
echo "  [ ] No truncated labels"
echo "  [ ] <br/> in labels renders as actual line breaks (not literal text)"
echo "============================================="
echo ""

if [ "$FAILED" -eq 0 ]; then
  echo "[PASS] Both renders succeeded. Do the visual check above."
  echo "       If layout matches the PDF, Phase 3 is complete."
  echo "       The full stack (Docker + config + wrapper) is validated."
else
  echo "[FAIL] One or more renders failed. Fix issues above and re-run:"
  echo "  bash phase-03-battle-test/render-and-compare.sh"
  exit 1
fi
echo ""
