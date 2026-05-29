# Containers stack

## Containers Overview
* It runs on Fedora 44 server `dell-optiplex-3000.innokentii-kozlov.com` with podman, systemd.
* containers are rootless, located in `~/.config/containers`
* `stack/containers/containers.conf` - defines containers settings
* `stack/containers/registries.conf` - defines podman registries settings
* `stack/Makefile` - is used to copy files to `dell-optiplex-3000.innokentii-kozlov.com`

## Server Overview
[`dell-optiplex-3000.innokentii-kozlov.com` setup](../docs/Documentation/dell-optiplex-3000-setup.md)

## Networking
* Two podman networks isolate services:
  * `frontend.network` — user-facing, proxied by Caddy
  * `backend.network` — internal only, no Caddy access
* Only containers on both networks can bridge between tiers.
* SELinux bind mounts use `:z` (shared). Named volumes use no relabel suffix.
* Blocky publishes port 53 on a specific LAN IP for DNS resolution.

## Applications Overview
* Secrets used in applications are handled with podman secrets.
* `authentik` is used to authenticate to other applications.
* `caddy` is a proxy
* `blocky` is a dns.
