# Exercise 02 -- Theme Your Kennel: Enterprise Styling

**Phase mapping:** Phase 2
**Time estimate:** 20-30 minutes

---

## Goal

Apply enterprise-grade light and dark themes to your pets diagram and understand what each
theme variable controls.

---

## Step 1: Locate the enterprise theme config

The Phase 2 setup installed theme configuration files. Verify they exist:

```bash
ls ~/.config/mermaid/
# Expected output:
# theme-light.json
# theme-dark.json
```

If the files are missing, re-run the Phase 2 setup script from the main repo:

```bash
bash ~/projects/mermaid-hybrid-stack/scripts/02-install-themes.sh
```

---

## Step 2: Render with the light theme

From your pets project directory:

```bash
cd ~/projects/pets-diagrams
mermaid-render pets.mmd pets-light.svg
```

The `mermaid-render` command uses the light theme by default. The output is `pets-light.svg`.

---

## Step 3: Render with the dark theme

Use the dark-theme variant of the render command:

```bash
mermaid-render-dark pets.mmd pets-dark.svg
```

The output is `pets-dark.svg`.

---

## Step 4: Compare both SVGs side by side

Open both files to compare them:

```bash
xdg-open pets-light.svg &
xdg-open pets-dark.svg &
```

You should observe:

| Property | Light Theme | Dark Theme |
|----------|-------------|------------|
| Background | White / off-white | Dark gray / near-black |
| Node fill | Light blue / neutral | Darker tinted fill |
| Node border | Medium gray | Lighter gray or accent color |
| Text | Near-black | Near-white |
| Edge arrows | Dark gray | Light gray |

---

## Step 5: Understand the theme variables

Open `~/.config/mermaid/theme-light.json` in your editor. Key variables:

```jsonc
{
  "theme": "base",
  "themeVariables": {
    "primaryColor": "#...",        // Node fill color
    "primaryBorderColor": "#...",  // Node border color
    "primaryTextColor": "#...",    // Text inside nodes
    "lineColor": "#...",           // Edge / arrow color
    "background": "#...",          // Canvas background
    "mainBkg": "#...",             // Main background for subgraphs
    "nodeBorder": "#...",          // Fallback node border
    "clusterBkg": "#...",          // Subgraph cluster background
    "titleColor": "#...",          // Title text color
    "edgeLabelBackground": "#..."  // Label box behind edge text
  }
}
```

The dark theme (`theme-dark.json`) uses the same keys but with inverted luminance values.
Swap one variable at a time to see how individual controls affect the output.

---

## What you learned

- `mermaid-render` uses the light theme; `mermaid-render-dark` uses the dark theme
- Themes are JSON files with named CSS-style color variables
- The same `.mmd` source file renders correctly in both themes -- no source changes needed
- Enterprise theme variables let you match your organization's design system

---

## Next exercise

[Exercise 03 -- Validate the Litter](03-validate-the-litter.md)
