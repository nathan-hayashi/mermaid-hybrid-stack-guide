# Exercise 03 -- Validate the Litter: Catching Syntax Errors

**Phase mapping:** Phase 3-4
**Time estimate:** 25-35 minutes

---

## Goal

Deliberately introduce three common Mermaid syntax errors, learn to read the validator
output, fix each error one at a time, and then run the combined validate-and-render
command.

---

## Step 1: Create a broken diagram

In your pets project directory, create `broken-pets.mmd` with these three deliberate errors:

```
flowchart TD
    Pet Store["Pet Store"] --> DOGS["Dogs"]
    Pet Store --> CATS["Cats"]
    DOGS --> LAB["Labrador\nRetriever"]
    DOGS --> POOD["Poodle"]
    CATS -->|"adopts"| SIAM["Siamese"]
    CATS --> PERS["Persian"]
```

The three errors are:

1. **Spaces in node IDs** -- `Pet Store["Pet Store"]` uses a space in the node ID.
   Node IDs must be a single token with no spaces. The label (inside `["..."]`) can have
   spaces, but the ID before it cannot.

2. **Wrong line-break syntax** -- `"Labrador\nRetriever"` uses `\n`. Mermaid does not
   interpret `\n` as a newline inside node labels. Use `<br/>` instead.

3. **Quoted edge labels** -- `-->|"adopts"|` wraps the edge label in quotes. Edge labels
   must not be quoted; the pipe delimiters are sufficient: `-->|adopts|`.

---

## Step 2: Run the validator and observe the errors

```bash
cd ~/projects/pets-diagrams
maid broken-pets.mmd
```

Expected output (exact messages may vary by version):

```
Error: Parse error on line 2:
...Pet Store["Pet Store"] --> DOGS
------^
Expecting 'SQS', 'PS', etc. -- unexpected token

1 error found. Fix the source and re-run.
```

The validator stops at the first parse error. You will fix errors one by one.

---

## Step 3: Fix error 1 -- spaces in node IDs

Change `Pet Store["Pet Store"]` to `PetStore["Pet Store"]` on both lines where it appears:

```
flowchart TD
    PetStore["Pet Store"] --> DOGS["Dogs"]
    PetStore --> CATS["Cats"]
    DOGS --> LAB["Labrador\nRetriever"]
    DOGS --> POOD["Poodle"]
    CATS -->|"adopts"| SIAM["Siamese"]
    CATS --> PERS["Persian"]
```

Re-run:

```bash
maid broken-pets.mmd
```

The node ID error should be gone. A new error about `\n` or quoted labels will appear.

---

## Step 4: Fix error 2 -- wrong line-break syntax

Change `"Labrador\nRetriever"` to `"Labrador<br/>Retriever"`:

```
    DOGS --> LAB["Labrador<br/>Retriever"]
```

Re-run:

```bash
maid broken-pets.mmd
```

---

## Step 5: Fix error 3 -- quoted edge labels

Change `-->|"adopts"|` to `-->|adopts|`:

```
    CATS -->|adopts| SIAM["Siamese"]
```

Re-run:

```bash
maid broken-pets.mmd
```

Expected output after all three fixes:

```
Syntax OK: broken-pets.mmd
```

---

## Step 6: Corrected diagram

Your corrected `broken-pets.mmd` should now look like this:

```
flowchart TD
    PetStore["Pet Store"] --> DOGS["Dogs"]
    PetStore --> CATS["Cats"]
    DOGS --> LAB["Labrador<br/>Retriever"]
    DOGS --> POOD["Poodle"]
    CATS -->|adopts| SIAM["Siamese"]
    CATS --> PERS["Persian"]
```

---

## Step 7: Validate and render in one step

The `mermaid-validate` command validates the source and, if it passes, renders the SVG:

```bash
mermaid-validate broken-pets.mmd broken-pets.svg
```

Expected output:

```
Syntax OK: broken-pets.mmd
Rendering broken-pets.mmd -> broken-pets.svg
Done.
```

---

## What you learned

- Node IDs cannot contain spaces; use camelCase or ALLCAPS identifiers
- Use `<br/>` for line breaks in node labels, not `\n`
- Edge labels go between pipe characters without quotes: `-->|label|`
- `maid` validates syntax only; `mermaid-validate` validates and renders
- Fix errors one at a time and re-run after each fix -- the parser stops at the first error

---

## Next exercise

[Exercise 04 -- Teach Claude to Draw](04-teach-claude-to-draw.md)
