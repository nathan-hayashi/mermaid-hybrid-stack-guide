# Phase 6: PostToolUse Hook -- Auto-Render on Write

**Time estimate: 10 minutes**

## Why

Without automation, every diagram edit is a three-step loop: write file, run
maid, run mermaid-render. The PostToolUse hook closes that loop -- Claude Code
triggers it automatically whenever the Write tool saves a `.mmd` file. The
result is that every diagram write produces an up-to-date SVG and PNG with no
manual intervention.

## Three Requirements (read before editing settings.json manually)

1. **`bash -c` wrapper** -- Hooks may execute in `sh`, which lacks `[[`, process
   substitution, and other bash features. Wrapping in `bash -c '...'` guarantees
   the hook always runs in bash.

2. **`export PATH`** -- The hook runs in a minimal environment where `~/bin` is
   not in `PATH`. Without the explicit export, `maid` and `mermaid-render` are
   not found even if they work fine in your interactive shell.

3. **POSIX `case/esac` not `[[ ]]`** -- The outer shell before the `bash -c`
   wrapper may be POSIX sh. Use `case "$FILE" in *.mmd)` for the file-extension
   check, not `[[ "$FILE" == *.mmd ]]`.

## CRITICAL: Merge, Never Overwrite

`create-hook.sh` and `add-permissions.sh` both use `jq` to merge into your
existing `~/.claude/settings.json`. They never replace the file wholesale.
Running them on an existing settings file is safe and idempotent.

## Steps

### 1. Install the PostToolUse hook

```bash
bash phase-06-auto-render-hook/create-hook.sh
```

### 2. Add tool permissions

```bash
bash phase-06-auto-render-hook/add-permissions.sh
```

### 3. Verify settings.json is valid

```bash
bash phase-06-auto-render-hook/test-hook.sh
```

### 4. Smoke-test the hook

Write any `.mmd` file in a Claude Code session and confirm that a matching `.svg`
and `.png` appear in the same directory within ~60 seconds (Docker cold-start
budget).

## Gate / PASS Criteria

- [ ] `jq . ~/.claude/settings.json` exits 0 (valid JSON)
- [ ] `jq '.hooks.PostToolUse' ~/.claude/settings.json` shows the Write matcher
- [ ] Writing a `.mmd` file in Claude Code produces a `.svg` and `.png` automatically
- [ ] A broken `.mmd` file does NOT produce output (maid exits non-zero, render is skipped)

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
