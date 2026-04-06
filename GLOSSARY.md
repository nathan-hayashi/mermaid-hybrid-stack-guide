# Glossary

Alphabetical definitions of technical terms used in this guide. Each entry notes which phase introduces the term.

**Claude Code** -- AI coding assistant by Anthropic that runs in the terminal. (Phase 5)

**D2** -- Declarative diagramming language specializing in architecture diagrams with nested containers. (Phase 11)

**dagre** -- The default layout engine used by Mermaid and GitHub's native Mermaid renderer. (Phase 7)

**Docker** -- Container platform that packages applications with all dependencies. Used here to run mermaid-cli without installing Chromium locally. (Phase 0)

**ELK** -- Eclipse Layout Kernel, a free graph layout engine used by D2. Always use `--layout=elk` instead of TALA. (Phase 11)

**Enterprise theme** -- A shared Mermaid configuration file that enforces consistent colors, fonts, and spacing across all renders. (Phase 2)

**heredoc** -- A shell feature (`<< 'EOF'`) for writing multi-line strings. Used in scripts to create config files. (Phase 1)

**Hooks** -- Shell commands that Claude Code executes automatically before or after tool use. PostToolUse hooks auto-render diagrams. (Phase 6)

**htmlLabels** -- A Mermaid config flag that enables HTML inside node labels. When true, use `<br/>` for line breaks instead of `\n`. (Phase 2)

**jq** -- Command-line JSON processor. Used in hooks to parse tool input and in scripts to merge settings.json. (Phase 6)

**maid** -- @probelabs/maid, a Mermaid syntax linter that validates .mmd files in 1-2ms without launching Chromium. (Phase 4)

**MCP** -- Model Context Protocol, a standard for AI tool integration. The mermaid-mcp server was evaluated and rejected. (Phase 12)

**Mermaid** -- A text-based diagramming tool that generates flowcharts, sequences, Gantt charts, and more from markdown-like syntax. (Phase 1)

**mmdc** -- The Mermaid CLI binary inside the Docker container. Accessed via the `mermaid-render` wrapper. (Phase 1)

**Node.js** -- JavaScript runtime required for npm package installation (maid, vega-lite, canvas). (Phase 0)

**npm** -- Node Package Manager. Use `sudo npm install -g` on WSL 2 for global packages. (Phase 4)

**Pandoc** -- Universal document converter. Converts markdown to PDF/HTML. (Phase 8)

**PATH** -- Shell environment variable listing directories where executables are found. `~/bin` must be in PATH for wrapper scripts. (Phase 1)

**Playwright** -- Browser automation framework used by D2 for PNG rendering. Requires libasound2t64 on WSL 2. (Phase 11)

**POSIX** -- Portable Operating System Interface. Use POSIX `case/esac` instead of bash-specific `[[ ]]` in hooks. (Phase 6)

**ReportLab** -- Python library for PDF generation. Mermaid PNGs at 3x scale replace matplotlib charts. (Phase 8)

**SKILL.md** -- The file that defines a Claude Code skill. Must be inside a named directory, not standalone. (Phase 5)

**SVG** -- Scalable Vector Graphics. Primary render output. Infinite resolution, small file size, viewable in browsers. (Phase 1)

**TALA** -- D2's premium layout engine (~$240/yr). Use the free ELK engine instead. (Phase 11)

**Vega-Lite** -- A declarative visualization grammar for creating heatmaps, bar charts, and data-driven diagrams from JSON specs. (Phase 10)

**vl2svg / vl2png** -- Vega-Lite CLI tools that render .vl.json specs to SVG and PNG respectively. (Phase 10)

**WSL 2** -- Windows Subsystem for Linux version 2. Provides a real Linux kernel inside Windows. Docker Desktop integrates with it. (Phase 0)
