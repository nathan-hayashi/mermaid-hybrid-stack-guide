#!/usr/bin/env bash
# create-batch-script.sh
# Creates ~/bin/render-all-diagrams -- a batch renderer that processes every
# Mermaid (.mmd), Vega-Lite (.vl.json), and D2 (.d2) file in a directory.
#
# After running this script, batch-render an entire diagrams directory with:
#   render-all-diagrams /path/to/diagrams
#   render-all-diagrams              # defaults to ./diagrams in current dir
#
# Usage:
#   ./create-batch-script.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 13: Create render-all-diagrams batch script ==="
echo ""

# ── Ensure ~/bin exists ───────────────────────────────────────────────────────
mkdir -p "$HOME/bin"

# ── Write the batch render script ─────────────────────────────────────────────
BATCH_PATH="$HOME/bin/render-all-diagrams"

cat > "$BATCH_PATH" << 'BATCH_EOF'
#!/bin/bash
# render-all-diagrams
# Batch-renders every diagram source file in a directory.
# Supports Mermaid (.mmd), Vega-Lite (.vl.json), and D2 (.d2) formats.
#
# Usage:
#   render-all-diagrams [DIRECTORY]
#   render-all-diagrams              # defaults to ./diagrams
#
# Prerequisites:
#   - mermaid-render  (from Phase 1: ~/bin/mermaid-render)
#   - maid            (from Phase 4: npm install -g @mermaid-js/mermaid-cli-linter or equivalent)
#   - vegalite-render (from Phase 10: ~/bin/vegalite-render)
#   - d2-render       (from Phase 11: ~/bin/d2-render)

DIR="${1:-$(pwd)/diagrams}"

echo "Rendering all diagrams in: $DIR"
echo ""

# Track counts for the summary
MMD_COUNT=0
VL_COUNT=0
D2_COUNT=0
FAIL_COUNT=0

# ── Mermaid files (.mmd) ──────────────────────────────────────────────────────
for f in "$DIR"/*.mmd; do
  # Skip if glob returns no matches (the literal pattern string)
  [ -f "$f" ] || continue
  echo "  [Mermaid] $f"

  # Validate syntax first with maid (exit code 0 = valid)
  # 2>/dev/null suppresses maid output; we only care about success/failure
  maid "$f" 2>/dev/null

  if [ $? -eq 0 ]; then
    # Render to SVG
    mermaid-render "$f" "${f%.mmd}.svg" && \
    # Render to PNG at 3x scale
    mermaid-render "$f" "${f%.mmd}.png" -s 3
    MMD_COUNT=$((MMD_COUNT + 1))
  else
    echo "    WARN: Syntax validation failed for $f -- skipping render"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

# ── Vega-Lite files (.vl.json) ────────────────────────────────────────────────
for f in "$DIR"/*.vl.json; do
  [ -f "$f" ] || continue
  echo "  [Vega-Lite] $f"
  vegalite-render "$f"
  VL_COUNT=$((VL_COUNT + 1))
done

# ── D2 files (.d2) ────────────────────────────────────────────────────────────
for f in "$DIR"/*.d2; do
  [ -f "$f" ] || continue
  echo "  [D2] $f"
  d2-render "$f"
  D2_COUNT=$((D2_COUNT + 1))
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "=== Batch render complete ==="
echo "  Mermaid rendered : $MMD_COUNT"
echo "  Vega-Lite rendered: $VL_COUNT"
echo "  D2 rendered      : $D2_COUNT"
echo "  Failed (syntax)  : $FAIL_COUNT"
BATCH_EOF

# ── Make the batch script executable ─────────────────────────────────────────
chmod +x "$BATCH_PATH"

echo "Created: $BATCH_PATH"
echo ""

# ── Verify it is on PATH ──────────────────────────────────────────────────────
if command -v render-all-diagrams &>/dev/null; then
  echo "PASS: render-all-diagrams is on PATH."
else
  echo "WARN: $HOME/bin is not on your PATH yet."
  echo "  Add this to ~/.bashrc (or ~/.zshrc):"
  echo "    export PATH=\"\$HOME/bin:\$PATH\""
  echo "  Then: source ~/.bashrc"
fi

echo ""
echo "=== Batch script created. Run run-validation.sh next. ==="
