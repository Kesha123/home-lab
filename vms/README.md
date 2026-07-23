# VMs

Libvirt VMs managed declaratively via `vm.yaml` + cloud-init, provisioned with Ansible.

## ci-lab

Woodpecker CI server. Fedora Cloud 44, 2 vCPU, 4 GiB RAM, 40 GiB root disk.

- **IP**: `192.168.40.119/24` (gateway `192.168.40.1`, DNS `192.168.40.118` blocky)
- **Host**: `dell-optiplex-3000.innokentii-kozlov.com` (`192.168.40.118`)
- **SSH**: `ssh -i target/ci-lab/ssh-keys/id_rsa admin@192.168.40.119`
- **Woodpecker URL**: `https://ci-lab.innokentii-kozlov.com` (via Caddy on host)
- **Forgejo (OAuth source)**: `https://forgejo.innokentii-kozlov.com` (on rpi-5)

### Networking — br0 bridge

The VM attaches to `br0` on the host (`bridge=br0` in `vm.yaml`). `br0` enslaves the host's physical NIC `enp1s0` and holds the host's static IP `192.168.40.118/24`. This puts the VM directly on the LAN (`192.168.40.0/24`), giving:

- Server (Caddy) -> VM: Caddy proxies `ci-lab.innokentii-kozlov.com` -> `192.168.40.119:80`.
- Dev machine -> VM: direct SSH and `make deploy/ci-lab` (Ansible).
- VM -> Forgejo (rpi-5): direct LAN access for OAuth and API calls.
- rpi-5 / LAN devices -> VM: direct.

`br_netfilter` is not loaded on the host, so UFW/iptables does not filter bridged traffic.

#### Create br0 (one-time, on host, requires sudo)

```bash
sudo nmcli con add type bridge con-name br0 ifname br0 \
  ipv4.method manual ipv4.addresses 192.168.40.118/24 \
  ipv4.gateway 192.168.40.1 ipv4.dns "192.168.40.118" \
  ipv4.dns-search "innokentii-kozlov.com" ipv4.ignore-auto-dns yes bridge.stp no
sudo nmcli con add type ethernet con-name br0-port1 ifname enp1s0 master br0
sudo nmcli con up br0          # SSH drops briefly; reconnect to .118 (now on br0)
sudo nmcli con delete "Wired connection 1"
```

### Disk

Root disk is a 40 GiB qcow2 overlay on the Fedora Cloud base image (CoW, not a full copy):

```
backing_store: /var/lib/libvirt/images/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2
size: 40
```

`virt-install --import` creates the overlay and boots from it in one step.

### Cloud-init

Generated from `input_vars.yaml` + `cloud-init/*.j2` templates by the `generate-cloud-init` Ansible workflow. Configures: static IP, hostname, `admin` user with SSH key, hardened sshd (key-only), Docker CE, resolv.conf -> blocky.

### Bring-up

```bash
make -C vms build/cloud-init/ci-lab     # render cloud-init.iso + ssh keys -> target/ci-lab/
make -C vms copy/cloud-init/ci-lab      # scp iso -> host /var/lib/libvirt/images/ci-lab/
make -C vms start/ci-lab                # virt-install: create 40G overlay + boot (--import)
```

Wait ~1-2 min for cloud-init, then SSH in:
```bash
ssh -i vms/target/ci-lab/ssh-keys/id_rsa admin@192.168.40.119
```

### Deploy Woodpecker stack (manual)

Stack files live in `vms/ci-lab/stack/` and are copied directly to the VM at `/home/admin/woodpecker-ci/`. No Ansible deploy workflow needed.

**Prerequisites:**
- Forgejo OAuth2 application at `https://forgejo.innokentii-kozlov.com` with redirect URI `https://ci-lab.innokentii-kozlov.com/authorize`
- Caddy on host proxies `ci-lab.innokentii-kozlov.com` -> `192.168.40.119:80` (already in `stack/config/caddy/Caddyfile`)

**1. Copy stack files to VM:**
```bash
ssh -i vms/target/ci-lab/ssh-keys/id_rsa admin@192.168.40.119 'mkdir -p /home/admin/woodpecker-ci/{nginx,postgres}'
scp -i vms/target/ci-lab/ssh-keys/id_rsa vms/ci-lab/stack/compose.yaml admin@192.168.40.119:/home/admin/woodpecker-ci/
scp -i vms/target/ci-lab/ssh-keys/id_rsa vms/ci-lab/stack/nginx/nginx.conf admin@192.168.40.119:/home/admin/woodpecker-ci/nginx/
scp -i vms/target/ci-lab/ssh-keys/id_rsa vms/ci-lab/stack/postgres/init.sql admin@192.168.40.119:/home/admin/woodpecker-ci/postgres/
```

**2. Create `.env` on VM at `/home/admin/woodpecker-ci/.env`:**
```bash
WOODPECKER_HOST=https://ci-lab.innokentii-kozlov.com
WOODPECKER_ADMIN=innokentii-kozlov              # your Forgejo username
WOODPECKER_GITEA_CLIENT=<from Forgejo OAuth app>
WOODPECKER_GITEA_SECRET=<from Forgejo OAuth app>
WOODPECKER_AGENT_SECRET=$(openssl rand -hex 32)
WOODPECKER_PROMETHEUS_AUTH_TOKEN=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 32)
```

**3. Bring up the stack:**
```bash
ssh -i vms/target/ci-lab/ssh-keys/id_rsa admin@192.168.40.119 \
  'cd /home/admin/woodpecker-ci && docker compose --env-file .env up -d'
```

**4. Verify:**
```bash
curl -sS -o /dev/null -w "HTTP %{http_code}\n" https://ci-lab.innokentii-kozlov.com   # expect 200
```

Then open `https://ci-lab.innokentii-kozlov.com` in a browser and log in via Forgejo.

### Notes

- Postgres runs without SSL (internal to the docker network only). `POSTGRES_DB: woodpecker` handles database creation — `init.sql` is empty.
- `WOODPECKER_OPEN: "true"` allows any Forgejo user to register. Set to `"false"` after initial setup to lock it down.
- The `forgejo-runner` container (if present) is unrelated to Woodpecker and can coexist.

### Traffic flow

```
client -> https://ci-lab.innokentii-kozlov.com
  -> blocky DNS resolves to 192.168.40.118 (host)
  -> Caddy (host, :443, Route53 TLS) reverse_proxy 192.168.40.119:80
  -> nginx (VM) -> woodpecker-server:8000
```

### Files

| Path | Purpose |
|------|---------|
| `ci-lab/vm.yaml` | VM definition (CPU, mem, disks, network, virt-install args) |
| `ci-lab/input_vars.yaml` | Cloud-init input (hostname, IP, gateway, DNS, MAC) |
| `ci-lab/cloud-init/*.j2` | Cloud-init templates (user-data, meta-data, network-config) |
| `ci-lab/stack/` | Woodpecker stack (compose, nginx, postgres) |
| `target/ci-lab/` | Build output (iso, ssh keys, credentials) — gitignored |
