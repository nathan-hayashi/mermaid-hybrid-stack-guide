#!/usr/bin/env bash
# test-render.sh
# Creates a simple Mermaid diagram, renders it to SVG via mermaid-render,
# and verifies that the output file exists and has content (size > 0 bytes).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "============================================="
echo "  Phase 1 -- Test Render"
echo "============================================="
echo ""

# ── Paths ─────────────────────────────────────────────────────────────────────
WORK_DIR="$(mktemp -d)"
TEST_MMD="$WORK_DIR/test-flowchart.mmd"
TEST_SVG="$WORK_DIR/test-flowchart.svg"

# Clean up the temp dir on exit (whether or not we succeed)
trap 'rm -rf "$WORK_DIR"' EXIT

# ── Step 1: Write the test diagram ────────────────────────────────────────────
# This is the threshold escalation flowchart from the runbook.
# It exercises node labels, edge labels, and diamond decision nodes.
cat > "$TEST_MMD" << 'MMD'
flowchart TD
    A["User Prompt"] --> B{"Complexity<br/>Score"}
    B -->|Score <= 4| C["Tier 1<br/>Solo Agent"]
    B -->|Score 5-8| D["Tier 2<br/>Lean Pipeline"]
    B -->|Score >= 9| E["Tier 3<br/>Full Orchestra"]
    C --> F["Direct Execution"]
    D --> G["3 Subagents<br/>+ Review"]
    E --> H["OCR + Codex<br/>+ Discourse"]
MMD

echo "[INFO] Test diagram written to: $TEST_MMD"
echo ""

# ── Step 2: Verify mermaid-render is available ────────────────────────────────
if ! command -v mermaid-render &>/dev/null; then
  echo "[FAIL] mermaid-render not found on PATH."
  echo "  Run setup-path.sh and then 'source \$SHELL_RC', or open a new terminal."
  exit 1
fi

echo "[INFO] Running: mermaid-render $TEST_MMD $TEST_SVG"
echo ""

# ── Step 3: Render ────────────────────────────────────────────────────────────
mermaid-render "$TEST_MMD" "$TEST_SVG"

# ── Step 4: Verify output ─────────────────────────────────────────────────────
echo ""
if [ ! -f "$TEST_SVG" ]; then
  echo "[FAIL] Output SVG was not created: $TEST_SVG"
  echo "  Check the Docker output above for error messages."
  exit 1
fi

SVG_SIZE=$(wc -c < "$TEST_SVG")
if [ "$SVG_SIZE" -eq 0 ]; then
  echo "[FAIL] Output SVG exists but is empty (0 bytes)."
  echo "  This usually means the diagram syntax was rejected."
  echo "  Check the Docker output above for Mermaid parse errors."
  exit 1
fi

echo "[PASS] SVG created successfully ($SVG_SIZE bytes)."
echo ""

# ── Step 5: Quick sanity check -- SVG must contain <svg tag ─────────────────
if grep -q "<svg" "$TEST_SVG"; then
  echo "[PASS] File contains <svg> tag -- looks like a valid SVG."
else
  echo "[FAIL] File does not contain an <svg> tag -- may be an error page."
  echo "  Contents (first 200 chars):"
  head -c 200 "$TEST_SVG"
  exit 1
fi

echo ""
echo "============================================="
echo "  Test render PASSED. mermaid-render is working."
echo "  Proceed to Phase 2 to set up enterprise themes."
echo "============================================="
echo ""
