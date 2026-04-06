#!/usr/bin/env bash
# create-skill.sh
# Creates ~/.claude/skills/mermaid-diagrams/SKILL.md
#
# IMPORTANT: A Claude Code skill is a DIRECTORY containing SKILL.md.
# A standalone markdown file at the skills root is NOT recognised as a skill.
# Correct path: ~/.claude/skills/mermaid-diagrams/SKILL.md

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SKILL_DIR="$HOME/.claude/skills/mermaid-diagrams"
SKILL_FILE="$SKILL_DIR/SKILL.md"

# ── Back up any existing skill file ─────────────────────────────────────────
if [ -f "$SKILL_FILE" ]; then
    BACKUP="${SKILL_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "==> Backing up existing skill to: $BACKUP"
    cp "$SKILL_FILE" "$BACKUP"
fi

# ── Create the skill directory ───────────────────────────────────────────────
echo "==> Creating skill directory: $SKILL_DIR"
mkdir -p "$SKILL_DIR"

# ── Write SKILL.md ───────────────────────────────────────────────────────────
echo "==> Writing $SKILL_FILE ..."

cat > "$SKILL_FILE" << 'EOF'
---
name: mermaid-diagrams
description: Generate production-quality diagrams.
allowed-tools: [Read, Write, Edit, Bash]
---

## Syntax Guardrails -- CRITICAL
- Line breaks: use <br/> NEVER \n
- Node labels: ALWAYS quote ["Label"]
- Edge labels in pipes: NEVER quote -->|Label|
- Node IDs: alphanumeric only

## Diagram Type Selection
- Flowcharts, sequences, Gantt --> **Mermaid** (.mmd files)
- Heatmaps, grouped bars, data charts --> **Vega-Lite** (.vl.json files)
- Multi-layer architectures --> **D2** (.d2 files)

## Enterprise Colors
- Primary: #F0F4FC
- Text: #1F2329
- Border: #2C5F8A
- Secondary: #E8F5E9
- Tertiary: #FFF3E0
- Font: Inter, Segoe UI, Roboto, sans-serif

## Post-Generation
1. Run maid <file> to validate
2. If fails, read error, fix, re-validate
3. Run mermaid-render <file> to produce SVG
EOF

echo "    Done."
echo ""
echo "==> Skill installed at: $SKILL_FILE"
echo ""
echo "    Invoke in Claude Code with: /mermaid-diagrams"
echo "    Or run: bash phase-05-claude-skill/test-skill.sh to verify."
