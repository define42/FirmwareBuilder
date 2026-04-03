#!/bin/sh
set -eu

BOARD_DIR="$(dirname "$0")"
BINARIES_DIR="${1:-${BINARIES_DIR:?}}"
TARGET_DIR="${TARGET_DIR:?}"

GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"

install -D -m 0644 \
  "${TARGET_DIR}/boot/grub/grub.cfg" \
  "${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg"

support/scripts/genimage.sh -c "${GENIMAGE_CFG}"
