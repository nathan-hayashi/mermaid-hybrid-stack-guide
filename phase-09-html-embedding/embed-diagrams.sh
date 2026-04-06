#!/usr/bin/env bash
# embed-diagrams.sh
# Copies rendered SVG and PNG diagram files from a diagrams/ source directory
# into the public/assets/ directory of an Astro project.
#
# Usage:
#   ./embed-diagrams.sh [DIAGRAMS_DIR] [ASTRO_PROJECT_DIR]
#
# Examples:
#   ./embed-diagrams.sh ~/projects/diagrams ~/projects/my-portfolio
#   ./embed-diagrams.sh                          # uses defaults below

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# ── Configuration ─────────────────────────────────────────────────────────────
# Default paths -- override by passing arguments or editing these variables
DIAGRAMS_DIR="${1:-$(pwd)/diagrams}"
ASTRO_PROJECT_DIR="${2:-$(pwd)}"
DEST_DIR="$ASTRO_PROJECT_DIR/public/assets"

echo "=== Phase 9: Embed Diagrams into Astro public/ ==="
echo ""
echo "Source diagrams : $DIAGRAMS_DIR"
echo "Astro project   : $ASTRO_PROJECT_DIR"
echo "Destination     : $DEST_DIR"
echo ""

# ── Validate source directory ─────────────────────────────────────────────────
if [ ! -d "$DIAGRAMS_DIR" ]; then
  echo "ERROR: Diagrams directory not found: $DIAGRAMS_DIR"
  echo "  Create it or pass the correct path as the first argument."
  exit 1
fi

# ── Create destination directory if it doesn't exist ─────────────────────────
mkdir -p "$DEST_DIR"

# ── Copy SVG files ────────────────────────────────────────────────────────────
SVG_COUNT=0
for svg_file in "$DIAGRAMS_DIR"/*.svg; do
  # The glob returns the pattern literally if no files match -- skip that case
  [ -f "$svg_file" ] || continue
  filename="$(basename "$svg_file")"
  cp "$svg_file" "$DEST_DIR/$filename"
  echo "  [SVG] Copied: $filename"
  SVG_COUNT=$((SVG_COUNT + 1))
done

# ── Copy PNG files ────────────────────────────────────────────────────────────
PNG_COUNT=0
for png_file in "$DIAGRAMS_DIR"/*.png; do
  [ -f "$png_file" ] || continue
  filename="$(basename "$png_file")"
  cp "$png_file" "$DEST_DIR/$filename"
  echo "  [PNG] Copied: $filename"
  PNG_COUNT=$((PNG_COUNT + 1))
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Done. Copied $SVG_COUNT SVG(s) and $PNG_COUNT PNG(s) to: $DEST_DIR"
echo ""

# ── Usage reminder: Astro img tag pattern ─────────────────────────────────────
# In your Astro components, reference the copied assets like this:
#
#   <img
#     src="/assets/threshold-escalation.svg"
#     alt="Threshold Escalation Flowchart"
#     width="800"
#     loading="lazy"
#   />
#
# Key points:
#   - src starts with /assets/ (maps to public/assets/ at build time)
#   - Always provide a descriptive alt attribute for accessibility and SEO
#   - Use loading="lazy" for diagrams below the fold
#   - SVGs scale infinitely -- no need to set height if width is set
#   - For PNGs, set both width and height to reserve layout space

echo "Next step: reference assets in your Astro components."
echo "See configs/astro-embed.example for img tag patterns."
