# Exercise 01 -- Hello Diagrams: Your First Flowchart

**Phase mapping:** Phase 0-1
**Time estimate:** 20-30 minutes

---

## Goal

Write a Mermaid flowchart from scratch, render it to SVG, and verify the output. You will
model a simple pet store hierarchy showing dog and cat breeds.

---

## Step 1: Create the project directory

Open a terminal and create your working directory:

```bash
mkdir -p ~/projects/pets-diagrams
cd ~/projects/pets-diagrams
```

---

## Step 2: Write the diagram source

Create a file called `pets.mmd` with the following content:

```
flowchart TD
    STORE["Pet Store"] --> DOGS["Dogs"]
    STORE --> CATS["Cats"]
    DOGS --> LAB["Labrador"]
    DOGS --> POOD["Poodle"]
    DOGS --> BULL["Bulldog"]
    CATS --> SIAM["Siamese"]
    CATS --> PERS["Persian"]
    CATS --> MAINE["Maine Coon"]
```

**Syntax notes:**

- Node IDs (`STORE`, `DOGS`, etc.) must not contain spaces. Use short uppercase identifiers.
- Node labels go inside quotes within square brackets: `STORE["Pet Store"]`.
- `-->` creates a directed edge (arrow) between nodes.
- `TD` means top-down layout. Other options: `LR` (left-right), `BT` (bottom-top), `RL` (right-left).
- For multi-line labels inside a node, use `<br/>` -- never `\n`. Example: `NODE["Line one<br/>Line two"]`.

---

## Step 3: Render to SVG

Run the render command from inside your project directory:

```bash
mermaid-render pets.mmd pets.svg
```

You should see output similar to:

```
Rendering pets.mmd -> pets.svg
Done.
```

---

## Step 4: Verify the output

Open `pets.svg` in your browser or an SVG viewer:

```bash
# On Linux with xdg-open:
xdg-open pets.svg

# Or open manually in your browser by navigating to the file path
```

You should see a top-down flowchart with:

- A single "Pet Store" node at the top
- Two child nodes: "Dogs" and "Cats"
- Three dog breed nodes below "Dogs": Labrador, Poodle, Bulldog
- Three cat breed nodes below "Cats": Siamese, Persian, Maine Coon

If the diagram looks correct, you are ready for Exercise 02.

---

## What you learned

- Mermaid source files use the `.mmd` extension
- Node IDs are separate from node labels
- Use `<br/>` for line breaks in labels (not `\n`)
- `mermaid-render <source> <output>` produces an SVG file

---

## Next exercise

[Exercise 02 -- Theme Your Kennel](02-theme-your-kennel.md)
