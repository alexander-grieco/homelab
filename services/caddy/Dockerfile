# Caddy with the Cloudflare DNS plugin, needed for the wildcard certificate
# (DNS-01 challenge). Rebuild to update: docker compose build --pull
FROM caddy:builder AS builder
RUN xcaddy build --with github.com/caddy-dns/cloudflare

FROM caddy:latest
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
