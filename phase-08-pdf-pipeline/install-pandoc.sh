#!/usr/bin/env bash
# install-pandoc.sh
# Installs pandoc for markdown-to-PDF conversion.
#
# LaTeX note:
#   pandoc's native PDF backend requires a LaTeX distribution (texlive-full
#   or similar), which weighs ~2 GB and takes 10+ minutes to install. It's
#   not worth it for most technical documentation use cases. This script
#   installs pandoc only; the mermaid-pdf wrapper (create-pdf-script.sh) uses
#   an HTML-based fallback (wkhtmltopdf or weasyprint) which is much smaller
#   and produces acceptable results for runbooks and design docs.
#
#   If you specifically need LaTeX-quality math typesetting, install it with:
#   sudo apt-get install -y texlive-latex-recommended texlive-fonts-recommended

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo "==> Checking for pandoc..."

if command -v pandoc >/dev/null 2>&1; then
    echo "    pandoc is already installed: $(pandoc --version | head -1)"
    echo "    Nothing to do."
    exit 0
fi

echo "==> Installing pandoc via apt-get..."
sudo apt-get update -qq
sudo apt-get install -y pandoc

echo ""
echo "==> Verifying install..."
if command -v pandoc >/dev/null 2>&1; then
    echo "    OK -- $(pandoc --version | head -1)"
else
    echo "    ERROR: pandoc not found after install." >&2
    exit 1
fi

# ── Optional: HTML PDF backend ────────────────────────────────────────────────
echo ""
echo "==> Checking for HTML-to-PDF backend..."
echo "    (Used as fallback when LaTeX is not installed)"

if command -v wkhtmltopdf >/dev/null 2>&1; then
    echo "    Found: wkhtmltopdf $(wkhtmltopdf --version 2>/dev/null | head -1)"
elif command -v weasyprint >/dev/null 2>&1; then
    echo "    Found: weasyprint"
else
    echo "    No HTML PDF backend found."
    echo "    Install one for the HTML fallback route:"
    echo "      sudo apt-get install -y wkhtmltopdf"
    echo "      OR: pip install weasyprint"
    echo ""
    echo "    Without a backend, mermaid-pdf will use pandoc's built-in HTML"
    echo "    output and you can open the .html in a browser to print-to-PDF."
fi
