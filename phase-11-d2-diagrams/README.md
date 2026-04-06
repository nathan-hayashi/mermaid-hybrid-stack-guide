# Phase 11: D2 -- Complex Architecture Diagrams

**Time estimate:** 15 minutes

## Why

D2's nested containers produce the cleanest multi-layer architecture diagrams. The
4-layer system architecture diagram benefits from strict spatial positioning -- D2
lets you define containers within containers, with explicit edges between any level.
The result is a diagram that is impossible to produce cleanly in Mermaid.

D2 source files are plain text, version-controllable, and diffable. The declarative
syntax is close to plain English, making diagrams readable even without rendering.

## Critical: Layout Engine

**Always use `--layout=elk` (free).** The ELK layout engine is bundled with D2 and
produces excellent results for hierarchical diagrams.

**Do not use TALA.** TALA is D2's premium layout engine and costs approximately
$240/year. All examples and wrapper scripts in this guide use ELK exclusively.

## PNG Rendering on WSL 2

D2 SVG output works immediately after install. PNG output requires Playwright and
Chromium, which in turn require the `libasound2t64` system library on WSL 2 Ubuntu.

- SVG: works immediately
- PNG: requires `sudo apt-get install -y libasound2t64` first

The install script handles this automatically.

## Steps

1. Install D2 and the Playwright system dependency:

   ```bash
   ./install-d2.sh
   ```

2. Create the `d2-render` wrapper script in `~/bin/`:

   ```bash
   ./create-d2-wrapper.sh
   ```

3. Verify everything works with a test diagram:

   ```bash
   ./test-d2.sh
   ```

4. Write your own D2 diagrams using `configs/d2-sample.d2.example` as a starting
   point. Name files with the `.d2` extension.

5. Render your diagram:

   ```bash
   d2-render my-diagram.d2
   ```

   This produces `my-diagram.svg` and `my-diagram.png`.

## Gate / PASS Criteria

- [ ] `d2 --version` prints a version number without error
- [ ] `d2-render` is on your PATH (`which d2-render` succeeds)
- [ ] `./test-d2.sh` produces a `.svg` file without errors
- [ ] Opening the SVG in a browser shows nested container boxes with an edge
      labeled "feeds into"

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
