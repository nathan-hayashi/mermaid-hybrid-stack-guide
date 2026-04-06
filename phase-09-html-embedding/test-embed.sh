#!/usr/bin/env bash
# test-embed.sh
# Verifies that diagram files were successfully copied to public/assets/
# and that the Astro build still passes with 0 errors.
#
# Usage:
#   ./test-embed.sh [ASTRO_PROJECT_DIR]
#
# Examples:
#   ./test-embed.sh ~/projects/my-portfolio
#   ./test-embed.sh                           # looks in current directory

# ── Load platform detection helpers ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# ── Configuration ─────────────────────────────────────────────────────────────
ASTRO_PROJECT_DIR="${1:-$(pwd)}"
ASSETS_DIR="$ASTRO_PROJECT_DIR/public/assets"

echo "=== Phase 9: Verify Embed ==="
echo ""
echo "Checking Astro project: $ASTRO_PROJECT_DIR"
echo "Checking assets dir   : $ASSETS_DIR"
echo ""

PASS=true

# ── Check that the assets directory exists ────────────────────────────────────
if [ ! -d "$ASSETS_DIR" ]; then
  echo "FAIL: public/assets/ directory not found."
  echo "  Run embed-diagrams.sh first."
  PASS=false
else
  echo "PASS: public/assets/ directory exists."
fi

# ── Count SVG files ───────────────────────────────────────────────────────────
SVG_COUNT=0
for f in "$ASSETS_DIR"/*.svg; do
  [ -f "$f" ] || continue
  SVG_COUNT=$((SVG_COUNT + 1))
done

# ── Count PNG files ───────────────────────────────────────────────────────────
PNG_COUNT=0
for f in "$ASSETS_DIR"/*.png; do
  [ -f "$f" ] || continue
  PNG_COUNT=$((PNG_COUNT + 1))
done

echo "Found: $SVG_COUNT SVG(s), $PNG_COUNT PNG(s) in public/assets/"

if [ "$SVG_COUNT" -eq 0 ] && [ "$PNG_COUNT" -eq 0 ]; then
  echo "WARN: No diagram files found. Did embed-diagrams.sh run successfully?"
  PASS=false
else
  echo "PASS: Diagram files present."
fi

# ── Optional: run npm run build ───────────────────────────────────────────────
# Only attempt a build if package.json exists in the Astro project directory.
# The build verifies Astro can process all pages without errors.
if [ -f "$ASTRO_PROJECT_DIR/package.json" ]; then
  echo ""
  echo "Running npm run build in: $ASTRO_PROJECT_DIR"
  echo "(This may take 30-60 seconds for a typical Astro project)"
  echo ""
  # Run build from the project directory; capture exit code
  (cd "$ASTRO_PROJECT_DIR" && npm run build)
  BUILD_EXIT=$?

  if [ "$BUILD_EXIT" -eq 0 ]; then
    echo ""
    echo "PASS: npm run build completed with 0 errors."
  else
    echo ""
    echo "FAIL: npm run build exited with code $BUILD_EXIT."
    echo "  Check the output above for error details."
    PASS=false
  fi
else
  echo ""
  echo "SKIP: No package.json found in $ASTRO_PROJECT_DIR -- skipping build check."
  echo "  If this is your Astro project root, navigate there and run: npm run build"
fi

# ── Final result ──────────────────────────────────────────────────────────────
echo ""
if [ "$PASS" = true ]; then
  echo "=== All checks passed. Phase 9 complete. ==="
else
  echo "=== One or more checks failed. Review output above. ==="
  exit 1
fi
