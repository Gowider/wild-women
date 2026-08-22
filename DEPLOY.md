# Deploying wildwomentrading.com

Two paths. Pick one — the site files are identical either way.

---

## Path A — Cloudflare Pages (recommended for now)

Free, global CDN, and it lives in the same dashboard as R2. Best fit while the
site is static marketing pages.

1. Push this folder to a GitHub repo.
2. Cloudflare dashboard → Workers & Pages → Create → Pages → connect the repo.
3. Build settings: **framework preset = None**, **build command = (leave empty)**,
   **output directory = `/`**. It's plain HTML — there is nothing to build.
4. Custom domains → add `wildwomentrading.com` and `www.wildwomentrading.com`.
   Your domain is registered elsewhere, so either move the nameservers to
   Cloudflare (easiest, and required for R2 custom domains) or add the CNAME
   records Cloudflare gives you at your current registrar.

Ignore `Dockerfile`, `Caddyfile`, and `railway.json` on this path — they're harmless.

---

## Path B — Railway

Use this when the site stops being static: member accounts, a students
database, gated downloads, Stripe webhooks. Railway runs a container, so you
pay for uptime (Hobby starts around $5/month minimum spend).

1. Push this folder to a GitHub repo.
2. Railway → New Project → Deploy from GitHub repo. It reads `railway.json`,
   sees the Dockerfile, and builds automatically. No settings to configure.
3. Settings → Networking → Generate Domain to test, then add your custom domain.
   SSL is provisioned automatically.

The container is Caddy serving static files, with gzip/zstd compression,
long cache headers on `/assets/*`, and no-cache on the HTML so edits go live
immediately.

Local test before pushing:

    docker build -t wwtc . && docker run -p 8080:8080 wwtc
    # open http://localhost:8080

---

## Images

Images are self-hosted — they live in `assets/img/` and are served by the same
host as the page. Relative paths, so the folder works unchanged on Railway,
Pages, or Hostinger. To swap a photo: replace the file, keep the filename, redeploy.

On Railway the images are baked into the container, so a photo change means a
push and rebuild (a minute or two). On Pages it's a git push; on Hostinger you
drop the file in File Manager and it's live.

Set up Cloudflare R2 later, when you start selling indicators and digital
downloads — zero egress fees and expiring signed URLs matter for paid files.
It is not worth the setup for three marketing photos.

### Before uploading, compress the photos

Export the three photos as WebP at display size (hero ≤250KB, others ≤150KB).
squoosh.app is free and does this in the browser. This matters more for load
speed than which host you pick.

---

## After going live (either path)

1. Search Console → add the property → submit `sitemap.xml`.
2. Test the link preview at opengraph.xyz — it should show the wolf badge.
3. PageSpeed Insights → check mobile score once real photos are in.
