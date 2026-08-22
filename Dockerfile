FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html og-image.png favicon.png sitemap.xml robots.txt /srv/
COPY assets /srv/assets

EXPOSE 8080
