# Home Lab

## Devices

```yaml
rpi-5:
  name: Raspberry Pi 5
  description: My personal rpi 5 i have at home. It is main "node" in my home lab. It hosts k3s and all underlying applications.
  network:
    ipv4: 192.168.0.80
    static: true
    ethernet: true
    wifi: false
    open_ports:
    - 443
    - 22 # Only during installation. After installation, during hardening, this port will be disabled.
    public_ip: false
  disks:
  - name: NVME SSD 500Gb
    size: 500Gb
    device: /dev/nvme0n1
  - name: SATA SSD 120Gb
    size: 120Gb
    device: /dev/sda
  users:
    - name: admin
      permissions: [containerd, kubectl, nerdctl, virtctl]
      ssh_connection: true
    - name: root
      permissions: everything
      ssh_connection: false
vps:
  name: Cloud VPS
  description: Cloud VPS to host Pangolin server to securely route traffic to my home lab
  deployment: AWS
  network:
    ports: [80, 443, 51820, 21820]
  disks:
    - name: cloud-init
    - name: root # root disk of the AWS EC2 VM
  users:
    - name: admin
      permissions: [containerd, nerdctl]
      ssh_connection: false
    - name: root
      permissions: everything
      ssh_connection: false
  applications: [containerd, nerdctl]
```

## Architecture Overview

- **Physical:** Raspberry Pi 5 hosts single-node K3s; AWS VPS terminates Pangolin (WireGuard) and exposes HTTPS management. Pangolin serves as the only inbound path to the lab; LAN services stay on the home network.
- **Control plane:** K3s uses embedded etcd (suitable up to ~3 nodes). Kubernetes API is exposed via MetalLB VIP `192.168.0.200` so additional nodes can join behind a stable endpoint.
- **Ingress & DNS:** Traefik (K3s default) fronted by MetalLB ingress VIP `192.168.0.201`. Pi-hole runs on MetalLB VIP `192.168.0.202` for internal resolution; Route53 handles public zones with optional split-horizon records.
- **MetalLB pool:** `192.168.0.200-192.168.0.220`, outside DHCP scope; reserve VIPs above. Ensure router will not lease this pool.
- **Storage:** Default `local-path` on Pi SSDs; Home Assistant root PVC on `/dev/sda` (suggest 32GiB), data PVC on `/dev/sda` (suggest 128GiB). Plan to adopt Longhorn for multi-node resilience later.
- **Secrets:** Vault as source of truth; plan to deliver via External Secrets Operator or Vault Agent Injector with Kubernetes auth.
- **Backups/ops:** Restic/rclone to Google Drive with encryption; include etcd snapshots, PV data (Grafana/Prometheus/Loki, Home Assistant), and Vault data. Define RPO/RTO per app.

## Development Milestones

1. **Base Platform Bring-up**
  - Deliverables: rpi5 imaging with cloud-init; containerd/nerdctl; single-node K3s with Traefik; MetalLB configured with pool/VIPs reserved.
  - Depends on: Raspberry Pi 5 preparation.
2. **Network Edge (Pangolin/VPS)**
  - Deliverables: AWS VPS with Pangolin WireGuard tunnel, HTTPS UI on 443, SGs restricted, health checks/auto-restart and monitoring for tunnel latency.
  - Depends on: Base Platform Bring-up; can proceed in parallel with Auth & Secrets.
3. **Auth & Secrets**
  - Deliverables: Authentik for OIDC, Vault deployed, Kubernetes auth, secrets delivery via External Secrets Operator or Vault Agent Injector, ingress OIDC protection.
  - Depends on: Base Platform Bring-up.
4. **DNS & Observability**
  - Deliverables: Pi-hole on VIP for internal DNS; Route53 records/split-horizon; cert-manager with Route53 solver; Prometheus/Grafana/Loki/Alertmanager with Telegram alerts and retention set.
  - Depends on: Base Platform Bring-up; coordinates with Auth & Secrets for alert auth endpoints.
5. **App Platform & Data Services**
  - Deliverables: ArgoCD bootstrapped; ApplicationSets for Pi-hole, Grafana, Prometheus, Loki, Pangolin client, Home Page Dashboard, KubeVirt/CDI, MetalLB, PicoClaw, Firefly iii; Home Assistant PVC sizing (root/data) on /dev/sda; storage plan documented (local-path now, Longhorn later).
  - Depends on: Auth & Secrets and DNS & Observability.
6. **Backups, Hardening, and Runtime Ops**
  - Deliverables: Restic/rclone encrypted backups (etcd, PVs, Vault), RPO/RTO per app, SSH/host hardening with break-glass path, K3s hardening (PodSecurity Baseline/Restricted, NetworkPolicies), rotation workflows for certs/passwords/AWS creds, monitoring checks for Vault/Authentik/Ingress.
  - Depends on: App Platform & Data Services; runs continuously post-cutover.

## Applications & Services

### Rules
1. All applications are accessible only via encrypted connection (https)
2. All applications authentication is handled by OIDC Authentik
3. Applications are deployed either with as Compose service with containerD container runtime or ArgoCD Application (ApplicationSet)

### ArgoCD ApplicationSet

1. Pihole
2. Grafana
3. Prometheus
4. Loki
5. Pangolin client
6. Home Page Dashboard
7. Kubevirt & CDI
8.  MetalLB
9.  PicoClaw
10. Firefly iii

### K3S Kubevirt VMs (managed by ArgoCD):

Home Assistant is deployed as KubeVirt Virtual Machine.

```yaml
home_assistant:
  name: Home Assistant
  network:
    ipv4: 192.168.0.91
    description: This VM should be available on my home network, so it will be visible as separate device.
  disks:
    - name: cloud-init
    - name: Root
      type: dataVolume
      ephemeral: false
      location: PVC on rpi-5 /dev/sda
      disk: https://github.com/home-assistant/operating-system/releases/download/17.1/haos_ova-17.1.qcow2.xz
    - name: Data
      type: dataVolume
      ephemeral: false
      location: PVC on rpi-5 /dev/sda
      disk: Prefilled with K8S job PVC
```

### Containers
1. Authentik
2. HashiCorp Vault

## Raspberry Pi 5 Cloud Init
1. Create & configure users
2. Configure networking
3. Configure disks
4. Install applications
5. Configure SSH

## VPS
VPS is used to host Pangolin server to securely access my home lab. AWS is used as cloud provider. VPS is deployed using pulumi & golang. Pulumi backend is hosted in encrypted file on Raspberry Pi 5.

- **Pangolin/WireGuard:** UDP `51820` for tunnels. HTTPS management on `443` via Pangolin UI; restrict security groups to home IPs when possible and enforce Authentik/WireGuard auth.

## Scenarios
1. Installation
2. Runtime

## Installation Steps

### Raspberry Pi 5 preparation
1. Generate cloud-init for rpi 5.
2. Create flash USB drive for rpi 5.
3. Insert USB drive to rpi 5 & start OS installation.

### K3S installation
K3S ansible installation is available in ansible-galaxy with repo https://github.com/k3s-io/k3s-ansible.git
1. Download OCI image, which is used to execute ansible
2. Run OCI container, which runs ansible workflow, installing k3S on rpi 5.

### Container Services Installation
1. Ensure containerd on rpi 5.
2. Ensure nerdctl on rpi 5.
3. Bring up vault container.
4. Bring up authentik container.

### Pulumi Installation
1. Ensure containerd on rpi 5.
2. Ensure nerdctl on rpi 5.
3. Execute pulumi in container to initialise backend.

### VPS (Pangolin)
1. Ensure containerd on rpi 5.
2. Ensure nerdctl on rpi 5.
3. Execute pulumi in container to bring up AWS infrastructure for VPS.

### ArgoCD Installation
1. Ensure containerd on rpi 5.
2. Ensure nerdctl on rpi 5.
3. Execute ansible workflow installing and configuring ArgoCD on K3S.

### Raspberry Pi 5 Hardening
1. Disable port 22
2. Disable SSH
3. Clean up SSH keys

### VPS hardening
1. Ensure containerd on rpi 5.
2. Ensure nerdctl on rpi 5.
3. Check state drift against pulumi backend.
4. Scan cloud infra for vulnerabilities.

## Runtime Operations
These are executed separately and do not depend on each other. Performed with crontab.
1. Rotate K3S certificates
   - separate workflow to rotate certificates
2. Rotate Applications certificates
   - backup certificates
   - workflow to rotate certificates
   - cleanup old certificates
3. Rotate Application passwords
  - workflow
  - update passwords in vault
4. Rotate AWS credentials in vault
   - workflow
   - update credentials in vault
5. Backup applications data to google drive
   - workflow

## Workflows
Workflows are ansible workflows. Workflows consists of:
1. Entry point workflow, for example, `workflow.yaml`
2. Roles
3. Role molecules
4. Group vars - if applicable
5. Assets - if applicable
6. Templates - if applicable

Workflows are executed from within container. All workflows, molecules as well, use the same container

### Workflows list
1. `rpi5-preparation`
   - create SSH keys
   - fill cloud-init templates for rpi 5
   - download rpi os ISO
   - insert cloud-init configs to rpi os ISO
2. `k3s-installation`
   - using ready made ansible collection perform K3s installation
3. `container-services-installation`
   - copy compose file to rpi 5
   - bring up services
  - wait until health checks pass for the services
4. `pulumi-installation`
   - pull OCI image with pulumi binary to rpi 5
   - initialize pulumi backend in encrypted file
5. `vps-installation`
   - execute pulumi in container to bring up AWS infrastructure for VPS.
6. `argocd-installation`
   - perform ArgoCD Installation
7. `rpi5-hardening`
   - perform rpi 5 hardening
8. `vps-hardening`
   - perform VPS hardening

## Documentation
Documentation is handled with mkdocs and hosted on github pages.

## CI
Github Actions are used as CI provider.

## Development Environment
- Devcontainer: debian:12.13, privileged/host net, tools pinned (Docker CLI, nerdctl, buildx, kind v0.31.0, kubectl v1.35.1, helm v4.1.1, pulumi 3.222.0).
- kind: single control-plane, installs Flannel+Multus, CDI, and KubeVirt via kubernetes/kind/setup.sh.
- Makefiles: namespaced targets like `kind/start-cluster`, `kind/stop-cluster`, `kind/export-kubeconfig`, `kind/install-stack`.
- CI: lint/unit/molecule, build artifacts, e2e in kind; collect kubeconfig/diagnostics on failure.
- Devcontainer stays minimal (no ansible/terraform/go); e2e checks ensure KubeVirt/CDI readiness.

Full details: [docs/Development/dev-environment-overview.md](docs/Development/dev-environment-overview.md).

## Images & Containers
containerd is a container runtime for the home lab.

1. Ansible runner image
2. Pulumi executor image

## Certificates
cert-manager is used to issue certificates with AWS route53 provider. I have domain name in route53.
