#!/usr/bin/env bash
# test-validation.sh
# Smoke-tests the mermaid-validate wrapper with a valid diagram and a broken one.
# Expected results:
#   valid.mmd   --> exits 0  (validation + render succeeds)
#   broken.mmd  --> exits 1  and prints the "Fix syntax" message

set -euo pipefail

# ── Load platform helpers ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────
PASS=0
FAIL=0

pass() { echo "  PASS -- $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL -- $1"; FAIL=$((FAIL + 1)); }

# ── Prereq check ─────────────────────────────────────────────────────────────
echo "==> Checking prerequisites..."

if ! command -v maid >/dev/null 2>&1; then
    echo "ERROR: maid is not installed. Run install-maid.sh first." >&2
    exit 1
fi

if [ ! -x "$HOME/bin/mermaid-validate" ]; then
    echo "ERROR: ~/bin/mermaid-validate not found. Run create-validate-wrapper.sh first." >&2
    exit 1
fi

# Ensure ~/bin is in PATH so the wrapper can call mermaid-render.
export PATH="$HOME/bin:$PATH"

# ── Temp workspace ───────────────────────────────────────────────────────────
TMPDIR_TEST="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_TEST"' EXIT

# ── Test 1: Valid diagram (should PASS validation) ───────────────────────────
VALID_MMD="$TMPDIR_TEST/valid.mmd"

cat > "$VALID_MMD" << 'EOF'
flowchart LR
    A["Start"] --> B["Process"]
    B -->|Success| C["End"]
    B -->|Failure| D["Retry"]
EOF

echo ""
echo "==> Test 1: Valid diagram"

if maid "$VALID_MMD" >/dev/null 2>&1; then
    pass "maid accepted valid .mmd file"
else
    fail "maid rejected a valid .mmd file -- unexpected"
fi

# ── Test 2: Broken diagram (should FAIL validation) ──────────────────────────
# This diagram uses quoted strings in pipe edge labels, which maid rejects.
# Correct form: -->|Label|   Wrong form: -->|"Label"|
BROKEN_MMD="$TMPDIR_TEST/broken.mmd"

cat > "$BROKEN_MMD" << 'EOF'
flowchart LR
    A["Input"] --> B["Evaluate"]
    B -->|"Score <= 4"| C["Low"]
    B -->|"Score >= 5"| D["High"]
EOF

echo ""
echo "==> Test 2: Broken diagram (quoted pipe edge labels)"

VALIDATE_OUTPUT="$("$HOME/bin/mermaid-validate" "$BROKEN_MMD" 2>&1 || true)"

if echo "$VALIDATE_OUTPUT" | grep -q "Validation failed. Fix syntax before rendering."; then
    pass "validation correctly rejected broken syntax"
else
    fail "expected 'Validation failed' message but got: $VALIDATE_OUTPUT"
fi

# Verify exit code separately using maid directly.
if maid "$BROKEN_MMD" >/dev/null 2>&1; then
    fail "maid unexpectedly accepted broken .mmd (quoted pipe labels)"
else
    pass "maid exited non-zero for broken syntax"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo "================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
