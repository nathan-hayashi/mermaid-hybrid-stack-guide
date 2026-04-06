#!/usr/bin/env bash
# update-bootstrap.sh
# Documents how to update ~/bin/new-project so that every new project
# automatically gets diagrams/ and docs/ directories with the right gitignore
# rules pre-applied.
#
# This script PRINTS instructions rather than blindly modifying new-project
# because the bootstrap script varies per setup. Read the output and apply
# the changes manually (or let Claude Code do it with /mermaid-diagrams).

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

BOOTSTRAP="$HOME/bin/new-project"

echo "==> Bootstrap update guide for: $BOOTSTRAP"
echo ""

# ── Check if new-project exists ──────────────────────────────────────────────
if [ ! -f "$BOOTSTRAP" ]; then
    echo "    ~/bin/new-project does not exist yet."
    echo "    The snippet below shows what to add when you create it."
    echo ""
fi

# ── Print the snippet to add ─────────────────────────────────────────────────
cat << 'SNIPPET'
────────────────────────────────────────────────────────────────
Add the following block to ~/bin/new-project after your existing
directory scaffolding (after the initial git init + README):
────────────────────────────────────────────────────────────────

  # ── Diagram directories ────────────────────────────────────
  echo "==> Creating diagrams/ and docs/ directories..."
  mkdir -p diagrams docs

  # .mmd source files are tracked; rendered artifacts are not.
  cat > diagrams/.gitignore << 'GITIGNORE_EOF'
*.svg
*.png
*.pdf
GITIGNORE_EOF

  # Placeholder so diagrams/ is committed even when empty.
  touch diagrams/.gitkeep

  # Example markdown with embedded Mermaid block.
  cat > docs/README.md << 'DOCS_EOF'
# Project Diagrams

Source diagrams live in `diagrams/` as `.mmd` files.
GitHub renders them natively -- paste the file contents into
any markdown fenced block with the `mermaid` language tag.
DOCS_EOF

  git add diagrams/ docs/
  git commit -m "chore: add diagrams and docs scaffold"

────────────────────────────────────────────────────────────────
SNIPPET

echo ""
echo "==> If new-project already exists, check whether these lines are present:"
if [ -f "$BOOTSTRAP" ]; then
    if grep -q "diagrams" "$BOOTSTRAP" 2>/dev/null; then
        echo "    diagrams/ setup FOUND in $BOOTSTRAP -- no changes needed."
    else
        echo "    diagrams/ setup NOT FOUND in $BOOTSTRAP -- apply the snippet above."
    fi
fi
