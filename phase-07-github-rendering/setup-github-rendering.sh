#!/usr/bin/env bash
# setup-github-rendering.sh
# Creates a global gitignore that excludes rendered diagram artifacts (SVG, PNG,
# PDF) while keeping .mmd source files tracked.
#
# Also creates a docs/ directory scaffold for GitHub-ready markdown with
# embedded Mermaid blocks.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

GLOBAL_GITIGNORE="$HOME/.gitignore_global"

echo "==> Setting up GitHub-native Mermaid rendering..."
echo ""

# ── Step 1: Create/update global gitignore ───────────────────────────────────
echo "--> Step 1: Global gitignore"

# Check if our rules already exist to keep the script idempotent.
if [ -f "$GLOBAL_GITIGNORE" ] && grep -q "diagrams/\*.svg" "$GLOBAL_GITIGNORE"; then
    echo "    Diagram artifact rules already present in $GLOBAL_GITIGNORE"
else
    # Append (or create) the rules. Using a blank line separator if the file
    # already exists and has content.
    if [ -f "$GLOBAL_GITIGNORE" ] && [ -s "$GLOBAL_GITIGNORE" ]; then
        echo "" >> "$GLOBAL_GITIGNORE"
        echo "# Mermaid / diagram rendered artifacts (keep .mmd source files)" >> "$GLOBAL_GITIGNORE"
    else
        echo "# Mermaid / diagram rendered artifacts (keep .mmd source files)" > "$GLOBAL_GITIGNORE"
    fi

    cat >> "$GLOBAL_GITIGNORE" << 'EOF'
diagrams/*.svg
diagrams/*.png
diagrams/*.pdf
EOF

    echo "    Written: $GLOBAL_GITIGNORE"
fi

# ── Step 2: Register global gitignore with git ────────────────────────────────
echo "--> Step 2: Register with git config"
git config --global core.excludesFile "$GLOBAL_GITIGNORE"
CONFIGURED="$(git config --global core.excludesFile)"
echo "    git config core.excludesFile = $CONFIGURED"

# ── Step 3: Create docs/ scaffold ─────────────────────────────────────────────
echo "--> Step 3: Create docs/ scaffold"
mkdir -p docs

# Only write the example if it doesn't already exist.
EXAMPLE_DOC="docs/diagram-embed-example.md"
if [ ! -f "$EXAMPLE_DOC" ]; then
    cat > "$EXAMPLE_DOC" << 'DOCEOF'
# Diagram Embed Example

GitHub renders Mermaid diagrams natively in markdown. Use fenced code blocks
with the `mermaid` language tag:

```mermaid
flowchart LR
    A["User"] --> B["Auth Server"]
    B -->|Token| C["Resource Server"]
    C -->|Data| A
```

## Limitations

These features are NOT supported in GitHub's renderer:
- ELK layout engine
- Font Awesome icons
- Clickable hyperlinks in nodes
- Custom theme variables
- Diagrams exceeding ~50 KB

For diagrams that need these features, render with mermaid-cli and embed
the resulting SVG or PNG image instead.
DOCEOF
    echo "    Created: $EXAMPLE_DOC"
else
    echo "    Skipped (already exists): $EXAMPLE_DOC"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "==> Done."
echo ""
echo "    Verify:"
echo "    cat ~/.gitignore_global"
echo "    git config --global core.excludesFile"
