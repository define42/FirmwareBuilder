#!/bin/sh
set -eu

BOARD_DIR="$(dirname "$0")"
BINARIES_DIR="${1:-${BINARIES_DIR:?}}"
TARGET_DIR="${TARGET_DIR:?}"
HOST_DIR="${HOST_DIR:?}"

GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GRUB_ENV="${BINARIES_DIR}/efi-part/EFI/BOOT/grubenv"
GRUB_EDITENV="${HOST_DIR}/bin/grub-editenv"

install -D -m 0644 \
  "${TARGET_DIR}/boot/grub/grub.cfg" \
  "${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg"

"${GRUB_EDITENV}" "${GRUB_ENV}" create
"${GRUB_EDITENV}" "${GRUB_ENV}" set \
  "ORDER=A B" \
  "A_OK=1" \
  "A_TRY=0" \
  "B_OK=0" \
  "B_TRY=0"

support/scripts/genimage.sh -c "${GENIMAGE_CFG}"
