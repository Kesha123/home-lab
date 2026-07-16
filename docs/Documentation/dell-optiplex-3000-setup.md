# Dell OptiPlex 3000 — Server Setup

**Host**: `dell-optiplex-3000.innokentii-kozlov.com` (192.168.0.252)
**User**: `admin`
**OS**: Fedora Server 44

---

## Phase 1: Base OS Configuration

### SSH Hardening

**Problem**: Default SSH allows root login, password auth, weak ciphers — exposes to brute-force.

Edited `/etc/ssh/sshd_config` (exact changes unknown without sudo access, but standard hardening: `PermitRootLogin no`, `PasswordAuthentication no`, `PubkeyAuthentication yes`).

```bash
sudo nano /etc/ssh/sshd_config
sudo service sshd restart
```

### Hostname

**Problem**: Servers need a stable, meaningful hostname for identification in logs, TLS certs, and DNS.

```bash
hostnamectl hostname dell-optiplex-3000.innokentii-kozlov.com
```

### System Update

```bash
sudo dnf update -y
```

---

## Phase 2: Podman Rootless Infrastructure

### Unprivileged Port Binding

**Problem**: Rootless containers cannot bind to ports <1024 by default. Caddy needs 80/443, Blocky needs 53.

```bash
echo "net.ipv4.ip_unprivileged_port_start=1" | sudo tee /etc/sysctl.d/99-unprivileged-ports.conf
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=1
```

Allows rootless containers to bind from port 1 upward.

### User Lingering

**Problem**: User-scoped systemd services die when the user logs out. Lingering keeps them alive.

```bash
loginctl enable-linger $USER
```

### DOCKER_HOST

Added to `~/.bashrc` for podman CLI convenience:

```bash
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
```

### Homelab Network (Bridge)

**Problem**: Containers need an isolated network to communicate by name (e.g., `caddy` → `zot:5000`).

Created as a Quadlet-managed network (auto-created by systemd when any container references it):

**`~/.config/containers/systemd/homelab.network`**:
```ini
[Network]
NetworkName=homelab.network
```

```bash
systemctl --user enable homelab-network.service
```

---

## Phase 3: DNS — Blocky

**Problem**: Need ad-blocking DNS + local domain resolution (`innokentii-kozlov.com` → `192.168.0.252`) without relying on external DNS for internal services. Replaced systemd-resolved which conflicts with port 53.

### Disable systemd-resolved

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

### Blocky Configuration

**`~/.config/config/blocky/config.yml`** — upstream resolvers (8.8.8.8, 1.1.1.1), ad-blocking denylists, custom DNS mapping for the local domain, metrics on port 4000.

### Quadlet Unit

**`~/.config/containers/systemd/blocky/blocky.container`**:
- Image: `docker.io/spx01/blocky`
- Binds DNS port 53/tcp+53/udp on host IP `192.168.0.252`
- Mounts config read-only
- Restart: unless-stopped

```bash
systemctl --user enable --now blocky
```

### System-level DNS → Blocky

**Problem**: The host itself uses systemd-resolved (127.0.0.53) which doesn't know about the local domain. NetworkManager must point directly to Blocky.

```bash
sudo nmcli con mod 805ca9b9-81f6-3ea1-87e4-4636f4204e96 ipv4.dns "192.168.0.252"
sudo nmcli con mod 805ca9b9-81f6-3ea1-87e4-4636f4204e96 ipv4.ignore-auto-dns yes
sudo nmcli con up 805ca9b9-81f6-3ea1-87e4-4636f4204e96
```

Now `nslookup zot.innokentii-kozlov.com` resolves to `192.168.0.252`.

### DNS flow:
1. Client queries `192.168.0.252:53` → Blocky
2. Blocky resolves `*.innokentii-kozlov.com` → `192.168.0.252` (custom mapping)
3. Blocky forwards other queries → upstream (8.8.8.8, 1.1.1.1)
4. Caddy receives TLS traffic on 443, reverses to `zot:5000` or any other container.

---

## Phase 4: Caddy Reverse Proxy + TLS

**Problem**: Need automatic TLS certificates for internal services, and a reverse proxy to expose them. AWS Route53 DNS challenge is used so certificates work fully inside the LAN without requiring internet-facing HTTP-01 challenges.

### Custom Image

Uses a custom Caddy image built with the Route53 DNS module: `codeberg.org/kesha123/home-lab/caddy-route53:0.0.0`

### Secrets

AWS Route53 credentials stored as podman secrets:

```bash
printf '<AWS_ACCESS_KEY_ID>' | podman secret create AWS_ACCESS_KEY_ID -
printf '<AWS_SECRET_ACCESS_KEY>' | podman secret create AWS_SECRET_ACCESS_KEY -
printf 'us-east-1' | podman secret create AWS_REGION -
```

### Caddyfile

**`~/.config/config/caddy/Caddyfile`**:
```caddy
zot.innokentii-kozlov.com {
    tls {
        dns route53
    }
    reverse_proxy zot:5000
}
```

### Quadlet Unit

**`~/.config/containers/systemd/caddy/caddy.container`**:
- Exposes ports 80, 443/tcp, 443/udp
- Mounts Caddyfile read-only
- Injects AWS secrets as env vars
- Persistent volumes for Caddy data and config

```bash
systemctl --user enable --now caddy
```

---

## Phase 5: Zot Container Registry

**Problem**: Avoid rate-limiting from Docker Hub/GHCR and speed up image pulls across the homelab by running a local caching registry proxy.

### Zot Configuration

**`~/.config/config/zot/config.yaml`**:
- Serves on port 5000
- UI and search extensions enabled
- On-demand sync from 5 upstream registries (quay.io, ghcr.io, gcr.io, codeberg.org, docker.io) — pulls images through the proxy transparently on first request

### Quadlet Unit

**`~/.config/containers/systemd/zot/zot.container`**:
- Image: `ghcr.io/project-zot/zot:v2.1.17`
- Mounts config + persistent data volume

```bash
systemctl --user enable --now zot
```

### Podman Registry Mirrors

**`~/.config/containers/registries.conf`** — redirects pulls from `docker.io`, `ghcr.io`, `quay.io`, `gcr.io`, `codeberg.org` → local Zot:
```
docker.io → zot.innokentii-kozlov.com/docker-images
ghcr.io   → zot.innokentii-kozlov.com/ghcr-images
quay.io   → zot.innokentii-kozlov.com/quay-images
...
```

This means `podman pull docker.io/alpine` transparently hits the local cache.

### Aardvark DNS Fix

Early on, container-to-container DNS was broken because `aardvark-dns` was missing:

```bash
sudo dnf install -y aardvark-dns
```

This made `caddy → zot:5000` resolve correctly within the homelab network.

---

## Phase 6: Firewall — firewalld → UFW

**Problem**: Initially used `firewalld` but encountered UX friction; switched to `ufw` for simpler rule management.

```bash
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
sudo dnf install ufw
```

### UFW Rules

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp       # SSH
sudo ufw allow 53/tcp       # DNS
sudo ufw allow 53/udp       # DNS
sudo ufw allow 443/tcp      # HTTPS (Caddy)
sudo ufw allow 443/udp      # HTTP/3 QUIC (Caddy)
sudo ufw --force enable
```
