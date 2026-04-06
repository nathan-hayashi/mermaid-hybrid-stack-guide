# Phase 2: Enterprise Theme Configuration

**Time estimate: 10 minutes**

## Why a Shared Config?

Without a config file, every `mermaid-render` call uses the default Mermaid
theme. The defaults look fine for quick notes, but they are inconsistent across
mermaid-cli versions and not optimized for documentation or PDF output.

A shared `~/.config/mermaid/config.json` ensures that:
- Every diagram in the repo looks identical
- Colors meet contrast requirements for printed PDFs
- Font stacks use real system fonts (Inter, Segoe UI, Roboto)
- Flowchart spacing is generous enough that labels do not overlap

The `mermaid-render` wrapper created in Phase 1 already checks for this file
and mounts it automatically. You just need to create it.

## What This Phase Creates

| File | Purpose |
|------|---------|
| `~/.config/mermaid/config.json` | Light theme (used by `mermaid-render`) |
| `~/.config/mermaid/config-dark.json` | Dark theme (used by `mermaid-render-dark`) |
| `~/bin/mermaid-render-dark` | Wrapper for dark-theme renders with transparent bg |

## Steps

1. Create both theme config files:
   ```bash
   bash phase-02-enterprise-theme/create-theme.sh
   ```

2. Create the dark-theme render wrapper:
   ```bash
   bash phase-02-enterprise-theme/create-dark-wrapper.sh
   ```

3. Verify both themes render correctly:
   ```bash
   bash phase-02-enterprise-theme/test-themes.sh
   ```

## Gate / PASS Criteria

- `~/.config/mermaid/config.json` exists
- `~/.config/mermaid/config-dark.json` exists
- `~/bin/mermaid-render-dark` exists and is executable
- `test-themes.sh` prints [PASS] for both light and dark renders
- Light SVG and dark SVG have different file sizes (proof they used different configs)

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
