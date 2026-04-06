# Phase 13: Full Validation and Cleanup

**Time estimate:** 30 minutes

## Why

After 13 phases, the setup is complete. This phase confirms everything works end-to-end
and removes test artifacts that should not be committed to the repository.

Infrastructure -- scripts in `~/bin/`, the global Claude skill, `settings.json` hooks,
and enterprise themes -- lives outside the repo and persists across clones and
reinstalls. It does not need to be in source control.

What belongs in the repo: diagram source files (`.mmd`, `.vl.json`, `.d2`) and their
rendered outputs (`.svg`, `.png`). What does not: test artifacts, local settings
overrides, and scratch diagrams.

## Steps

1. Create the batch render script for iterating an entire diagrams directory:

   ```bash
   ./create-batch-script.sh
   ```

2. Run full validation -- counts sources and rendered outputs:

   ```bash
   ./run-validation.sh
   ```

3. Review cleanup instructions (printed, not executed):

   ```bash
   ./cleanup-instructions.sh
   ```

4. Follow the steps in `configs/cleanup-checklist.example` before committing.

## Gate / PASS Criteria

- [ ] `render-all-diagrams` is on PATH and renders at least one diagram
- [ ] `run-validation.sh` reports matching counts for sources and outputs
      (every `.mmd` has a corresponding `.svg`)
- [ ] No test artifacts remain in the `diagrams/` directory
- [ ] `.claude/settings.local.json` is in `.gitignore` (not committed)
- [ ] `git status` is clean (or shows only intentional changes)

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
