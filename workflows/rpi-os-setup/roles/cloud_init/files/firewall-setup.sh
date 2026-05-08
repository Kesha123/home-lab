#!/usr/bin/env bash
set -euo pipefail

_main() {
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing

  ufw allow 22/tcp comment 'SSH'
  ufw allow 443/tcp comment 'HTTPS'
  ufw allow 6443/tcp comment 'api-server'

  # Allow local network traffic if needed
  ufw allow from 192.168.0.0/24

  ufw --force enable

  echo "Firewall status:"
  ufw status numbered
}

_main "$@"
