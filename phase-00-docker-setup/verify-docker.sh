#!/usr/bin/env bash
# verify-docker.sh
# Checks that Docker Desktop is running and the WSL 2 backend is correctly
# configured. Run this from inside your WSL 2 Ubuntu terminal.
#
# Exit codes:
#   0 = all checks passed
#   1 = one or more checks failed

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

PASS="[PASS]"
FAIL="[FAIL]"
INFO="[INFO]"

pass() { echo "$PASS $1"; }
fail() { echo "$FAIL $1"; FAILED=1; }
info() { echo "$INFO $1"; }

FAILED=0

echo ""
echo "============================================="
echo "  Phase 0 -- Docker WSL 2 Verification"
echo "============================================="
echo ""

# ── Check 1: docker --version ─────────────────────────────────────────────────
# This confirms the docker CLI is on your PATH inside WSL 2.
echo "--- Check 1: docker CLI available ---"
if docker --version 2>/dev/null; then
  pass "docker CLI found"
else
  fail "docker CLI not found. Make sure Docker Desktop is installed and"
  info "  its WSL 2 backend is enabled. [WINDOWS] Docker Desktop → Settings"
  info "  → General → 'Use the WSL 2 based engine' must be checked."
fi
echo ""

# ── Check 2: docker run hello-world ──────────────────────────────────────────
# Runs a tiny container to confirm the Docker daemon is reachable from WSL 2.
echo "--- Check 2: docker daemon reachable (hello-world) ---"
if docker run --rm hello-world 2>&1 | grep -q "Hello from Docker"; then
  pass "hello-world container ran successfully"
else
  fail "hello-world container did not produce expected output."
  info "  Possible causes:"
  info "  1. Docker Desktop is not running on Windows -- launch it first."
  info "  2. WSL Integration is not enabled for your Ubuntu distro. [WINDOWS]"
  info "     Docker Desktop → Settings → Resources → WSL Integration"
  info "     → toggle on your Ubuntu distro, then Apply & Restart."
fi
echo ""

# ── Check 3: docker compose version ──────────────────────────────────────────
# Verifies the Compose v2 plugin is available (needed for multi-container setups).
echo "--- Check 3: docker compose (v2) available ---"
if docker compose version 2>/dev/null; then
  pass "docker compose v2 found"
else
  fail "docker compose not found."
  info "  Docker Compose v2 ships with Docker Desktop 3.x+."
  info "  Update Docker Desktop to the latest version to fix this."
fi
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo "============================================="
if [ "$FAILED" -eq 0 ]; then
  echo "  All checks PASSED. Proceed to Phase 1."
else
  echo "  One or more checks FAILED. Fix the issues above, then re-run:"
  echo "    bash phase-00-docker-setup/verify-docker.sh"
fi
echo "============================================="
echo ""

exit "$FAILED"
