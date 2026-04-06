# Phase 12: MCP Server Evaluation (REJECTED)

**Time estimate:** 5 minutes

## Outcome: REJECTED

The `mermaid-mcp` package referenced in pre-implementation research does not exist as
a published npm executable. Running `npx -y mermaid-mcp` returns:

```
could not determine executable to run
```

No viable Mermaid MCP server is available as a published npm package at the time of
writing. The evaluation was conducted, the tool was tested, and it was intentionally
rejected.

## Why This Phase Is Included

Real engineering involves testing and intentionally rejecting options that don't work.
This phase is included for educational value: not every evaluated tool makes the cut.

Documenting rejections is as important as documenting what was adopted. It prevents
future engineers (or future you) from re-evaluating the same dead ends.

## What MCP Would Have Provided

The Model Context Protocol (MCP) is an interface for connecting AI assistants to
external tools and data sources. A hypothetical `mermaid-mcp` server would have:

- Accepted natural-language diagram requests from Claude
- Returned validated Mermaid syntax
- Triggered rendering automatically via the MCP protocol

## Why the Skill + Hook Pipeline Is Sufficient

The skill and hook pipeline established in Phases 5-6 provides equivalent capabilities
without MCP overhead:

- **Phase 5 (Claude Skill)**: Claude generates and validates Mermaid syntax using
  the `mermaid-diagrams` skill, which includes syntax validation via `maid`.
- **Phase 6 (Auto-render Hook)**: The PostToolUse hook automatically renders diagrams
  whenever Claude writes a `.mmd` file, with no manual invocation required.

The result is the same automated diagram generation-validation-rendering pipeline that
MCP would have enabled, implemented with tools that actually exist and are stable.

## Future Evaluation

If a viable Mermaid MCP server becomes available as a published npm package,
re-evaluate using this checklist:

- [ ] `npx -y <package-name>` runs without error
- [ ] The server exposes a `render_diagram` or equivalent tool
- [ ] Output is a file path or base64-encoded image (not just text)
- [ ] Latency is comparable to the existing skill + hook pipeline

The integration point for any approved MCP server is the `mcpServers` object in
`.mcp.json` at the project root. Example structure:

```json
{
  "mcpServers": {
    "mermaid": {
      "command": "npx",
      "args": ["-y", "mermaid-mcp"]
    }
  }
}
```

Do not add this configuration until a working package is confirmed.

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
