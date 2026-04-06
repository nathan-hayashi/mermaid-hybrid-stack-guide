# Exercise 07 -- Full Pipeline Test: The Vet Checkup

**Phase mapping:** Phase 13
**Time estimate:** 15-20 minutes

---

## Goal

Run the `render-all-diagrams` command across the entire pets project and verify that every
source file produces a valid rendered output. This is the "vet checkup" -- a full health
test of your pipeline.

---

## Step 1: Confirm your source files are in place

Before running the full pipeline test, list your source files:

```bash
cd ~/projects/pets-diagrams
ls -1 *.mmd *.vl.json *.d2 2>/dev/null
```

Expected output:

```
adoption-stats.vl.json
broken-pets.mmd
cat-adoption.mmd
pets.mmd
shelter-architecture.d2
```

If `cat-adoption.mmd` is missing, go back to [Exercise 04](04-teach-claude-to-draw.md)
and generate it before continuing.

---

## Step 2: Run the full pipeline

```bash
render-all-diagrams
```

This command (installed in Phase 13) discovers all diagram source files in the current
directory tree and renders each one using the appropriate renderer:

- `.mmd` files -- rendered with `mermaid-render`
- `.vl.json` files -- rendered with `vegalite-render`
- `.d2` files -- rendered with `d2-render`

Expected output:

```
Scanning for diagram sources...
Found 3 Mermaid source(s): broken-pets.mmd, cat-adoption.mmd, pets.mmd
Found 1 Vega-Lite source(s): adoption-stats.vl.json
Found 1 D2 source(s): shelter-architecture.d2

Rendering Mermaid: broken-pets.mmd -> broken-pets.svg ... Done
Rendering Mermaid: cat-adoption.mmd -> cat-adoption.svg ... Done
Rendering Mermaid: pets.mmd -> pets.svg ... Done
Rendering Vega-Lite: adoption-stats.vl.json -> adoption-stats.svg ... Done
Rendering D2: shelter-architecture.d2 -> shelter-architecture.svg ... Done

5 source(s) rendered. 0 error(s).
```

---

## Step 3: Verify all outputs

Check that every source file has a corresponding rendered output:

```bash
ls -1 *.svg 2>/dev/null
```

Expected output:

```
adoption-stats.svg
broken-pets.svg
cat-adoption.svg
pets.svg
shelter-architecture.svg
```

That is 5 source files and 5 corresponding SVG outputs.

---

## Step 4: Count source files vs rendered outputs

```bash
echo "Source files:"
ls *.mmd *.vl.json *.d2 2>/dev/null | wc -l

echo "Rendered outputs:"
ls *.svg 2>/dev/null | wc -l
```

Expected:

```
Source files:
5
Rendered outputs:
5
```

The counts should match. If any SVG is missing, check the `render-all-diagrams` output
for errors on that file's render step.

---

## Step 5: Clean up test artifacts

The `broken-pets.mmd` file was created in Exercise 03 for error demonstration. You can
remove it and its rendered output now that the tutorial is complete:

```bash
rm broken-pets.mmd broken-pets.svg
```

Verify the cleanup:

```bash
ls *.mmd *.svg
# Expected: cat-adoption.mmd  cat-adoption.svg  pets.mmd  pets.svg
```

---

## Congratulations

You have completed the full Mermaid Hybrid Stack tutorial. Here is what you built:

- A version-controlled diagram project with Mermaid, Vega-Lite, and D2 sources
- An AI-assisted workflow with Claude generating valid diagram source files
- A PostToolUse hook that auto-renders diagrams on every write
- A GitHub-hosted README with live Mermaid previews
- A `render-all-diagrams` pipeline that regenerates all outputs from source

---

## Next steps

- Read the full phase documentation in the [main repo](../README.md) to explore phases
  you did not configure during this tutorial (Phase 8 PDF export, Phase 9 CI/CD, Phase 12
  changelog automation)
- Explore the [TOOL-COMPARISON.md](../TOOL-COMPARISON.md) guide to deepen your
  understanding of when to use each renderer
- Add new diagrams to your own projects using the same workflow
- Share your pets project repo as a portfolio example

---

## Summary: Pipeline at a glance

```
Source file (.mmd / .vl.json / .d2)
        |
        v
   [render command]
        |
        v
  Rendered output (.svg / .png / .pdf)
        |
        +-- Committed to git? NO (gitignored)
        |
Source file committed? YES
```

The source is the truth. The output is a build artifact.
