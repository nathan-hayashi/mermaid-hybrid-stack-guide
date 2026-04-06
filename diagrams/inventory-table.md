# Claude Code Orchestration -- Component Inventory

| Component | Type | Location | Tool / Model | Trigger |
|---|---|---|---|---|
| CLAUDE.md (Global) | Configuration | `~/.claude/CLAUDE.md` | Read at startup | Every session start |
| CLAUDE.md (Project) | Configuration | `<repo-root>/CLAUDE.md` | Read at startup | Every session start |
| CLAUDE.local.md | Configuration | `<repo-root>/CLAUDE.local.md` | Read at startup (gitignored) | Every session start |
| Rule: No console.log | Rule | `CLAUDE.md > Code Standards` | Enforced by Claude | Every code write |
| Rule: Conventional Commits | Rule | `CLAUDE.md > Git Workflow` | Enforced by Claude | Every commit |
| Rule: No hardcoded secrets | Rule | `CLAUDE.md > Code Standards` | Enforced by Claude | Every code write |
| Rule: Pin dependencies | Rule | `CLAUDE.md > Code Standards` | Enforced by Claude | Every package change |
| Memory: Project Guide | Memory | `~/.claude/projects/.../memory/` | Injected into context | On project open |
| settings.json | Settings | `~/.claude/settings.json` | Claude Code runtime | Startup, hook dispatch |
| Hook: PreToolUse (bash-blocker) | Hook | `settings.json > hooks` | Bash tool intercept | Before every Bash call |
| Hook: PostToolUse (Prettier) | Hook | `settings.json > hooks` | npx prettier | After every file write |
| Hook: PostToolUse (TypeCheck) | Hook | `settings.json > hooks` | npx tsc --noEmit | After .ts/.tsx writes |
| Hook: PostToolUse (ESLint) | Hook | `settings.json > hooks` | npx eslint | After JS/TS writes |
| Hook: PreToolUse (git-guard) | Hook | `settings.json > hooks` | Bash script | Before git destructive ops |
| Hook: PostToolUse (notify) | Hook | `settings.json > hooks` | system notification | After long tasks complete |
| Hook: Stop (session-log) | Hook | `settings.json > hooks` | Bash append script | On session end |
| Threshold Router | Skill | `~/.claude/skills/threshold-router.md` | claude-sonnet-4-6 | Every user prompt |
| Skill: mermaid-diagrams | Skill | `~/.claude/skills/mermaid-diagrams.md` | claude-sonnet-4-6 | On diagram request |
| Subagent: Security Reviewer | Review Subagent | Spawned inline (Task tool) | claude-sonnet-4-6 | T2 / T3 tier completion |
| Subagent: Quality Reviewer | Review Subagent | Spawned inline (Task tool) | claude-sonnet-4-6 | T2 / T3 tier completion |
| Subagent: Fixer Agent | Review Subagent | Spawned inline (Task tool) | claude-sonnet-4-6 | T3 tier completion |
| MCP Server: GitHub | MCP Server | `settings.json > mcpServers` | github MCP binary | On GitHub tool call |
| MCP Server: Playwright | MCP Server | `settings.json > mcpServers` | playwright MCP binary | On browser tool call |
| Plugin: OCR | Review Plugin | `~/.claude/skills/ocr.md` | Multi-reviewer pipeline | T3 or explicit invocation |
| Plugin: Codex | Review Plugin | `~/.claude/skills/codex-review.md` | openai codex CLI | T3 or explicit invocation |
| Plugin: Turbo | Skill Manager | `~/.claude/skills/update-turbo.md` | npm / local scripts | On /update-turbo call |
