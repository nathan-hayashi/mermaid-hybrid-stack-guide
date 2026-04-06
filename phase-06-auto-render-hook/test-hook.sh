#!/usr/bin/env bash
# test-hook.sh
# Validates that settings.json is well-formed JSON and contains the expected
# PostToolUse hook and permission entries.

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SETTINGS="$HOME/.claude/settings.json"

PASS=0
FAIL=0

pass() { echo "  PASS -- $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL -- $1"; FAIL=$((FAIL + 1)); }

echo "==> Testing hook configuration in: $SETTINGS"
echo ""

# ── Prereq: jq ───────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required. Install it with: sudo apt-get install -y jq" >&2
    exit 1
fi

# ── Check 1: File exists ──────────────────────────────────────────────────────
echo "--> Check 1: settings.json exists"
if [ -f "$SETTINGS" ]; then
    pass "settings.json found"
else
    fail "settings.json not found at $SETTINGS -- run create-hook.sh first"
    echo "Cannot continue without settings.json." >&2
    exit 1
fi

# ── Check 2: Valid JSON ───────────────────────────────────────────────────────
echo "--> Check 2: settings.json is valid JSON"
if jq . "$SETTINGS" > /dev/null 2>&1; then
    pass "settings.json is valid JSON"
else
    fail "settings.json is INVALID JSON -- this will break Claude Code"
    echo "Restore the backup: cp ${SETTINGS}.bak.* $SETTINGS" >&2
    exit 1
fi

# ── Check 3: PostToolUse hook exists ─────────────────────────────────────────
echo "--> Check 3: PostToolUse hook array exists"
HOOK_COUNT="$(jq '.hooks.PostToolUse | length' "$SETTINGS" 2>/dev/null || echo 0)"
if [ "$HOOK_COUNT" -gt 0 ]; then
    pass "PostToolUse array has $HOOK_COUNT entry/entries"
else
    fail "hooks.PostToolUse is empty or missing -- run create-hook.sh"
fi

# ── Check 4: Write matcher is present ────────────────────────────────────────
echo "--> Check 4: Write matcher is in PostToolUse"
WRITE_MATCHER="$(jq -r '.hooks.PostToolUse[] | select(.matcher == "Write") | .matcher' "$SETTINGS" 2>/dev/null | head -1)"
if [ "$WRITE_MATCHER" = "Write" ]; then
    pass "Write matcher found in PostToolUse"
else
    fail "Write matcher missing from PostToolUse -- run create-hook.sh"
fi

# ── Check 5: Timeout is set ──────────────────────────────────────────────────
echo "--> Check 5: Hook timeout is configured (should be 60)"
TIMEOUT="$(jq -r '.hooks.PostToolUse[] | select(.matcher == "Write") | .hooks[0].timeout' "$SETTINGS" 2>/dev/null || echo '')"
if [ "$TIMEOUT" = "60" ]; then
    pass "Timeout is 60 seconds"
else
    fail "Timeout is '$TIMEOUT' (expected 60) -- Docker cold-start may exceed default"
fi

# ── Check 6: maid permission present ─────────────────────────────────────────
echo "--> Check 6: Bash(maid*) permission is in permissions.allow"
MAID_PERM="$(jq -r '.permissions.allow[] | select(. == "Bash(maid*)")' "$SETTINGS" 2>/dev/null | head -1)"
if [ "$MAID_PERM" = "Bash(maid*)" ]; then
    pass "Bash(maid*) permission found"
else
    fail "Bash(maid*) permission missing -- run add-permissions.sh"
fi

# ── Check 7: docker permission present ───────────────────────────────────────
echo "--> Check 7: Bash(docker run*) permission is in permissions.allow"
DOCKER_PERM="$(jq -r '.permissions.allow[] | select(. == "Bash(docker run*)")' "$SETTINGS" 2>/dev/null | head -1)"
if [ "$DOCKER_PERM" = "Bash(docker run*)" ]; then
    pass "Bash(docker run*) permission found"
else
    fail "Bash(docker run*) permission missing -- run add-permissions.sh"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo "================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
