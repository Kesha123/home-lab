#!/usr/bin/env bash
set -euo pipefail

# Configure UFW for a secure baseline
_main() {
  echo "Configuring firewall..."

  # Ensure UFW is installed
  if ! command -v ufw >/dev/null; then
    echo "UFW not found, attempting to install..."
    apt-get update && apt-get install -y ufw
  fi

  # Reset to defaults
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing

  # Allow essential services
  ufw allow 22/tcp comment 'SSH'
  ufw allow 443/tcp comment 'HTTPS'
  ufw allow 6443/tcp comment 'api-server'

  # Allow local network traffic if needed
  ufw allow from 192.168.0.0/24

  # Enable firewall
  ufw --force enable

  echo "Firewall status:"
  ufw status numbered
}

_main "$@"
