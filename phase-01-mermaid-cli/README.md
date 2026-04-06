# Phase 1: Mermaid CLI Installation via Docker

**Time estimate: 15 minutes**

## Why Docker Instead of a Native Install?

Installing `mmdc` (Mermaid CLI) natively requires:

1. Node.js + npm
2. Puppeteer (`npm install puppeteer`)
3. Chromium (downloaded automatically by Puppeteer -- ~300 MB)
4. Roughly 15 system libraries on Ubuntu for headless Chromium to run:
   `libgbm`, `libnss3`, `libxss1`, `libasound2`, `libatk1.0`, and more

Tracking down every missing library when a render silently fails is painful.
The `minlag/mermaid-cli` Docker image ships with all of it pre-installed and
tested together. One `docker pull` and it works.

The trade-off is a ~400 MB image download the first time. After that, renders
are fast (cold start ~2 s, warm ~0.5 s).

## What This Phase Creates

| File | Purpose |
|------|---------|
| `~/bin/mermaid-render` | Thin shell wrapper -- the command you type every day |
| `~/.config/mermaid/` | Directory for theme config files (Phase 2 will populate it) |

## Steps

1. Run the install script (pulls the Docker image, creates the wrapper):
   ```bash
   bash phase-01-mermaid-cli/install-mermaid.sh
   ```

2. Add `~/bin` to your PATH if it is not already there:
   ```bash
   bash phase-01-mermaid-cli/setup-path.sh
   # Then reload your shell:
   source ~/.bashrc   # or ~/.zshrc
   ```

3. Verify the install with a test render:
   ```bash
   bash phase-01-mermaid-cli/test-render.sh
   ```

## Gate / PASS Criteria

- `mermaid-render --version` prints a version string (no errors)
- `test-render.sh` prints [PASS] and produces a non-empty `.svg` file

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
