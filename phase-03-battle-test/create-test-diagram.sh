#!/usr/bin/env bash
# create-test-diagram.sh
# Creates the full threshold escalation flowchart as a Mermaid source file.
# This is the battle-test diagram from the Definitive Runbook.
#
# The diagram exercises: fan-out, fan-in, diamond decision nodes,
# special-character edge labels (<=, >=), and multi-line node labels (<br/>).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 3 -- Create Battle-Test Diagram"
echo "============================================="
echo ""

# ── Output path ───────────────────────────────────────────────────────────────
# Place the diagram inside this phase's directory for easy access.
DIAGRAMS_DIR="$SCRIPT_DIR/diagrams"
mkdir -p "$DIAGRAMS_DIR"
OUTPUT="$DIAGRAMS_DIR/threshold-escalation.mmd"

# ── Write the diagram ─────────────────────────────────────────────────────────
# Rules followed:
#   - Node labels ALWAYS quoted:  A["Label"]
#   - Edge labels NEVER quoted:   -->|Label|   not  -->|"Label"|
#   - Line breaks use <br/> not \n
#   - Stadium nodes for START/END: (["text"])
cat > "$OUTPUT" << 'MMD'
flowchart TD
    START(["Incoming Prompt"]) --> PARSE["Parse Prompt<br/>Extract Keywords"]
    PARSE --> SCORE{"Complexity<br/>Scoring Engine"}
    SCORE --> S1["File Count<br/>(0-3 pts)"]
    SCORE --> S2["Language Count<br/>(0-3 pts)"]
    SCORE --> S3["Keyword Signals<br/>(0-4 pts)"]
    SCORE --> S4["Cross-Cutting<br/>Concerns (0-2 pts)"]
    S1 --> SUM["Sum Score<br/>(0-12 range)"]
    S2 --> SUM
    S3 --> SUM
    S4 --> SUM
    SUM --> ROUTE{"Route by<br/>Threshold"}
    ROUTE -->|Score <= 4| T1["TIER 1<br/>Solo Agent<br/>(Opus 4.6)"]
    ROUTE -->|Score 5-8| T2["TIER 2<br/>Lean Pipeline<br/>(3 Subagents)"]
    ROUTE -->|Score >= 9| T3["TIER 3<br/>Full Orchestra<br/>(OCR + Codex)"]
MMD

echo "[PASS] Diagram created: $OUTPUT"
echo ""
echo "Next: run render-and-compare.sh to render SVG + PNG and check the output."
echo ""

echo "============================================="
echo "  Diagram source ready."
echo "============================================="
echo ""
