# Phase 5: Claude Code Skill -- Mermaid Diagram Generator

**Time estimate: 15 minutes**

## Why

Describing a diagram in plain English and getting back a valid `.mmd`, `.vl.json`,
or `.d2` file closes the last manual step in the pipeline. The skill tells Claude
Code exactly which diagram type to pick, enforces the syntax guardrails that
prevent maid validation failures, and auto-runs validation + rendering after
every file write.

Without this skill, Claude Code falls back to general-purpose code generation
and occasionally produces broken Mermaid (quoted pipe labels, `\n` line breaks,
hyphenated node IDs) that fail silently or waste a render cycle.

**CRITICAL:** Skills are **directories** containing a `SKILL.md` file. Do NOT
create a standalone `mermaid-diagrams.md` at the skills root -- Claude Code will
not recognise it as a skill. The correct path is:

```
~/.claude/skills/mermaid-diagrams/SKILL.md
```

## Steps

### 1. Create the skill

```bash
bash phase-05-claude-skill/create-skill.sh
```

The script creates `~/.claude/skills/mermaid-diagrams/SKILL.md` (backing up any
existing file first).

### 2. Verify the skill was installed

```bash
bash phase-05-claude-skill/test-skill.sh
```

### 3. Use the skill in Claude Code

In any Claude Code session, invoke the skill:

```
/mermaid-diagrams
```

Then describe what you want:

```
Generate a flowchart showing the OAuth 2.0 authorization code flow with PKCE.
Include the browser, auth server, and resource server as participants.
```

Claude Code will:
1. Pick the right diagram type (Mermaid for flowcharts/sequences)
2. Write a `.mmd` file with valid syntax
3. Run `maid` to validate
4. Run `mermaid-render` to produce SVG (via the Phase 6 hook)

## Gate / PASS Criteria

- [ ] `~/.claude/skills/mermaid-diagrams/SKILL.md` exists as a **file inside a directory**
      (not a standalone `.md` file at the skills root)
- [ ] The file contains the Syntax Guardrails section
- [ ] `/mermaid-diagrams` is recognised by Claude Code (`/skills` lists it)
- [ ] A generated `.mmd` file passes `maid` validation without edits

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
