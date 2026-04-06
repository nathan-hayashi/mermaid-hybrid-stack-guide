# Phase 8: PDF Integration Pipeline

**Time estimate: 20 minutes**

## Why

ReportLab and similar Python PDF libraries generate charts as matplotlib PNGs
at screen resolution (~96 DPI). When these land in a printed or exported PDF,
text inside diagrams becomes blurry and lines lose their crispness. Replacing
those images with Mermaid-rendered PNGs at 3x scale (~288 DPI equivalent)
produces significantly sharper output with no change to the surrounding report
structure.

This phase also wires up pandoc for markdown-to-PDF conversion with a table of
contents and reasonable geometry, which is useful for runbooks, design docs,
and architecture decision records that contain embedded diagrams.

## Architecture

```
.mmd files
    |
    v
mermaid-render *.mmd *.svg     (vector, GitHub/web use)
mermaid-render *.mmd *.png -s 3  (3x raster, PDF/print use)
    |
    v
pandoc document.md --> document.pdf
    (embeds the 3x PNGs; falls back to HTML if LaTeX absent)
```

## Steps

### 1. Install pandoc

```bash
bash phase-08-pdf-pipeline/install-pandoc.sh
```

Note: LaTeX (~2 GB) is NOT installed by this script. The pandoc PDF route
used here goes through HTML (wkhtmltopdf or weasyprint), which is much smaller
and produces acceptable output for technical documents.

### 2. Create the batch render script

```bash
bash phase-08-pdf-pipeline/create-batch-render.sh
```

This creates `~/bin/render-all-diagrams` which batch-renders every `.mmd` file
in the current directory to SVG and 3x PNG.

### 3. Create the PDF wrapper

```bash
bash phase-08-pdf-pipeline/create-pdf-script.sh
```

Creates `~/bin/mermaid-pdf` -- a pandoc wrapper that converts a markdown file
to PDF, embedding rendered diagram PNGs.

### 4. Smoke-test the pipeline

```bash
bash phase-08-pdf-pipeline/test-pdf-pipeline.sh
```

Creates a test markdown file referencing a diagram, renders the diagram, and
converts the markdown to PDF.

## Gate / PASS Criteria

- [ ] `pandoc --version` prints a version string
- [ ] `~/bin/render-all-diagrams` exists and is executable
- [ ] `~/bin/mermaid-pdf` exists and is executable
- [ ] Running `mermaid-pdf test.md` produces `test.pdf` without errors
- [ ] The PDF contains a diagram image (open and visually verify)
- [ ] Diagram PNG is at 3x scale (check with `identify -verbose *.png | grep Resolution`)

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
