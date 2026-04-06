# Troubleshooting: 11 Documented Errors

Every error documented below was encountered during the live implementation walkthrough. No hypotheticals -- each entry includes the exact symptom, root cause, and fix.

## Error 1: Docker EACCES Permission Denied on Write

Phase 1, Step 1.5

| Field | Detail |
|---|---|
| Symptom | `[Error: EACCES: permission denied, open '/data/output.svg']` |
| Root Cause | Docker container runs as internal user without write permission to volume-mounted host directory. |
| Fix | Add `--user "$(id -u):$(id -g)"` to docker run command. |

## Error 2: Literal \n in Rendered Diagram Labels

Phase 3, Step 3.4

| Field | Detail |
|---|---|
| Symptom | Node text displays "Complexity\nScoring Engine" as single line with visible \n. |
| Root Cause | Enterprise theme config sets htmlLabels: true. Mermaid expects HTML markup (`<br/>`) not escape sequences. |
| Fix | Replace all `\n` with `<br/>` in .mmd files. |

## Error 3: npm EACCES on Global Package Install

Phase 4, 10, Step 4.1, 10.1

| Field | Detail |
|---|---|
| Symptom | `npm error code EACCES -- permission denied, mkdir '/usr/local/lib/node_modules/...'` |
| Root Cause | Global node_modules directory owned by root. |
| Fix | Prefix with sudo: `sudo npm install -g <package>` |

## Error 4: maid Rejects Quoted Strings in Pipe Edge Labels

Phase 4, Step 4.2

| Field | Detail |
|---|---|
| Symptom | `error[FL-EDGE-LABEL-QUOTE-IN-PIPES]: Quotes not supported inside pipe-delimited edge labels.` |
| Root Cause | maid enforces stricter grammar. Pipe edge labels do not support quoted strings. |
| Fix | BEFORE: `-->|"Score <= 4"|` AFTER: `-->|Score <= 4|` |

## Error 5: Claude Code Skill Not Detected

Phase 5, Step 5.3

| Field | Detail |
|---|---|
| Symptom | `/skills` does not list mermaid-diagrams despite the file existing. |
| Root Cause | Claude Code expects skills as directories containing SKILL.md, not standalone .md files. |
| Fix | `mkdir -p ~/.claude/skills/mermaid-diagrams` then move file to SKILL.md inside that directory. |

## Error 6: PostToolUse Hook Fires but SVG Not Generated (PATH)

Phase 6, Step 6.4

| Field | Detail |
|---|---|
| Symptom | "3 PostToolUse hooks ran" but no .svg file created. No error visible. |
| Root Cause | Hooks run in minimal shell where ~/bin is not in PATH. |
| Fix | Add `export PATH="$HOME/bin:$PATH"` inside the hook command. |

## Error 7: Hook Still Fails After PATH Fix (Shell Compatibility)

Phase 6, Step 6.4

| Field | Detail |
|---|---|
| Symptom | Same as Error 6 -- hook fires, no SVG, no error. |
| Root Cause | `[[ ]]` is bash-specific. Hooks may execute in sh/restricted shell. |
| Fix | Wrap in `bash -c '...'`; replace `[[ ]]` with POSIX `case/esac`; increase timeout to 60s. |

## Error 8: Vega-Lite PNG Render Fails -- Missing Canvas

Phase 10, Step 10.3

| Field | Detail |
|---|---|
| Symptom | `Error: CanvasRenderer is missing a valid canvas or context` |
| Root Cause | vl2png requires native canvas npm package for server-side PNG rasterization. |
| Fix | `sudo npm install -g canvas`. SVG rendering works without it. |

## Error 9: D2 PNG Render Fails -- Playwright Missing Dependencies

Phase 11, Step 11.3

| Field | Detail |
|---|---|
| Symptom | `Host system is missing dependencies to run browsers.` |
| Root Cause | D2 uses Playwright + Chromium for PNG. WSL 2 Ubuntu lacks libasound2t64. |
| Fix | `sudo apt-get install -y libasound2t64`. D2 SVG works without Playwright. |

## Error 10: MCP Server mermaid-mcp Fails to Connect

Phase 12, Step 12.3

| Field | Detail |
|---|---|
| Symptom | `npx -y mermaid-mcp` returns: could not determine executable to run. |
| Root Cause | Package is a GitHub repo, not a published npm package with bin entry. |
| Fix | Removed from .mcp.json. Skill + hook pipeline provides equivalent capabilities. |

## Error 11: Batch Render Stalls on Sequential Docker Runs

Phase 8, Step 8.2

| Field | Detail |
|---|---|
| Symptom | Script hangs mid-execution during third diagram's PNG render. |
| Root Cause | Rapid sequential Docker container spin-ups exhaust resources. Each spawns full Chromium. |
| Fix | Wait 60-90s before Ctrl+C. Re-run stalled file individually. Increase Docker resource allocation. |
