#!/usr/bin/env bash
# create-dark-wrapper.sh
# Creates ~/bin/mermaid-render-dark -- a wrapper that renders Mermaid diagrams
# using the dark enterprise theme with a transparent background.
#
# Use this wrapper when producing SVGs for embedding in dark-themed
# documentation, slide decks, or web pages.
#
# The --user flag is CRITICAL here too: same reason as mermaid-render.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 2 -- Dark Theme Wrapper"
echo "============================================="
echo ""

DARK_CONFIG="$HOME/.config/mermaid/config-dark.json"
WRAPPER="$HOME/bin/mermaid-render-dark"

# ── Verify the dark config exists ─────────────────────────────────────────────
if [ ! -f "$DARK_CONFIG" ]; then
  echo "[FAIL] Dark config not found: $DARK_CONFIG"
  echo "  Run create-theme.sh first."
  exit 1
fi

mkdir -p "$HOME/bin"

# ── Write the wrapper script ──────────────────────────────────────────────────
cat > "$WRAPPER" << 'WRAPPER_SCRIPT'
#!/usr/bin/env bash
# mermaid-render-dark -- renders with dark enterprise theme + transparent bg
#
# Usage: mermaid-render-dark input.mmd [output.svg] [extra mmdc args...]

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: mermaid-render-dark <input.mmd> [output.svg] [extra args...]"
  exit 1
fi

INPUT_FILE="$1"
shift

INPUT_ABS="$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")"
INPUT_DIR="$(dirname "$INPUT_ABS")"
INPUT_NAME="$(basename "$INPUT_ABS")"

if [ $# -ge 1 ] && [[ "$1" != -* ]]; then
  OUTPUT_FILE="$1"
  shift
  OUTPUT_NAME="$(basename "$OUTPUT_FILE")"
else
  OUTPUT_NAME="${INPUT_NAME%.*}.dark.svg"
fi

EXTRA_ARGS="$*"

DARK_CONFIG="$HOME/.config/mermaid/config-dark.json"

if [ ! -f "$DARK_CONFIG" ]; then
  echo "[FAIL] Dark config not found: $DARK_CONFIG"
  echo "  Run phase-02-enterprise-theme/create-theme.sh to create it."
  exit 1
fi

# --user "$(id -u):$(id -g)" prevents root-owned output files (Error #1).
# -b transparent makes the SVG background clear for dark-bg embedding.
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$INPUT_DIR:/data" \
  -v "$DARK_CONFIG:/config-dark.json" \
  minlag/mermaid-cli \
  -i "/data/$INPUT_NAME" \
  -o "/data/$OUTPUT_NAME" \
  -c /config-dark.json \
  -b transparent \
  $EXTRA_ARGS

echo "[DONE] Dark output: $INPUT_DIR/$OUTPUT_NAME"
WRAPPER_SCRIPT

chmod +x "$WRAPPER"
echo "[PASS] Created dark wrapper: $WRAPPER"
echo ""

echo "============================================="
echo "  Dark wrapper ready."
echo "  Usage: mermaid-render-dark diagram.mmd"
echo "  Next: run test-themes.sh to verify both wrappers."
echo "============================================="
echo ""
