#!/usr/bin/env bash
# create-vega-wrapper.sh
# Creates ~/bin/vegalite-render -- a convenience wrapper around vl2svg and vl2png.
#
# After running this script, you can render any Vega-Lite spec with:
#   vegalite-render my-chart.vl.json
#
# This produces:
#   my-chart.svg  (always -- uses vl2svg)
#   my-chart.png  (requires canvas -- uses vl2png at 3x scale)
#
# Usage:
#   ./create-vega-wrapper.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 10: Create vegalite-render wrapper ==="
echo ""

# ── Ensure ~/bin exists ───────────────────────────────────────────────────────
# ~/bin is a standard location for user-level scripts. Add it to PATH if needed.
mkdir -p "$HOME/bin"

# ── Write the wrapper script ──────────────────────────────────────────────────
WRAPPER_PATH="$HOME/bin/vegalite-render"

cat > "$WRAPPER_PATH" << 'WRAPPER_EOF'
#!/bin/bash
# vegalite-render
# Renders a Vega-Lite JSON spec to SVG and PNG.
#
# Usage:
#   vegalite-render <spec.vl.json>
#
# Outputs:
#   <spec>.svg   -- vector, infinite resolution
#   <spec>.png   -- raster at 3x scale (requires canvas npm package)

INPUT="$1"

# Validate input argument
if [ -z "$INPUT" ]; then
  echo "Usage: vegalite-render <spec.vl.json>"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "ERROR: File not found: $INPUT"
  exit 1
fi

# Strip the .vl.json extension to get the base name for outputs.
# Example: diagrams/tool-usage.vl.json -> diagrams/tool-usage
BASENAME="${INPUT%.vl.json}"

echo "Rendering: $INPUT"

# Render SVG (always works, no canvas dependency)
echo "  -> ${BASENAME}.svg"
vl2svg "$INPUT" "${BASENAME}.svg"

# Render PNG at 3x scale for high-DPI / print quality.
# -s 3 means 3x the declared spec dimensions.
# This fails silently if canvas is not installed -- check README for fix.
echo "  -> ${BASENAME}.png (3x scale)"
vl2png "$INPUT" "${BASENAME}.png" -s 3

echo "Done."
WRAPPER_EOF

# ── Make the wrapper executable ───────────────────────────────────────────────
chmod +x "$WRAPPER_PATH"

echo "Created: $WRAPPER_PATH"
echo ""

# ── Verify it is on PATH ──────────────────────────────────────────────────────
if command -v vegalite-render &>/dev/null; then
  echo "PASS: vegalite-render is on PATH."
else
  echo "WARN: $HOME/bin is not on your PATH yet."
  echo "  Add this line to ~/.bashrc (or ~/.zshrc) and reload your shell:"
  echo ""
  echo "    export PATH=\"\$HOME/bin:\$PATH\""
  echo ""
  echo "  Then run: source ~/.bashrc"
  echo ""
  echo "  After that, 'vegalite-render' will be available in any terminal."
fi

echo ""
echo "=== Wrapper created. Run test-vega.sh to verify. ==="
