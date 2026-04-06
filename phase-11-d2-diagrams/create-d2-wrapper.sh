#!/usr/bin/env bash
# create-d2-wrapper.sh
# Creates ~/bin/d2-render -- a convenience wrapper around the d2 CLI.
#
# After running this script, render any D2 diagram with:
#   d2-render my-diagram.d2
#
# This produces:
#   my-diagram.svg  (always)
#   my-diagram.png  (requires Playwright + libasound2t64, at 3x scale)
#
# IMPORTANT: Always uses --layout=elk (free, bundled with D2).
# Never uses TALA (~$240/yr). See Phase 11 README for details.
#
# Usage:
#   ./create-d2-wrapper.sh

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "=== Phase 11: Create d2-render wrapper ==="
echo ""

# ── Ensure ~/bin exists ───────────────────────────────────────────────────────
mkdir -p "$HOME/bin"

# ── Write the wrapper script ──────────────────────────────────────────────────
WRAPPER_PATH="$HOME/bin/d2-render"

cat > "$WRAPPER_PATH" << 'WRAPPER_EOF'
#!/bin/bash
# d2-render
# Renders a D2 diagram to SVG and PNG using the ELK layout engine.
#
# Usage:
#   d2-render <diagram.d2>
#
# Outputs:
#   <diagram>.svg  -- vector, infinite resolution (works immediately)
#   <diagram>.png  -- raster at 3x scale (requires Playwright + libasound2t64)
#
# IMPORTANT: Always uses --layout=elk (free). Never use TALA (~$240/yr).

INPUT="$1"

# Validate input argument
if [ -z "$INPUT" ]; then
  echo "Usage: d2-render <diagram.d2>"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "ERROR: File not found: $INPUT"
  exit 1
fi

# Strip the .d2 extension to get the base name for outputs.
# Example: diagrams/system-arch.d2 -> diagrams/system-arch
BASENAME="${INPUT%.d2}"

echo "Rendering: $INPUT"

# Render SVG using ELK layout engine.
# --layout=elk is free and bundled with D2. Always use this.
echo "  -> ${BASENAME}.svg"
d2 --layout=elk "$INPUT" "${BASENAME}.svg"

# Render PNG at 3x scale for high-DPI / print quality.
# --scale 3 multiplies the output pixel dimensions by 3.
# Requires Playwright + Chromium internals; may fail without libasound2t64.
echo "  -> ${BASENAME}.png (3x scale)"
d2 --layout=elk "$INPUT" "${BASENAME}.png" --scale 3

echo "Done."
WRAPPER_EOF

# ── Make the wrapper executable ───────────────────────────────────────────────
chmod +x "$WRAPPER_PATH"

echo "Created: $WRAPPER_PATH"
echo ""

# ── Verify it is on PATH ──────────────────────────────────────────────────────
if command -v d2-render &>/dev/null; then
  echo "PASS: d2-render is on PATH."
else
  echo "WARN: $HOME/bin is not on your PATH yet."
  echo "  Add this line to ~/.bashrc (or ~/.zshrc) and reload your shell:"
  echo ""
  echo "    export PATH=\"\$HOME/bin:\$PATH\""
  echo ""
  echo "  Then run: source ~/.bashrc"
fi

echo ""
echo "=== Wrapper created. Run test-d2.sh to verify. ==="
