# Exercise 06 -- Data Charts & Blueprints: Beyond Mermaid

**Phase mapping:** Phase 10-11
**Time estimate:** 30-40 minutes

---

## Goal

Use Vega-Lite to create a data-driven bar chart of pet adoption statistics, and D2 to
create an architecture diagram of a pet shelter system. Understand when to reach for each
tool instead of Mermaid.

---

## Part A -- Vega-Lite Bar Chart

### Step 1: Create the adoption stats data file

In your pets project directory, create `adoption-stats.vl.json`:

```json
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Monthly pet adoptions by species",
  "width": 500,
  "height": 300,
  "data": {
    "values": [
      {"month": "Jan", "species": "Dogs", "count": 12},
      {"month": "Jan", "species": "Cats", "count": 8},
      {"month": "Feb", "species": "Dogs", "count": 15},
      {"month": "Feb", "species": "Cats", "count": 10},
      {"month": "Mar", "species": "Dogs", "count": 20},
      {"month": "Mar", "species": "Cats", "count": 14},
      {"month": "Apr", "species": "Dogs", "count": 18},
      {"month": "Apr", "species": "Cats", "count": 16}
    ]
  },
  "mark": "bar",
  "encoding": {
    "x": {
      "field": "month",
      "type": "ordinal",
      "title": "Month",
      "sort": ["Jan", "Feb", "Mar", "Apr"]
    },
    "y": {
      "field": "count",
      "type": "quantitative",
      "title": "Adoptions"
    },
    "color": {
      "field": "species",
      "type": "nominal",
      "scale": {
        "domain": ["Dogs", "Cats"],
        "range": ["#4C72B0", "#DD8452"]
      }
    },
    "xOffset": {
      "field": "species",
      "type": "nominal"
    }
  },
  "title": "Monthly Pet Adoptions (Q1-Q2)"
}
```

### Step 2: Render the chart

```bash
vegalite-render adoption-stats.vl.json
```

This produces `adoption-stats.svg` (or `adoption-stats.png` depending on your Phase 10
configuration). Open it to verify you see a grouped bar chart with blue bars for dogs and
orange bars for cats across the four months.

---

## Part B -- D2 Architecture Diagram

### Step 1: Create the shelter architecture file

Create `shelter-architecture.d2`:

```d2
direction: right

Frontend: "Frontend" {
  Website: "Website"
  MobileApp: "Mobile App"
}

Backend: "Backend" {
  APIServer: "API Server"
  Database: "Database"
}

Services: "Services" {
  AdoptionService: "Adoption Service"
  MedicalRecords: "Medical Records"
  Inventory: "Inventory"
}

Frontend.Website -> Backend.APIServer: "HTTPS"
Frontend.MobileApp -> Backend.APIServer: "HTTPS"
Backend.APIServer -> Backend.Database: "SQL"
Backend.APIServer -> Services.AdoptionService: "gRPC"
Backend.APIServer -> Services.MedicalRecords: "gRPC"
Backend.APIServer -> Services.Inventory: "gRPC"
```

### Step 2: Render the diagram

```bash
d2-render shelter-architecture.d2
```

This produces `shelter-architecture.svg`. Open it to verify you see three labeled groups
(Frontend, Backend, Services) with arrows showing the connection flow between components.

---

## When to use each tool

See also: [TOOL-COMPARISON.md](../TOOL-COMPARISON.md) in the main repo.

| Tool | Best for | Avoid when |
|------|----------|------------|
| **Mermaid** | Flowcharts, sequence diagrams, entity relationships, git graphs, class diagrams | You need precise pixel layout or complex data binding |
| **Vega-Lite** | Data-driven charts (bar, line, scatter, histogram) with real data values | You are drawing process flows or architecture -- use Mermaid or D2 |
| **D2** | System architecture, network topology, infrastructure diagrams with grouped containers | You have tabular data to visualize -- use Vega-Lite |

**Decision rule:** If the content is *data*, use Vega-Lite. If the content is a *process
or flow*, use Mermaid. If the content is a *system with components and connections*, use D2.

---

## Step 3: Add the new source files to git

```bash
git add adoption-stats.vl.json shelter-architecture.d2
git commit -m "feat: add adoption stats chart and shelter architecture diagram"
git push
```

Note: The rendered SVG outputs are still excluded by the gitignore rules.

---

## What you learned

- Vega-Lite uses a JSON grammar to bind data fields to visual channels (position, color, size)
- D2 uses a text-based syntax with `->` edges and `{}` containers for grouped components
- `vegalite-render` and `d2-render` follow the same render-from-source pattern as `mermaid-render`
- Tool choice depends on content type: data, flow, or architecture

---

## Next exercise

[Exercise 07 -- Full Pipeline Test](07-full-pipeline-test.md)
