#!/usr/bin/env bash
# create-validate-wrapper.sh
# Creates ~/bin/mermaid-validate -- a thin wrapper that runs maid first and
# only proceeds to mermaid-render if the syntax check passes.
#
# Why a wrapper instead of calling maid directly?
#   The PostToolUse hook (Phase 6) runs a single shell command. Having a named
#   wrapper keeps the hook string short and readable, and lets you swap out the
#   validator later without editing settings.json.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# ── Ensure ~/bin exists ──────────────────────────────────────────────────────
mkdir -p "$HOME/bin"

WRAPPER="$HOME/bin/mermaid-validate"

echo "==> Creating $WRAPPER ..."

# Write the wrapper script. The heredoc delimiter (EOF) is unquoted so that
# $HOME expands NOW (at write time), but the single-quoted INNEREOF keeps the
# script body literal.
cat > "$WRAPPER" << 'INNEREOF'
#!/usr/bin/env bash
# mermaid-validate
# Usage: mermaid-validate <input.mmd> [output.svg]
#
# Runs maid for fast syntax validation, then delegates to mermaid-render
# if and only if validation passes.

set -euo pipefail

INPUT_FILE="${1:-}"
OUTPUT_FILE="${2:-}"

# ── Argument check ───────────────────────────────────────────────────────────
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: mermaid-validate <input.mmd> [output.svg]" >&2
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: File not found: $INPUT_FILE" >&2
    exit 1
fi

# ── Step 1: Syntax validation via maid ──────────────────────────────────────
echo "[mermaid-validate] Validating syntax: $INPUT_FILE"

if ! maid "$INPUT_FILE"; then
    echo ""
    echo "Validation failed. Fix syntax before rendering." >&2
    echo ""
    echo "Common fixes:"
    echo "  - Edge labels in pipes: use -->|Label| NOT -->|\"Label\"|"
    echo "  - Node labels: use A[\"Label\"] NOT A[Label]"
    echo "  - Line breaks: use <br/> NOT \\n"
    echo "  - Node IDs: alphanumeric only, no hyphens"
    exit 1
fi

echo "[mermaid-validate] Syntax OK."

# ── Step 2: Render ───────────────────────────────────────────────────────────
# If no output file was specified, derive one from the input filename.
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${INPUT_FILE%.mmd}.svg"
fi

echo "[mermaid-validate] Rendering to: $OUTPUT_FILE"
mermaid-render "$INPUT_FILE" "$OUTPUT_FILE"
echo "[mermaid-validate] Done."
INNEREOF

chmod +x "$WRAPPER"

echo "    Created: $WRAPPER"
echo ""
echo "==> Test it:"
echo "    mermaid-validate path/to/diagram.mmd"
echo ""
echo "    Or add ~/bin to your PATH if it isn't already:"
echo "    echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
