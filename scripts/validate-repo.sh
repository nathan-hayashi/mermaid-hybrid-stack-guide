#!/usr/bin/env bash
# validate-repo.sh -- Pre-push repository validation.
# Checks structure, syntax, shebangs, permissions, secrets, configs, diagrams, and links.
#
# Usage: ./scripts/validate-repo.sh
# Exit code: 0 = all checks pass, 1 = one or more checks failed.

set -euo pipefail

# Load platform detection (sets PLATFORM, IS_WSL, etc.)
source "$(dirname "$0")/platform-detect.sh"

# ──────────────────────────────────────────────────────────────────────
# Repo root is one level up from the scripts/ directory.
# ──────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Counters for the final summary.
TOTAL=0
PASSED=0
FAILED=0

# ──────────────────────────────────────────────────────────────────────
# Helper: record a pass or fail.
#   pass "message"   -- prints a green checkmark and increments PASSED.
#   fail "message"   -- prints a red X and increments FAILED.
# ──────────────────────────────────────────────────────────────────────
pass() {
  echo "  [PASS] $1"
  TOTAL=$((TOTAL + 1))
  PASSED=$((PASSED + 1))
}

fail() {
  echo "  [FAIL] $1"
  TOTAL=$((TOTAL + 1))
  FAILED=$((FAILED + 1))
}

# ======================================================================
# 1. Structure check
#    Verify that all expected directories and their README.md files exist.
# ======================================================================
check_structure() {
  echo ""
  echo "=== 1. Structure check ==="

  # Top-level directories that must exist.
  local top_dirs=("scripts" "diagrams" "tutorial" "tutorial/assets/sample-project")

  for dir in "${top_dirs[@]}"; do
    if [[ -d "$REPO_ROOT/$dir" ]]; then
      pass "Directory exists: $dir"
    else
      fail "Missing directory: $dir"
    fi
  done

  # Phase directories (00 through 13 = 14 directories).
  local phases=(
    "phase-00-docker-setup"
    "phase-01-mermaid-cli"
    "phase-02-enterprise-theme"
    "phase-03-battle-test"
    "phase-04-syntax-validation"
    "phase-05-claude-skill"
    "phase-06-auto-render-hook"
    "phase-07-github-rendering"
    "phase-08-pdf-pipeline"
    "phase-09-html-embedding"
    "phase-10-vega-lite"
    "phase-11-d2-diagrams"
    "phase-12-mcp-evaluation"
    "phase-13-validation-cleanup"
  )

  for phase in "${phases[@]}"; do
    # Directory itself must exist.
    if [[ -d "$REPO_ROOT/$phase" ]]; then
      pass "Phase directory exists: $phase"
    else
      fail "Missing phase directory: $phase"
      continue  # Skip sub-checks if the directory is missing.
    fi

    # Each phase must have a README.md.
    if [[ -f "$REPO_ROOT/$phase/README.md" ]]; then
      pass "README.md exists: $phase/README.md"
    else
      fail "Missing README.md: $phase/README.md"
    fi

    # Every phase except phase-12 must have a configs/ subdir.
    if [[ "$phase" != "phase-12-mcp-evaluation" ]]; then
      if [[ -d "$REPO_ROOT/$phase/configs" ]]; then
        pass "configs/ exists: $phase/configs/"
      else
        fail "Missing configs/ subdir: $phase/configs/"
      fi
    fi
  done
}

# ======================================================================
# 2. Bash syntax lint
#    Run `bash -n` (syntax-only check) on every .sh file.
# ======================================================================
check_bash_syntax() {
  echo ""
  echo "=== 2. Bash syntax lint ==="

  # Find all .sh files in the repo.
  local sh_files
  sh_files=$(find "$REPO_ROOT" -name "*.sh" -type f)

  if [[ -z "$sh_files" ]]; then
    pass "No .sh files found (nothing to lint)"
    return
  fi

  while IFS= read -r file; do
    # bash -n only parses, never executes.
    if bash -n "$file" 2>/dev/null; then
      pass "Syntax OK: ${file#"$REPO_ROOT"/}"
    else
      fail "Syntax error: ${file#"$REPO_ROOT"/}"
    fi
  done <<< "$sh_files"
}

# ======================================================================
# 3. Shebang check
#    Every .sh file must start with #!/usr/bin/env bash.
# ======================================================================
check_shebangs() {
  echo ""
  echo "=== 3. Shebang check ==="

  local sh_files
  sh_files=$(find "$REPO_ROOT" -name "*.sh" -type f)

  if [[ -z "$sh_files" ]]; then
    pass "No .sh files found (nothing to check)"
    return
  fi

  while IFS= read -r file; do
    # Read the first line of the file.
    local first_line
    first_line=$(head -n 1 "$file")

    if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
      pass "Shebang OK: ${file#"$REPO_ROOT"/}"
    else
      fail "Bad/missing shebang: ${file#"$REPO_ROOT"/} (got: $first_line)"
    fi
  done <<< "$sh_files"
}

# ======================================================================
# 4. Executable bit check
#    Every .sh file must have the executable permission set.
# ======================================================================
check_executable_bits() {
  echo ""
  echo "=== 4. Executable bit check ==="

  local sh_files
  sh_files=$(find "$REPO_ROOT" -name "*.sh" -type f)

  if [[ -z "$sh_files" ]]; then
    pass "No .sh files found (nothing to check)"
    return
  fi

  while IFS= read -r file; do
    if [[ -x "$file" ]]; then
      pass "Executable: ${file#"$REPO_ROOT"/}"
    else
      fail "Not executable: ${file#"$REPO_ROOT"/}"
    fi
  done <<< "$sh_files"
}

# ======================================================================
# 5. Secrets scan
#    Look for common API key prefixes that should never be committed.
# ======================================================================
check_secrets() {
  echo ""
  echo "=== 5. Secrets scan ==="

  # Patterns that suggest hardcoded secrets.
  local patterns=(
    "sk-[a-zA-Z0-9]{20,}"    # OpenAI / Stripe secret keys
    "ghp_[a-zA-Z0-9]{36,}"   # GitHub personal access tokens
    "gho_[a-zA-Z0-9]{36,}"   # GitHub OAuth tokens
    "AKIA[A-Z0-9]{16,}"      # AWS access key IDs
  )

  # Files to exclude from scanning.
  local exclude_files=(".gitignore" "validate-repo.sh")

  local found_secrets=false

  for pattern in "${patterns[@]}"; do
    # Use grep -rE to search recursively. Exclude specific files.
    local grep_args=("-rE" "$pattern" "$REPO_ROOT")
    for excl in "${exclude_files[@]}"; do
      grep_args=("--exclude=$excl" "${grep_args[@]}")
    done

    # Run grep; if it finds matches, that is a failure.
    local matches
    if matches=$(grep "${grep_args[@]}" 2>/dev/null); then
      found_secrets=true
      # Report each match.
      while IFS= read -r match; do
        local relative_path="${match%%:*}"
        relative_path="${relative_path#"$REPO_ROOT"/}"
        fail "Possible secret ($pattern) in: $relative_path"
      done <<< "$matches"
    fi
  done

  if [[ "$found_secrets" == false ]]; then
    pass "No hardcoded secrets detected"
  fi
}

# ======================================================================
# 6. Config .example check
#    Phase dirs (except phase-12) with configs/ must have >= 1 .example file.
# ======================================================================
check_config_examples() {
  echo ""
  echo "=== 6. Config .example check ==="

  local phases=(
    "phase-00-docker-setup"
    "phase-01-mermaid-cli"
    "phase-02-enterprise-theme"
    "phase-03-battle-test"
    "phase-04-syntax-validation"
    "phase-05-claude-skill"
    "phase-06-auto-render-hook"
    "phase-07-github-rendering"
    "phase-08-pdf-pipeline"
    "phase-09-html-embedding"
    "phase-10-vega-lite"
    "phase-11-d2-diagrams"
    "phase-13-validation-cleanup"
  )

  for phase in "${phases[@]}"; do
    local configs_dir="$REPO_ROOT/$phase/configs"

    # Only check phases whose configs/ directory exists.
    if [[ ! -d "$configs_dir" ]]; then
      # Structure check already flagged this; skip here to avoid double-counting.
      continue
    fi

    # Count .example files in the configs/ directory.
    local example_count
    example_count=$(find "$configs_dir" -maxdepth 1 -name "*.example" -type f | wc -l)

    if [[ "$example_count" -gt 0 ]]; then
      pass "Has .example file(s): $phase/configs/ ($example_count found)"
    else
      fail "No .example files: $phase/configs/"
    fi
  done
}

# ======================================================================
# 7. Diagram source check
#    Verify all expected diagram files exist in diagrams/.
# ======================================================================
check_diagram_sources() {
  echo ""
  echo "=== 7. Diagram source check ==="

  local expected_files=(
    "system-architecture.d2"
    "threshold-escalation.mmd"
    "token-economics.vl.json"
    "before-after-workflow.mmd"
    "config-hierarchy.mmd"
    "phase-dependencies.mmd"
    "decision-matrix.vl.json"
    "gantt-timeline.mmd"
    "error-resolution.mmd"
    "inventory-table.md"
  )

  for file in "${expected_files[@]}"; do
    if [[ -f "$REPO_ROOT/diagrams/$file" ]]; then
      pass "Diagram exists: diagrams/$file"
    else
      fail "Missing diagram: diagrams/$file"
    fi
  done
}

# ======================================================================
# 8. Internal markdown link validation
#    Find relative links in .md files and verify the targets exist.
# ======================================================================
check_markdown_links() {
  echo ""
  echo "=== 8. Internal markdown link validation ==="

  # Find all markdown files in the repo.
  local md_files
  md_files=$(find "$REPO_ROOT" -name "*.md" -type f)

  if [[ -z "$md_files" ]]; then
    pass "No .md files found (nothing to check)"
    return
  fi

  local link_count=0

  while IFS= read -r md_file; do
    # Directory containing this markdown file (for resolving relative paths).
    local md_dir
    md_dir=$(dirname "$md_file")

    # Extract relative links: ](path) where path does NOT start with http or #.
    # Uses grep to find the pattern, then sed to extract the path portion.
    local links
    links=$(grep -oE '\]\([^)]+\)' "$md_file" 2>/dev/null | \
            sed 's/^\](//' | sed 's/)$//' | \
            grep -v '^http' | grep -v '^#' || true)

    if [[ -z "$links" ]]; then
      continue  # No relative links in this file.
    fi

    while IFS= read -r link; do
      # Strip any anchor fragment (e.g., path/to/file.md#section).
      local target="${link%%#*}"

      # Skip empty targets (pure anchor links that slipped through).
      if [[ -z "$target" ]]; then
        continue
      fi

      link_count=$((link_count + 1))

      # Resolve the link relative to the markdown file's directory.
      local resolved="$md_dir/$target"

      if [[ -e "$resolved" ]]; then
        pass "Link OK: ${md_file#"$REPO_ROOT"/} -> $link"
      else
        fail "Broken link: ${md_file#"$REPO_ROOT"/} -> $link"
      fi
    done <<< "$links"
  done <<< "$md_files"

  if [[ "$link_count" -eq 0 ]]; then
    pass "No relative links found to validate"
  fi
}

# ======================================================================
# Run all checks.
# ======================================================================
echo "============================================"
echo "  Repository Validation"
echo "  Platform: $PLATFORM"
echo "  Repo root: $REPO_ROOT"
echo "============================================"

check_structure
check_bash_syntax
check_shebangs
check_executable_bits
check_secrets
check_config_examples
check_diagram_sources
check_markdown_links

# ======================================================================
# Summary
# ======================================================================
echo ""
echo "============================================"
echo "  Summary"
echo "  Total checks: $TOTAL"
echo "  Passed:       $PASSED"
echo "  Failed:       $FAILED"
echo "============================================"

if [[ "$FAILED" -gt 0 ]]; then
  echo "RESULT: FAIL -- $FAILED check(s) did not pass."
  exit 1
else
  echo "RESULT: ALL CHECKS PASSED"
  exit 0
fi
