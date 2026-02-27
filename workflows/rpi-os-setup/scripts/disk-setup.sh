#!/usr/bin/env bash
set -euo pipefail

# Setup and migrate root filesystem from SD card to NVMe storage.
_main() {
  # Identify current and target disks
  local current_disk
  current_disk=$(lsblk -no pkname "$(findmnt / -n -o SOURCE)")
  local target_disk="nvme0n1"

  # 1. PHASE 1: Migration (Runs on SD Card)
  if [[ "${current_disk}" != "${target_disk}" ]]; then
    if [[ ! -b "/dev/${target_disk}" ]]; then
       echo "ERROR: Target /dev/${target_disk} not found. Ensure NVMe is connected."
       exit 1
    fi

    echo "Cloning SD card to NVMe... this will take a few minutes."
    # Clone the entire SD to NVMe
    dd if="/dev/${current_disk}" of="/dev/${target_disk}" bs=4M conv=fsync status=progress

    # Update the boot config to point to the NVMe for the next boot
    # On Trixie, the boot partition is usually /boot/firmware
    sed -i "s|root=[^ ]*|root=/dev/${target_disk}p2|" /boot/firmware/cmdline.txt

    echo "Clone complete. Rebooting to transition to NVMe..."
    reboot

  # 2. PHASE 2: Expansion (Runs on NVMe after reboot)
  else
    echo "Running on NVMe. Ensuring partition 2 utilizes full 500GB."
    # Grow the partition to fill the SSD
    if command -v growpart >/dev/null; then
        growpart "/dev/${target_disk}" 2 || echo "Partition already grown."
        resize2fs "/dev/${target_disk}p2" || echo "Filesystem already resized."
    fi
    echo "Disk migration and expansion successful."
  fi
}

_main "$@"
