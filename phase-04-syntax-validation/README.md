# Phase 4: Syntax Validation with @probelabs/maid

**Time estimate: 5 minutes**

## Why

Mermaid diagrams fail silently at render time -- a missing semicolon or a quoted
pipe edge label sends Chromium spinning for 3-5 seconds before returning a blank
image. `@probelabs/maid` catches these errors in 1-2 ms without launching
Chromium at all. Its error messages are structured (JSON-serialisable) which
makes them easy for Claude Code to parse and self-repair in the same turn.

This phase wires maid into a `mermaid-validate` wrapper so the validation step
runs automatically before every render call.

## Steps

### 1. Install maid globally

```bash
bash phase-04-syntax-validation/install-maid.sh
```

Verify the install:

```bash
maid --version
```

### 2. Create the validate wrapper

```bash
bash phase-04-syntax-validation/create-validate-wrapper.sh
```

This puts `mermaid-validate` in `~/bin/` so the PostToolUse hook (Phase 6) can
call it without a full path.

### 3. Run the test suite

```bash
bash phase-04-syntax-validation/test-validation.sh
```

You should see:

- Valid diagram: `PASS -- validation succeeded`
- Broken diagram: `PASS -- validation correctly rejected broken syntax`

## Gate / PASS Criteria

- [ ] `maid --version` prints a version string without error
- [ ] `~/bin/mermaid-validate` exists and is executable
- [ ] Running `mermaid-validate` on a valid `.mmd` file exits 0
- [ ] Running `mermaid-validate` on `configs/broken-test.mmd.example` exits 1
      and prints "Validation failed. Fix syntax before rendering."

## Syntax Reference

| Context | Correct | Wrong |
|---|---|---|
| Node label | `A["My Label"]` | `A[My Label]` |
| Edge label | `A -->|Score| B` | `A -->|"Score"| B` |
| Line break in label | `A["Line1<br/>Line2"]` | `A["Line1\nLine2"]` |
| Node ID | `myNode` | `my-node` |

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
