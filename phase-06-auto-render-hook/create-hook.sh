#!/usr/bin/env bash
# create-hook.sh
# Merges a PostToolUse hook into ~/.claude/settings.json that auto-validates
# and renders any .mmd file written by Claude Code's Write tool.
#
# SAFE: uses jq to merge -- never overwrites the entire file.
# IDEMPOTENT: running this script twice produces the same result.

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

# ── Back up before modifying ──────────────────────────────────────────────────
BACKUP="${SETTINGS}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SETTINGS" "$BACKUP"
echo "==> Backed up settings.json to: $BACKUP"

# ── The hook command ──────────────────────────────────────────────────────────
# Breaking this down:
#   INPUT=$(cat)               -- reads the JSON payload piped by Claude Code
#   FILE=$(echo "$INPUT" | jq) -- extracts the file_path from tool_input
#   case "*.mmd"               -- POSIX-safe extension check (not [[ ]])
#   export PATH                -- ~/bin is not in the hook's minimal env
#   maid "$FILE"               -- fast syntax check (~1ms)
#   mermaid-render SVG + PNG   -- only runs if maid exits 0

HOOK_COMMAND='bash -c '"'"'INPUT=$(cat); FILE=$(echo "$INPUT" | jq -r ".tool_input.file_path // empty"); case "$FILE" in *.mmd) export PATH="$HOME/bin:$PATH"; maid "$FILE" 2>/dev/null; if [ $? -eq 0 ]; then mermaid-render "$FILE" "${FILE%.mmd}.svg" 2>/dev/null; mermaid-render "$FILE" "${FILE%.mmd}.png" -s 3 2>/dev/null; fi ;; esac'"'"

# ── Build the new hook entry as a JSON object ─────────────────────────────────
NEW_HOOK="$(jq -n \
    --arg cmd "$HOOK_COMMAND" \
    '{
        matcher: "Write",
        hooks: [{
            type: "command",
            command: $cmd,
            timeout: 60
        }]
    }')"

# ── Merge into existing settings.json ────────────────────────────────────────
# Strategy:
#   - If hooks.PostToolUse does not exist: create it as an array with our entry.
#   - If it exists: append our entry (jq += for arrays).
# We avoid duplicates by checking if the Write matcher already exists.

echo "==> Merging hook into: $SETTINGS"

UPDATED="$(jq \
    --argjson new_hook "$NEW_HOOK" \
    '
    # Ensure hooks and hooks.PostToolUse exist
    .hooks //= {}
    | .hooks.PostToolUse //= []
    # Remove any existing Write matcher entry to avoid duplicates
    | .hooks.PostToolUse |= map(select(.matcher != "Write"))
    # Append the new entry
    | .hooks.PostToolUse += [$new_hook]
    ' "$SETTINGS")"

echo "$UPDATED" > "$SETTINGS"

echo "    Hook added with timeout: 60s (Docker cold-start budget)"
echo ""
echo "==> Verify with:"
echo "    jq '.hooks.PostToolUse' ~/.claude/settings.json"
