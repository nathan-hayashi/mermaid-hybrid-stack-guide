# Phase 10: Vega-Lite -- Heatmaps and Data Charts

**Time estimate:** 15 minutes

## Why

Mermaid cannot produce heatmaps or grouped bar charts. Vega-Lite is the only free,
declarative, text-based tool for these at enterprise quality. You write a JSON spec
describing your data and visual encoding -- Vega-Lite handles layout, scales, axes,
and legends automatically. This makes complex charts as version-controllable and
reproducible as Mermaid diagrams, while covering the data visualization gap Mermaid
leaves behind.

Vega-Lite is especially useful for:
- Heatmaps (e.g., tool usage frequency by week)
- Grouped and stacked bar charts
- Scatter plots with custom color encoding
- Multi-series line charts from structured data

## Steps

1. Install Vega-Lite, Vega CLI, and the canvas rendering dependency:

   ```bash
   ./install-vega.sh
   ```

   Note: the `canvas` package is required for PNG output. SVG works without it.
   If the canvas install fails, SVG rendering will still work.

2. Create the `vegalite-render` wrapper script in `~/bin/`:

   ```bash
   ./create-vega-wrapper.sh
   ```

3. Verify everything works by rendering a test chart:

   ```bash
   ./test-vega.sh
   ```

4. Write your own Vega-Lite specs using `configs/vega-spec.example` as a starting
   point. Name files with the `.vl.json` extension.

5. Render your spec:

   ```bash
   vegalite-render my-chart.vl.json
   ```

   This produces `my-chart.svg` (always) and `my-chart.png` (requires canvas).

## Gate / PASS Criteria

- [ ] `vl2svg --version` prints a version number without error
- [ ] `vegalite-render` is on your PATH (`which vegalite-render` succeeds)
- [ ] `./test-vega.sh` renders a `.svg` output without errors
- [ ] Opening the output SVG in a browser shows a bar chart with labeled axes

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
