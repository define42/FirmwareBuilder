#!/bin/sh
set -eu

IMAGES_DIR="$1"
BOARD_DIR="$2"
VERSION="${VERSION:-1.0.1}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cp "${IMAGES_DIR}/rootfs.ext4" "${WORKDIR}/rootfs.ext4"

sed "s/@VERSION@/${VERSION}/" \
  "${BOARD_DIR}/bundle/manifest.raucm.in" \
  > "${WORKDIR}/manifest.raucm"

rauc bundle \
  --cert="${BOARD_DIR}/certs/dev.cert.pem" \
  --key="${BOARD_DIR}/certs/dev.key.pem" \
  "${WORKDIR}" \
  "${IMAGES_DIR}/update-${VERSION}.raucb"
