#!/usr/bin/env bash
# create-batch-render.sh
# Creates ~/bin/render-all-diagrams -- a script that batch-renders every .mmd
# file in the current directory to SVG (for web/GitHub) and PNG at 3x scale
# (for PDF/print use).
#
# Why 3x?
#   mermaid-cli renders at 1x by default (~96 DPI equivalent). At 3x, the PNG
#   is ~288 DPI equivalent, which stays sharp when embedded in a PDF and viewed
#   at any zoom level. File sizes are larger but still much smaller than
#   comparable vector-converted rasters.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

mkdir -p "$HOME/bin"
SCRIPT="$HOME/bin/render-all-diagrams"

echo "==> Creating $SCRIPT ..."

cat > "$SCRIPT" << 'INNEREOF'
#!/usr/bin/env bash
# render-all-diagrams
# Batch-renders all .mmd files in the current directory (or a specified dir)
# to SVG and PNG at 3x scale.
#
# Usage:
#   render-all-diagrams              # renders *.mmd in current directory
#   render-all-diagrams ./diagrams   # renders *.mmd in specified directory

set -euo pipefail

TARGET_DIR="${1:-.}"

# Validate the target directory exists.
if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Directory not found: $TARGET_DIR" >&2
    exit 1
fi

# Expand to absolute path so error messages are unambiguous.
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Count .mmd files to process.
MMD_FILES=("$TARGET_DIR"/*.mmd)
if [ ! -f "${MMD_FILES[0]}" ]; then
    echo "No .mmd files found in: $TARGET_DIR"
    exit 0
fi

TOTAL="${#MMD_FILES[@]}"
DONE=0
ERRORS=0

echo "==> Rendering $TOTAL diagram(s) in: $TARGET_DIR"
echo ""

for f in "${MMD_FILES[@]}"; do
    BASE="${f%.mmd}"
    NAME="$(basename "$f")"

    echo "--> $NAME"

    # SVG: vector output for web and GitHub embedding.
    if mermaid-render "$f" "${BASE}.svg" 2>/dev/null; then
        echo "    SVG: OK"
    else
        echo "    SVG: FAILED" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # PNG at 3x scale: raster output for PDF/print pipelines.
    if mermaid-render "$f" "${BASE}.png" -s 3 2>/dev/null; then
        echo "    PNG (3x): OK"
    else
        echo "    PNG (3x): FAILED" >&2
        ERRORS=$((ERRORS + 1))
    fi

    DONE=$((DONE + 1))
    echo ""
done

echo "================================"
echo "Rendered: $DONE / $TOTAL diagrams"
if [ "$ERRORS" -gt 0 ]; then
    echo "Errors:   $ERRORS (check output above)"
    exit 1
fi
echo "================================"
INNEREOF

chmod +x "$SCRIPT"
echo "    Created: $SCRIPT"
echo ""
echo "==> Usage:"
echo "    render-all-diagrams               # current directory"
echo "    render-all-diagrams ./diagrams    # specific directory"
