#!/usr/bin/env bash
# create-pdf-script.sh
# Creates ~/bin/mermaid-pdf -- a pandoc wrapper that converts a markdown file
# to PDF with a table of contents, geometry settings, and smart handling of
# the LaTeX-vs-HTML PDF backend choice.
#
# LaTeX fallback:
#   If LaTeX is not installed (the common case -- it's ~2 GB), the script falls
#   back to HTML output. You can open the HTML in a browser and use
#   "Print > Save as PDF" to get a PDF, or install wkhtmltopdf for a
#   fully automated HTML-to-PDF step.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

mkdir -p "$HOME/bin"
SCRIPT="$HOME/bin/mermaid-pdf"

echo "==> Creating $SCRIPT ..."

cat > "$SCRIPT" << 'INNEREOF'
#!/usr/bin/env bash
# mermaid-pdf
# Converts a markdown file to PDF using pandoc.
# Embedded diagram images (e.g. ![](diagram.png)) are included as-is.
# Render diagrams first with: render-all-diagrams ./diagrams
#
# Usage:
#   mermaid-pdf input.md                  # outputs input.pdf
#   mermaid-pdf input.md output.pdf       # explicit output path
#   mermaid-pdf input.md --toc            # with table of contents
#   mermaid-pdf input.md --html           # force HTML output (no LaTeX needed)

set -euo pipefail

# ── Argument parsing ─────────────────────────────────────────────────────────
INPUT=""
OUTPUT=""
TOC=0
FORCE_HTML=0

for arg in "$@"; do
    case "$arg" in
        --toc)       TOC=1 ;;
        --html)      FORCE_HTML=1 ;;
        --*)         echo "Unknown option: $arg" >&2; exit 1 ;;
        *.md)        [ -z "$INPUT" ] && INPUT="$arg" || OUTPUT="$arg" ;;
        *.pdf|*.html) OUTPUT="$arg" ;;
        *)           [ -z "$INPUT" ] && INPUT="$arg" || OUTPUT="$arg" ;;
    esac
done

if [ -z "$INPUT" ]; then
    echo "Usage: mermaid-pdf <input.md> [output.pdf] [--toc] [--html]" >&2
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "ERROR: File not found: $INPUT" >&2
    exit 1
fi

# Derive output filename if not specified.
if [ -z "$OUTPUT" ]; then
    BASE="${INPUT%.md}"
    if [ "$FORCE_HTML" -eq 1 ]; then
        OUTPUT="${BASE}.html"
    else
        OUTPUT="${BASE}.pdf"
    fi
fi

echo "[mermaid-pdf] Input:  $INPUT"
echo "[mermaid-pdf] Output: $OUTPUT"

# ── Build pandoc arguments ────────────────────────────────────────────────────
PANDOC_ARGS=(
    "$INPUT"
    -o "$OUTPUT"
    --standalone
    -V geometry:margin=1in
    -V fontsize=11pt
    -V colorlinks=true
    --highlight-style=tango
)

# Table of contents.
if [ "$TOC" -eq 1 ]; then
    PANDOC_ARGS+=(--toc --toc-depth=3)
fi

# ── Choose PDF backend ────────────────────────────────────────────────────────
if [ "$FORCE_HTML" -eq 0 ] && [[ "$OUTPUT" == *.pdf ]]; then
    # Try LaTeX first (best quality).
    if command -v pdflatex >/dev/null 2>&1 || command -v xelatex >/dev/null 2>&1; then
        echo "[mermaid-pdf] Backend: LaTeX"
        if command -v xelatex >/dev/null 2>&1; then
            PANDOC_ARGS+=(--pdf-engine=xelatex)
        fi
    # Fall back to wkhtmltopdf.
    elif command -v wkhtmltopdf >/dev/null 2>&1; then
        echo "[mermaid-pdf] Backend: wkhtmltopdf (HTML)"
        PANDOC_ARGS+=(--pdf-engine=wkhtmltopdf)
    # Fall back to weasyprint.
    elif command -v weasyprint >/dev/null 2>&1; then
        echo "[mermaid-pdf] Backend: weasyprint (HTML)"
        PANDOC_ARGS+=(--pdf-engine=weasyprint)
    else
        # No PDF backend. Fall back to HTML.
        echo "[mermaid-pdf] WARNING: No PDF backend found. Generating HTML instead."
        echo "[mermaid-pdf] Open the HTML in a browser and print to PDF."
        OUTPUT="${OUTPUT%.pdf}.html"
        PANDOC_ARGS[1]="-o"
        PANDOC_ARGS[2]="$OUTPUT"
    fi
fi

# ── Run pandoc ────────────────────────────────────────────────────────────────
pandoc "${PANDOC_ARGS[@]}"

if [ -f "$OUTPUT" ]; then
    SIZE="$(du -h "$OUTPUT" | cut -f1)"
    echo "[mermaid-pdf] Done: $OUTPUT ($SIZE)"
else
    echo "[mermaid-pdf] ERROR: Output file was not created." >&2
    exit 1
fi
INNEREOF

chmod +x "$SCRIPT"
echo "    Created: $SCRIPT"
echo ""
echo "==> Usage:"
echo "    mermaid-pdf runbook.md"
echo "    mermaid-pdf runbook.md --toc"
echo "    mermaid-pdf runbook.md report.pdf"
