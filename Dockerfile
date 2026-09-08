FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html og-image.png favicon.png sitemap.xml robots.txt hero.webp logo-badge.png logo-full.png logo-wordmark.png *.svg /srv/

EXPOSE 8080
