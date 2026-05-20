FROM docker.io/caddy:builder AS builder
RUN xcaddy build --with github.com/caddy-dns/route53

FROM docker.io/caddy:2.11.3
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
