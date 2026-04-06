# Reference Tables

## Installed Tools Summary

| Tool | Install Command | Purpose |
|---|---|---|
| Docker (mermaid-cli) | `docker pull minlag/mermaid-cli` | Mermaid -> SVG/PNG |
| @probelabs/maid | `sudo npm install -g @probelabs/maid` | Syntax validation (1-2ms) |
| Vega-Lite + vega-cli | `sudo npm install -g vega-lite vega-cli vega` | Heatmaps, bar charts |
| canvas | `sudo npm install -g canvas` | Vega-Lite PNG rendering |
| D2 | `curl -fsSL https://d2lang.com/install.sh \| sh` | Architecture diagrams |
| libasound2t64 | `sudo apt-get install -y libasound2t64` | D2 PNG (Playwright dep) |
| Pandoc | `sudo apt-get install -y pandoc` | Markdown -> PDF/HTML |
| jq | `sudo apt-get install -y jq` | JSON parsing in hooks |

## Custom Scripts Summary

| Script | Location | Purpose |
|---|---|---|
| mermaid-render | ~/bin/ | Docker wrapper for mmdc |
| mermaid-render-dark | ~/bin/ | Dark theme variant |
| mermaid-validate | ~/bin/ | Validate then render |
| vegalite-render | ~/bin/ | Vega-Lite JSON -> SVG/PNG |
| d2-render | ~/bin/ | D2 -> SVG/PNG with ELK layout |
| render-all-diagrams | ~/bin/ | Batch render entire diagrams/ |
| mermaid-pdf | ~/bin/ | Markdown+Mermaid -> PDF/HTML |

## File Naming Conventions

| Extension | Tool | Tracked in Git? |
|---|---|---|
| .mmd | Mermaid source | Yes -- diffable text |
| .vl.json | Vega-Lite spec | Yes -- diffable JSON |
| .d2 | D2 source | Yes -- diffable text |
| .svg | Rendered output | No -- generated artifact |
| .png | Rendered output | No -- generated artifact |

## Diagram-to-Tool Assignment Matrix

| # | Diagram | Tool | Source File |
|---|---|---|---|
| 1 | System Architecture | D2 | system-architecture.d2 |
| 2 | Threshold Escalation | Mermaid | threshold-escalation.mmd |
| 3 | Token Economics | Vega-Lite | token-economics.vl.json |
| 4 | Before/After Workflow | Mermaid | before-after-workflow.mmd |
| 5 | Config File Hierarchy | Mermaid | config-hierarchy.mmd |
| 6 | Phase Dependency Graph | Mermaid | phase-dependencies.mmd |
| 7 | Decision Matrix Heatmap | Vega-Lite | decision-matrix.vl.json |
| 8 | Gantt Timeline | Mermaid | gantt-timeline.mmd |
| 9 | Error Resolution | Mermaid | error-resolution.mmd |
| 10 | Component Inventory | Markdown | inventory-table.md |
