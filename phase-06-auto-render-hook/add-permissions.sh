#!/usr/bin/env bash
# add-permissions.sh
# Adds diagram-tool permissions to ~/.claude/settings.json so Claude Code
# doesn't prompt for approval on every maid/mermaid-render/docker invocation.
#
# SAFE: merges into existing permissions.allow array -- never overwrites.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SETTINGS="$HOME/.claude/settings.json"

# ── Prereq: jq ───────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required. Install it with: sudo apt-get install -y jq" >&2
    exit 1
fi

# ── Create settings.json if it doesn't exist yet ─────────────────────────────
if [ ! -f "$SETTINGS" ]; then
    echo "==> settings.json not found. Creating a minimal one..."
    mkdir -p "$(dirname "$SETTINGS")"
    echo '{}' > "$SETTINGS"
fi

# ── Back up ───────────────────────────────────────────────────────────────────
BACKUP="${SETTINGS}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SETTINGS" "$BACKUP"
echo "==> Backed up settings.json to: $BACKUP"

# ── Define permissions to add ─────────────────────────────────────────────────
# Each entry is a glob pattern matching a Bash tool call.
# Claude Code checks the first word + arguments against these patterns.
NEW_PERMISSIONS=(
    "Bash(maid*)"
    "Bash(mermaid-render*)"
    "Bash(mermaid-validate*)"
    "Bash(mermaid-render-dark*)"
    "Bash(d2*)"
    "Bash(d2-render*)"
    "Bash(vl2svg*)"
    "Bash(vl2png*)"
    "Bash(vegalite-render*)"
    "Bash(render-all-diagrams*)"
    "Bash(docker run*)"
)

# ── Build a JSON array of new permission strings ──────────────────────────────
PERMS_JSON="$(printf '%s\n' "${NEW_PERMISSIONS[@]}" | jq -R . | jq -s .)"

# ── Merge: add permissions, skip any already present ─────────────────────────
echo "==> Merging permissions into: $SETTINGS"

UPDATED="$(jq \
    --argjson new_perms "$PERMS_JSON" \
    '
    .permissions //= {}
    | .permissions.allow //= []
    | .permissions.allow |= (. + $new_perms | unique)
    ' "$SETTINGS")"

echo "$UPDATED" > "$SETTINGS"

echo ""
echo "    Added ${#NEW_PERMISSIONS[@]} permission patterns."
echo ""
echo "==> Verify with:"
echo "    jq '.permissions.allow' ~/.claude/settings.json"
