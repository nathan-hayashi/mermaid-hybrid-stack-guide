#!/usr/bin/env bash
# install-mermaid.sh
# Pulls the mermaid-cli Docker image and creates a ~/bin/mermaid-render wrapper
# script that you can call from anywhere.
#
# The --user flag in the wrapper is CRITICAL: without it, files written by the
# container are owned by root, causing "EACCES: permission denied" errors.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 1 -- Mermaid CLI Install"
echo "============================================="
echo ""

# ── Step 1: Pull the Docker image ─────────────────────────────────────────────
# This is a ~400 MB download. Subsequent runs skip the download if the image
# is already present (Docker caches layers).
echo "[INFO] Pulling minlag/mermaid-cli Docker image (~400 MB first run)..."
docker pull minlag/mermaid-cli
echo "[PASS] Image pulled."
echo ""

# ── Step 2: Create ~/bin directory ────────────────────────────────────────────
# ~/bin is a standard location for personal scripts on Linux/WSL 2.
mkdir -p "$HOME/bin"
echo "[INFO] ~/bin directory ready."

# ── Step 3: Create the mermaid-render wrapper script ──────────────────────────
# This wrapper translates a simple "mermaid-render input.mmd output.svg"
# call into the full docker run command with all the right flags.
WRAPPER="$HOME/bin/mermaid-render"

cat > "$WRAPPER" << 'WRAPPER_SCRIPT'
#!/usr/bin/env bash
# mermaid-render -- wrapper for minlag/mermaid-cli via Docker
#
# Usage:
#   mermaid-render input.mmd [output.svg] [extra mmdc args...]
#
# If output file is omitted, defaults to input filename with .svg extension.
# Extra args are passed directly to mmdc (e.g., -s 3 for 3x PNG scale).

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: mermaid-render <input.mmd> [output.svg] [extra args...]"
  echo "  input.mmd   -- Mermaid source file"
  echo "  output.svg  -- Output file (default: same name, .svg extension)"
  echo "  extra args  -- passed directly to mmdc (e.g., -s 3 for PNG)"
  exit 1
fi

INPUT_FILE="$1"
shift

# Resolve input to an absolute path so Docker can mount it correctly
INPUT_ABS="$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")"
INPUT_DIR="$(dirname "$INPUT_ABS")"
INPUT_NAME="$(basename "$INPUT_ABS")"

# Determine output filename
if [ $# -ge 1 ] && [[ "$1" != -* ]]; then
  OUTPUT_FILE="$1"
  shift
  OUTPUT_ABS="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"
  OUTPUT_NAME="$(basename "$OUTPUT_ABS")"
else
  # Default: replace extension with .svg
  OUTPUT_NAME="${INPUT_NAME%.*}.svg"
  OUTPUT_ABS="$INPUT_DIR/$OUTPUT_NAME"
fi

# Remaining arguments are passed through to mmdc
EXTRA_ARGS="$*"

# Mount the mermaid config file if it exists
CONFIG_MOUNT=""
CONFIG_ARG=""
if [ -f "$HOME/.config/mermaid/config.json" ]; then
  CONFIG_MOUNT="-v $HOME/.config/mermaid/config.json:/config.json"
  CONFIG_ARG="-c /config.json"
fi

# ── THE CRITICAL PART ──────────────────────────────────────────────────────
# --user "$(id -u):$(id -g)" makes the container write files as YOU, not root.
# Without this, output files are owned by root and you cannot read/move them
# without sudo. This is Error #1 in the runbook.
# ───────────────────────────────────────────────────────────────────────────
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$INPUT_DIR:/data" \
  $CONFIG_MOUNT \
  minlag/mermaid-cli \
  -i "/data/$INPUT_NAME" \
  -o "/data/$OUTPUT_NAME" \
  $CONFIG_ARG \
  $EXTRA_ARGS

echo "[DONE] Output: $OUTPUT_ABS"
WRAPPER_SCRIPT

chmod +x "$WRAPPER"
echo "[PASS] Created $WRAPPER"
echo ""

# ── Step 4: Create the mermaid config directory ───────────────────────────────
# Phase 2 will write config files here. Creating the dir now prevents errors.
mkdir -p "$HOME/.config/mermaid"
echo "[INFO] Config directory ready: ~/.config/mermaid/"
echo ""

echo "============================================="
echo "  Install complete."
echo "  Next: run setup-path.sh to add ~/bin to PATH,"
echo "  then run test-render.sh to verify everything works."
echo "============================================="
echo ""
