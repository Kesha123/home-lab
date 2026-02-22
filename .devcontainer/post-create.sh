#!/usr/bin/env bash
set -euo pipefail

# just to be sure after apt update
echo "### chmod +s /usr/lib/qemu/qemu-bridge-helper"
sudo chmod +s /usr/lib/qemu/qemu-bridge-helper

# Add user to libvirt group for KVM access
echo "### adding user to libvirt group"
if getent group libvirt >/dev/null 2>&1; then
    sudo usermod -a -G libvirt "${USER}"
    echo "User ${USER} added to libvirt group"
else
    echo "Warning: libvirt group not found"
fi

# Add user to docker group for Docker daemon access
echo "### adding user to docker group"
if getent group docker >/dev/null 2>&1; then
    sudo usermod -a -G docker "${USER}"
    echo "User ${USER} added to docker group"
else
    echo "Warning: docker group not found"
fi

# Add user to systemd-journal group for docker socket access
# The docker socket is typically owned by root:systemd-journal
echo "### adding user to systemd-journal group"
if getent group systemd-journal >/dev/null 2>&1; then
    sudo usermod -a -G systemd-journal "${USER}"
    echo "User ${USER} added to systemd-journal group"
else
    echo "Warning: systemd-journal group not found"
fi

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc

cat <<EOT >> ~/.bashrc
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOT
source ~/.bashrc
echo "source <(docker completion bash)" >> ~/.bashrc
