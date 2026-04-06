#!/usr/bin/env bash
# test-skill.sh
# Verifies that the mermaid-diagrams skill is installed correctly.
#
# A Claude Code skill MUST be a directory containing SKILL.md.
# This test checks both that the file exists AND that it lives inside a
# directory (not as a standalone file at the skills root).

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SKILL_DIR="$HOME/.claude/skills/mermaid-diagrams"
SKILL_FILE="$SKILL_DIR/SKILL.md"

PASS=0
FAIL=0

pass() { echo "  PASS -- $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL -- $1"; FAIL=$((FAIL + 1)); }

echo "==> Testing mermaid-diagrams skill installation..."
echo ""

# ── Check 1: Skill directory exists ──────────────────────────────────────────
echo "--> Check 1: Skill directory exists"
if [ -d "$SKILL_DIR" ]; then
    pass "directory exists: $SKILL_DIR"
else
    fail "directory missing: $SKILL_DIR -- run create-skill.sh first"
fi

# ── Check 2: SKILL.md exists inside the directory ────────────────────────────
echo "--> Check 2: SKILL.md exists inside the directory"
if [ -f "$SKILL_FILE" ]; then
    pass "SKILL.md found at: $SKILL_FILE"
else
    fail "SKILL.md missing: $SKILL_FILE"
fi

# ── Check 3: SKILL.md is inside a directory (not standalone) ────────────────
# The parent of SKILL.md must be a directory named 'mermaid-diagrams'.
echo "--> Check 3: SKILL.md is inside a named directory (not standalone)"
PARENT_DIR="$(dirname "$SKILL_FILE")"
PARENT_NAME="$(basename "$PARENT_DIR")"

if [ "$PARENT_NAME" = "mermaid-diagrams" ] && [ -d "$PARENT_DIR" ]; then
    pass "skill is correctly structured as a directory: $PARENT_DIR/SKILL.md"
else
    fail "skill is not inside a named directory -- Claude Code won't recognise it"
fi

# ── Check 4: SKILL.md contains Syntax Guardrails ─────────────────────────────
echo "--> Check 4: SKILL.md contains Syntax Guardrails section"
if [ -f "$SKILL_FILE" ] && grep -q "Syntax Guardrails" "$SKILL_FILE"; then
    pass "Syntax Guardrails section found"
else
    fail "Syntax Guardrails section missing from SKILL.md"
fi

# ── Check 5: SKILL.md contains the NEVER quote rule ──────────────────────────
echo "--> Check 5: SKILL.md enforces NEVER quote pipe edge labels"
if [ -f "$SKILL_FILE" ] && grep -q "NEVER quote" "$SKILL_FILE"; then
    pass "NEVER quote rule present"
else
    fail "NEVER quote rule missing -- Claude may generate broken edge labels"
fi

# ── Check 6: Frontmatter has name field ──────────────────────────────────────
echo "--> Check 6: SKILL.md frontmatter has 'name' field"
if [ -f "$SKILL_FILE" ] && grep -q "^name:" "$SKILL_FILE"; then
    pass "frontmatter 'name' field found"
else
    fail "frontmatter 'name' field missing"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo "================================"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Fix the above failures, then re-run this script."
    exit 1
fi

echo ""
echo "Skill is correctly installed. Use /mermaid-diagrams in Claude Code."
