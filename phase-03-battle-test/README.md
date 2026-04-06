# Phase 3: Battle Test -- Threshold Escalation Flowchart

**Time estimate: 20 minutes**

## Why This Specific Diagram?

The threshold escalation flowchart from the Definitive Runbook is the most
structurally demanding diagram in the series. It has:

- A fan-out pattern (one node feeding four parallel scoring nodes)
- A fan-in pattern (four nodes merging back into one sum node)
- Diamond decision nodes with labeled edges using special characters (<=, >=)
- Nested labels with line breaks (`<br/>`)
- Two separate routing decision points

If this diagram renders cleanly -- with no label truncation, no overlapping
nodes, no broken edges -- then the Docker + config + wrapper stack is validated
for all remaining diagrams in the runbook.

This is the "does the car actually drive?" test before you take it on the highway.

## What This Phase Creates

| File | Purpose |
|------|---------|
| `diagrams/threshold-escalation.mmd` | Full scoring flowchart source |
| `diagrams/threshold-escalation.svg` | Rendered light SVG (after running the script) |
| `diagrams/threshold-escalation.png` | Rendered 3x PNG (after running the script) |

## Steps

1. Create the diagram source file:
   ```bash
   bash phase-03-battle-test/create-test-diagram.sh
   ```

2. Render to SVG and PNG, then compare visually with the runbook PDF:
   ```bash
   bash phase-03-battle-test/render-and-compare.sh
   ```

## Gate / PASS Criteria

- `diagrams/threshold-escalation.svg` exists and is non-empty
- `diagrams/threshold-escalation.png` exists and is non-empty
- Visual inspection confirms the diagram matches the runbook PDF layout:
  - START → PARSE → SCORE fan-out to S1/S2/S3/S4 → SUM fan-in → ROUTE
  - Three output tiers with correct threshold labels on edges
  - No overlapping nodes or truncated labels

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
