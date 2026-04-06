# Tool Comparison: Mermaid vs Vega-Lite vs D2

## Why Three Tools?

No single tool covers all diagram types. Mermaid excels at flowcharts but can't do heatmaps. Vega-Lite excels at data charts but can't do flowcharts. D2 excels at nested architecture layouts that Mermaid's dagre engine handles poorly.

## Decision Matrix

| Diagram Type | Mermaid | Vega-Lite | D2 |
|---|---|---|---|
| Flowcharts | Best | Cannot | Possible |
| Sequence Diagrams | Best | Cannot | Cannot |
| Gantt Charts | Best | Possible | Cannot |
| Heatmaps | Cannot | Best | Cannot |
| Bar/Line Charts | Cannot | Best | Cannot |
| Architecture (nested) | Poor | Cannot | Best |
| State Diagrams | Best | Cannot | Possible |
| ER Diagrams | Best | Cannot | Possible |
| Class Diagrams | Best | Cannot | Possible |

## Comparison Table

| Feature | Mermaid | Vega-Lite | D2 |
|---|---|---|---|
| Input Format | .mmd (text) | .vl.json (JSON) | .d2 (text) |
| Rendering Engine | Chromium (via Docker) | Node.js (vega-cli) | Playwright/ELK |
| GitHub Native | Yes (```mermaid blocks) | No | No |
| Cost | Free (MIT) | Free (BSD) | Free (ELK) / $240/yr (TALA) |
| Learning Curve | Low | Medium | Medium |
| Output Formats | SVG, PNG, PDF | SVG, PNG | SVG, PNG |
| Validation Tool | @probelabs/maid | vl2svg (built-in) | d2 (built-in) |

## Quick Reference

One-liner routing rules:

- Flowcharts, sequences, Gantt -> Mermaid (.mmd)
- Heatmaps, grouped bars, data charts -> Vega-Lite (.vl.json)
- Multi-layer architectures -> D2 (.d2)
