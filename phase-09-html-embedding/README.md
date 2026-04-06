# Phase 9: HTML Portfolio Embedding

**Time estimate:** 10 minutes

## Why

Pre-rendered SVGs in Astro's `public/` directory provide instant loading, SEO-friendly
rendering, and infinite resolution scaling. Unlike client-side diagram libraries that
execute JavaScript at runtime, static SVGs are available immediately -- no flash of
unstyled content, no render delay, and no dependency on external CDNs. Search engines
can index the SVG alt text, and retina/4K displays get perfect vector crispness at any
zoom level.

## Steps

1. Run the embed script to copy rendered SVGs and PNGs into your Astro project:

   ```bash
   ./embed-diagrams.sh /path/to/your/diagrams /path/to/your/astro-project
   ```

2. Verify the files were copied correctly:

   ```bash
   ./test-embed.sh /path/to/your/astro-project
   ```

3. In your Astro components, reference the copied assets using the pattern in
   `configs/astro-embed.example`.

4. Run `npm run build` inside your Astro project and confirm 0 errors.

5. Check the built `dist/` directory to confirm SVG/PNG files are present under
   `dist/assets/`.

## Gate / PASS Criteria

- [ ] All `.svg` and `.png` files from `diagrams/` are present in
      `public/assets/` of the Astro project
- [ ] `npm run build` completes with 0 errors
- [ ] Opening `dist/index.html` (or the relevant page) in a browser shows the
      diagram images rendered correctly
- [ ] No broken image icons or 404s in the browser network panel

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
