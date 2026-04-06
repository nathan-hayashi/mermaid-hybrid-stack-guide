# Interactive Tutorial: Diagram-as-Code with Dogs & Cats

Welcome to the hands-on tutorial for the Mermaid Hybrid Stack. You will build a complete
diagram-as-code workflow from scratch using a fun pets theme -- flowcharts, data charts,
and architecture blueprints, all version-controlled and AI-assisted.

---

## Prerequisites

Before starting, make sure you have completed the following:

- **Phase 0-1 complete** -- Docker is running, `mermaid-render` is installed and working
- **Terminal access** -- a shell where you can run commands
- **Text editor** -- VS Code, Neovim, or any editor you prefer

To verify your environment is ready:

```bash
mermaid-render --version
docker ps
```

---

## Time Estimate

**2-3 hours** for all 7 exercises. Each exercise is self-contained but builds on the
previous one. You can pause and resume at any exercise boundary.

---

## Overview

This tutorial walks you through the entire Mermaid Hybrid Stack pipeline using a pets
theme. By the end, you will have:

- A version-controlled project with Mermaid, Vega-Lite, and D2 source files
- An AI-assisted workflow where Claude generates diagrams and they auto-render
- A GitHub-hosted README with live diagram previews
- A full pipeline test validating every output

---

## Exercises

| # | Title | Phase | Description |
|---|-------|-------|-------------|
| 01 | [Hello Diagrams](01-hello-diagrams.md) | Phase 0-1 | Write your first flowchart and render it to SVG |
| 02 | [Theme Your Kennel](02-theme-your-kennel.md) | Phase 2 | Apply light and dark enterprise themes |
| 03 | [Validate the Litter](03-validate-the-litter.md) | Phase 3-4 | Introduce deliberate syntax errors and fix them |
| 04 | [Teach Claude to Draw](04-teach-claude-to-draw.md) | Phase 5-6 | Use the AI skill and PostToolUse hook |
| 05 | [Publish to GitHub](05-publish-to-github.md) | Phase 7 | Version-control source files, push to GitHub |
| 06 | [Data Charts & Blueprints](06-data-charts-and-blueprints.md) | Phase 10-11 | Vega-Lite bar charts and D2 architecture diagrams |
| 07 | [Full Pipeline Test](07-full-pipeline-test.md) | Phase 13 | Run `render-all-diagrams` and verify every output |

---

## Important Note

Each exercise builds on the previous one. The project directory (`~/projects/pets-diagrams`)
and its files accumulate as you progress. Do not skip exercises or the later ones may
reference files that do not exist yet.

If you need a clean starting point for any exercise, the `assets/sample-project/`
directory in this repo contains reference copies of the key source files.
