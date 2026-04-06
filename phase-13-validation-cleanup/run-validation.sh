#!/usr/bin/env bash
# run-validation.sh
# Counts diagram source files and their rendered outputs, then reports a summary.
# Helps confirm that every source file has been rendered before cleanup.
#
# Usage:
#   ./run-validation.sh [DIAGRAMS_DIR]
#   ./run-validation.sh              # defaults to ./diagrams in current dir

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 13: Validation Report ==="
echo ""

# ── Configuration ─────────────────────────────────────────────────────────────
DIAGRAMS_DIR="${1:-$(pwd)/diagrams}"

echo "Diagrams directory: $DIAGRAMS_DIR"
echo ""

if [ ! -d "$DIAGRAMS_DIR" ]; then
  echo "ERROR: Directory not found: $DIAGRAMS_DIR"
  echo "  Pass the correct path as an argument: ./run-validation.sh /path/to/diagrams"
  exit 1
fi

# ── Count Mermaid sources and outputs ─────────────────────────────────────────
MMD_SOURCES=0
MMD_SVG=0
MMD_PNG=0
MMD_MISSING_SVG=()

for f in "$DIAGRAMS_DIR"/*.mmd; do
  [ -f "$f" ] || continue
  MMD_SOURCES=$((MMD_SOURCES + 1))
  base="${f%.mmd}"
  if [ -f "${base}.svg" ]; then
    MMD_SVG=$((MMD_SVG + 1))
  else
    MMD_MISSING_SVG+=("$(basename "$f")")
  fi
  if [ -f "${base}.png" ]; then
    MMD_PNG=$((MMD_PNG + 1))
  fi
done

# ── Count Vega-Lite sources and outputs ───────────────────────────────────────
VL_SOURCES=0
VL_SVG=0
VL_PNG=0
VL_MISSING_SVG=()

for f in "$DIAGRAMS_DIR"/*.vl.json; do
  [ -f "$f" ] || continue
  VL_SOURCES=$((VL_SOURCES + 1))
  base="${f%.vl.json}"
  if [ -f "${base}.svg" ]; then
    VL_SVG=$((VL_SVG + 1))
  else
    VL_MISSING_SVG+=("$(basename "$f")")
  fi
  if [ -f "${base}.png" ]; then
    VL_PNG=$((VL_PNG + 1))
  fi
done

# ── Count D2 sources and outputs ──────────────────────────────────────────────
D2_SOURCES=0
D2_SVG=0
D2_PNG=0
D2_MISSING_SVG=()

for f in "$DIAGRAMS_DIR"/*.d2; do
  [ -f "$f" ] || continue
  D2_SOURCES=$((D2_SOURCES + 1))
  base="${f%.d2}"
  if [ -f "${base}.svg" ]; then
    D2_SVG=$((D2_SVG + 1))
  else
    D2_MISSING_SVG+=("$(basename "$f")")
  fi
  if [ -f "${base}.png" ]; then
    D2_PNG=$((D2_PNG + 1))
  fi
done

# ── Print report ──────────────────────────────────────────────────────────────
TOTAL_SOURCES=$((MMD_SOURCES + VL_SOURCES + D2_SOURCES))
TOTAL_SVG=$((MMD_SVG + VL_SVG + D2_SVG))
TOTAL_PNG=$((MMD_PNG + VL_PNG + D2_PNG))

echo "┌──────────────────────────────────────────────────────┐"
echo "│              Diagram Validation Summary               │"
echo "├─────────────┬──────────┬──────────────┬──────────────┤"
echo "│ Format      │ Sources  │ SVGs         │ PNGs         │"
echo "├─────────────┼──────────┼──────────────┼──────────────┤"
printf "│ %-11s │ %-8s │ %-12s │ %-12s │\n" "Mermaid"   "$MMD_SOURCES" "$MMD_SVG / $MMD_SOURCES" "$MMD_PNG / $MMD_SOURCES"
printf "│ %-11s │ %-8s │ %-12s │ %-12s │\n" "Vega-Lite" "$VL_SOURCES"  "$VL_SVG / $VL_SOURCES"   "$VL_PNG / $VL_SOURCES"
printf "│ %-11s │ %-8s │ %-12s │ %-12s │\n" "D2"        "$D2_SOURCES"  "$D2_SVG / $D2_SOURCES"   "$D2_PNG / $D2_SOURCES"
echo "├─────────────┼──────────┼──────────────┼──────────────┤"
printf "│ %-11s │ %-8s │ %-12s │ %-12s │\n" "TOTAL" "$TOTAL_SOURCES" "$TOTAL_SVG / $TOTAL_SOURCES" "$TOTAL_PNG / $TOTAL_SOURCES"
echo "└─────────────┴──────────┴──────────────┴──────────────┘"
echo ""

# ── Report missing SVGs ───────────────────────────────────────────────────────
ALL_MISSING=("${MMD_MISSING_SVG[@]}" "${VL_MISSING_SVG[@]}" "${D2_MISSING_SVG[@]}")

if [ "${#ALL_MISSING[@]}" -gt 0 ]; then
  echo "Sources missing SVG output:"
  for f in "${ALL_MISSING[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Run render-all-diagrams to generate missing outputs:"
  echo "  render-all-diagrams $DIAGRAMS_DIR"
  echo ""
fi

# ── Check tool availability ───────────────────────────────────────────────────
echo "Tool availability:"

for tool in mermaid-render maid vegalite-render d2-render render-all-diagrams; do
  if command -v "$tool" &>/dev/null; then
    echo "  PASS  $tool"
  else
    echo "  MISS  $tool  (not on PATH)"
  fi
done

echo ""

# ── Final verdict ─────────────────────────────────────────────────────────────
if [ "$TOTAL_SOURCES" -eq 0 ]; then
  echo "WARN: No diagram source files found in: $DIAGRAMS_DIR"
  echo "  Add .mmd, .vl.json, or .d2 files, then re-run."
elif [ "$TOTAL_SVG" -eq "$TOTAL_SOURCES" ]; then
  echo "=== All sources have rendered outputs. Validation PASSED. ==="
else
  MISSING_COUNT=$(( TOTAL_SOURCES - TOTAL_SVG ))
  echo "WARN: $MISSING_COUNT source(s) have no SVG output."
  echo "  Run: render-all-diagrams $DIAGRAMS_DIR"
fi
