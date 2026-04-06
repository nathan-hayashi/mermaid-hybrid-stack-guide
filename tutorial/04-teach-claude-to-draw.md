# Exercise 04 -- Teach Claude to Draw: AI-Powered Diagrams

**Phase mapping:** Phase 5-6
**Time estimate:** 20-30 minutes

---

## Goal

Verify that the mermaid-diagrams Claude skill and the PostToolUse auto-render hook are
installed. Then ask Claude to generate a diagram from a plain English description and watch
it render automatically.

---

## Step 1: Verify the skill is installed

```bash
ls ~/.claude/skills/mermaid-diagrams/SKILL.md
```

Expected output:

```
/home/<your-user>/.claude/skills/mermaid-diagrams/SKILL.md
```

If the file does not exist, re-run the Phase 5 setup script:

```bash
bash ~/projects/mermaid-hybrid-stack/scripts/05-install-skill.sh
```

---

## Step 2: Verify the PostToolUse hook is configured

```bash
cat ~/.claude/settings.json | grep -A 5 "PostToolUse"
```

You should see a hook entry that runs `mermaid-render` on `.mmd` files after Claude writes
them. The relevant section looks similar to:

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'echo \"$CLAUDE_TOOL_OUTPUT\" | grep -q \\.mmd && mermaid-render \"$CLAUDE_TOOL_INPUT_FILE_PATH\" \"${CLAUDE_TOOL_INPUT_FILE_PATH%.mmd}.svg\" || true'"
        }
      ]
    }
  ]
}
```

If the hook is missing, re-run the Phase 6 setup script:

```bash
bash ~/projects/mermaid-hybrid-stack/scripts/06-install-hook.sh
```

---

## Step 3: Open Claude Code in the pets project

```bash
cd ~/projects/pets-diagrams
claude
```

Wait for Claude Code to start. You should see the familiar prompt.

---

## Step 4: Ask Claude to generate a diagram

Type or paste the following prompt into Claude Code:

```
Create a flowchart showing the cat adoption process:
Application -> Background Check -> Home Visit -> Approval/Rejection -> Pickup Day
```

Claude will:

1. Load the `mermaid-diagrams` skill (triggered by the diagram request)
2. Generate a valid `cat-adoption.mmd` file using correct Mermaid syntax
3. Write the file to your project directory
4. The PostToolUse hook detects the `.mmd` file write and automatically runs
   `mermaid-render cat-adoption.mmd cat-adoption.svg`

---

## Step 5: Verify the auto-rendered output

After Claude finishes, check that both files exist:

```bash
ls ~/projects/pets-diagrams/
# Expected: cat-adoption.mmd  cat-adoption.svg  pets.mmd  pets.svg  ...
```

Open the SVG to verify it looks correct:

```bash
xdg-open cat-adoption.svg
```

You should see a flowchart with a branch at "Approval/Rejection" -- one path leading to
"Pickup Day" (Approved) and one path indicating rejection. The exact layout depends on
how Claude structures the diagram, but the content should match your description.

---

## How it works

**The skill** (`~/.claude/skills/mermaid-diagrams/SKILL.md`) teaches Claude:

- Which Mermaid diagram types to use for which scenarios
- The exact syntax rules (node IDs, label quoting, `<br/>` for line breaks)
- Common mistakes to avoid (the same errors from Exercise 03)
- How to structure complex diagrams with subgraphs

**The hook** (configured in `~/.claude/settings.json`) watches for file writes ending in
`.mmd`. When Claude uses the Write or Edit tool to create or modify a `.mmd` file, the
hook immediately runs `mermaid-render` on it. You get a rendered SVG without any manual
step.

Together, the skill and hook create a tight loop: describe a diagram in plain English,
get a syntactically correct source file and a rendered SVG in one interaction.

---

## What you learned

- The mermaid-diagrams skill gives Claude knowledge of Mermaid syntax rules
- The PostToolUse hook auto-renders `.mmd` files the moment Claude writes them
- You can describe diagrams in plain English and get valid, rendered output
- The hook requires no changes to how you interact with Claude -- it is transparent

---

## Next exercise

[Exercise 05 -- Publish to GitHub](05-publish-to-github.md)
