#!/usr/bin/env bash
set -euo pipefail

_main() {
    local sata_disk="/dev/sda"
    if [ -b "$sata_disk" ]; then
        # Wipe existing signatures so HAOS sees it as 'uninitialized'
        wipefs -a "$sata_disk"
        # Zap any remaining partition tables
        sgdisk --zap-all "$sata_disk"
        echo "SATA SSD ($sata_disk) is ready for passthrough."
    else
        echo "ERROR: SATA SSD not found at $sata_disk"
        exit 1
    fi
}

_main "$@"
