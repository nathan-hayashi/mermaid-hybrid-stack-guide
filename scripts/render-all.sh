#!/usr/bin/env bash
# render-all.sh -- Batch renders all diagram source files.
# Dispatches to the correct tool based on file extension.
#
# Usage: ./scripts/render-all.sh [directory]
#   directory  Optional path to diagram sources (defaults to diagrams/ in repo root).
#
# Supported formats:
#   .mmd      -> mermaid-render  (SVG + PNG at 3x scale)
#   .vl.json  -> vegalite-render (SVG + PNG)
#   .d2       -> d2-render       (SVG + PNG)
#   .md       -> skipped (not renderable)

set -euo pipefail

# Load platform detection (sets PLATFORM, IS_WSL, etc.)
source "$(dirname "$0")/platform-detect.sh"

# ──────────────────────────────────────────────────────────────────────
# Repo root is one level up from the scripts/ directory.
# ──────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Target directory: use the first argument if provided, otherwise diagrams/.
TARGET_DIR="${1:-$REPO_ROOT/diagrams}"

# Resolve to an absolute path for consistency.
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ──────────────────────────────────────────────────────────────────────
# Counters for the final summary.
# ──────────────────────────────────────────────────────────────────────
PROCESSED=0
SUCCEEDED=0
SKIPPED=0
FAILURES=0

# ──────────────────────────────────────────────────────────────────────
# Tool availability checks.
# We check once at startup so we can skip entire file types cleanly.
# ──────────────────────────────────────────────────────────────────────
HAS_MERMAID=false
HAS_VEGALITE=false
HAS_D2=false

if command -v mermaid-render &>/dev/null; then
  HAS_MERMAID=true
else
  echo "WARNING: mermaid-render not found in PATH. .mmd files will be skipped."
fi

if command -v vegalite-render &>/dev/null; then
  HAS_VEGALITE=true
else
  echo "WARNING: vegalite-render not found in PATH. .vl.json files will be skipped."
fi

if command -v d2-render &>/dev/null; then
  HAS_D2=true
else
  echo "WARNING: d2-render not found in PATH. .d2 files will be skipped."
fi

# ======================================================================
# render_file -- Dispatch a single file to the appropriate renderer.
#   $1 = full path to the source file.
# ======================================================================
render_file() {
  local file="$1"
  local basename
  basename=$(basename "$file")
  local relative="${file#"$REPO_ROOT"/}"

  # Determine file type by extension and dispatch.
  # Check .vl.json first since it contains .json which could match other rules.
  if [[ "$basename" == *.vl.json ]]; then
    # Vega-Lite specification file.
    if [[ "$HAS_VEGALITE" == true ]]; then
      echo "  Rendering (vegalite): $relative"
      if vegalite-render "$file"; then
        SUCCEEDED=$((SUCCEEDED + 1))
      else
        echo "    ERROR: vegalite-render failed for $relative"
        FAILURES=$((FAILURES + 1))
      fi
    else
      echo "  Skipping (no vegalite-render): $relative"
      SKIPPED=$((SKIPPED + 1))
    fi

  elif [[ "$basename" == *.mmd ]]; then
    # Mermaid diagram file.
    if [[ "$HAS_MERMAID" == true ]]; then
      echo "  Rendering (mermaid, -s 3): $relative"
      if mermaid-render "$file" -s 3; then
        SUCCEEDED=$((SUCCEEDED + 1))
      else
        echo "    ERROR: mermaid-render failed for $relative"
        FAILURES=$((FAILURES + 1))
      fi
    else
      echo "  Skipping (no mermaid-render): $relative"
      SKIPPED=$((SKIPPED + 1))
    fi

  elif [[ "$basename" == *.d2 ]]; then
    # D2 diagram file.
    if [[ "$HAS_D2" == true ]]; then
      echo "  Rendering (d2): $relative"
      if d2-render "$file"; then
        SUCCEEDED=$((SUCCEEDED + 1))
      else
        echo "    ERROR: d2-render failed for $relative"
        FAILURES=$((FAILURES + 1))
      fi
    else
      echo "  Skipping (no d2-render): $relative"
      SKIPPED=$((SKIPPED + 1))
    fi

  elif [[ "$basename" == *.md ]]; then
    # Markdown files are not renderable diagram sources.
    echo "  Skipping (markdown): $relative"
    SKIPPED=$((SKIPPED + 1))

  else
    # Unrecognized extension.
    echo "  Skipping (unsupported format): $relative"
    SKIPPED=$((SKIPPED + 1))
  fi
}

# ======================================================================
# Main: iterate over every file in the target directory.
# ======================================================================
echo "============================================"
echo "  Batch Diagram Renderer"
echo "  Platform: $PLATFORM"
echo "  Source dir: $TARGET_DIR"
echo "============================================"
echo ""

# Verify the target directory exists.
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: Directory not found: $TARGET_DIR"
  exit 1
fi

# Process each file in the directory (non-recursive, top-level only).
for file in "$TARGET_DIR"/*; do
  # Skip if the glob matched nothing (empty directory).
  [[ -e "$file" ]] || continue

  # Skip subdirectories.
  [[ -f "$file" ]] || continue

  PROCESSED=$((PROCESSED + 1))
  render_file "$file"
done

# ======================================================================
# Summary
# ======================================================================
echo ""
echo "============================================"
echo "  Summary"
echo "  Files processed: $PROCESSED"
echo "  Succeeded:       $SUCCEEDED"
echo "  Skipped:         $SKIPPED"
echo "  Failed:          $FAILURES"
echo "============================================"

if [[ "$FAILURES" -gt 0 ]]; then
  echo "RESULT: $FAILURES file(s) failed to render."
  exit 1
else
  echo "RESULT: All renderable files processed successfully."
  exit 0
fi
