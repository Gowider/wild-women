# Wild Women Trading Company — Static Site

Everything is plain, SEO-friendly HTML. All text is in `index.html` — no JavaScript needed to read it.

## What's in here
- `index.html` — the whole site (content, styles, icon set)
- `og-image.png` — 1200×630 social share image (link previews)
- `sitemap.xml`, `robots.txt` — search engine files
- `*.svg` (bell, binoculars, book, etc.) — the reusable icon set (17 SVGs, one consistent line style, inlined into `index.html` as `<symbol>` defs; recolor by changing `stroke="currentColor"` or wrapping in an element with a CSS `color`)
- `placeholder-hero.svg`, `placeholder-mentor.svg`, `placeholder-community.svg` — placeholder images to replace
- `hero.webp`, `logo-badge.png` — the real hero photo and logo currently in use
- `logo-full.png`, `logo-wordmark.png` — superseded lockups, kept as spares

## Swapping in your real elements
1. **Logo**: search `index.html` for `#i-seal` — the placeholder badge. Replace the `<svg class="seal">…</svg>` blocks with your logo `<img>`, or replace the `i-seal` symbol at the top of the file with your logo's SVG paths.
2. **Photos**: replace `hero.webp`, and the `placeholder-mentor.svg` / `placeholder-community.svg` files (hero 1920×1080, mentor 900×1000, community 1000×900). Search `PLACEHOLDER:` in index.html to find each spot. Keep the `width`/`height` attributes and `loading="lazy"` on the two below-the-fold photos.
3. **Buttons/links**: all "Join the Pack" buttons and the announcement bar point to `https://www.skool.com/wild-women-trading`. The app "Notify me at launch" button needs your email signup URL (marked with a PLACEHOLDER comment).

## Image compression (do this before upload)
Export photos as WebP at the display size (hero ≤ 250KB, others ≤ 150KB). Free tool: squoosh.app. Modern lazy loading is already in place via `loading="lazy"` — no 1×1 pixel tricks needed; browsers handle deferred loading natively now.

## Deploying
Upload the whole folder to any static host (Netlify, Cloudflare Pages, your current host). `index.html` must be at the root. After deploy:
1. Verify the site at https://search.google.com/search-console and submit `sitemap.xml`.
2. Test link previews at https://www.opengraph.xyz (should show og-image.png).

## Logo files
- `logo-badge.png` — the real badge, background removed, transparent, 900px wide (cut from your 2000×2000 original)
- `favicon.png` — 128px favicon from the badge
- `logo-wordmark.png` / `logo-full.png` — older low-res lockup cuts; superseded, kept only in case you need the horizontal text version
- Keep your original WWTC_Logo.png as the master file for merch and print.
Brand colors measured from the logo: green #152912 (background), gold #c69636, cream #ead3a2 — the site's CSS variables in index.html are derived from these.
