#!/bin/sh
set -eu

IMAGES_DIR="$1"
BOARD_DIR="$2"
VERSION="${VERSION:-1.0.1}"
OUTPUT_DIR="$(dirname "${IMAGES_DIR}")"
RAUC_BIN="${RAUC_BIN:-${OUTPUT_DIR}/host/bin/rauc}"
CERTS_DIR="${OUTPUT_DIR}/generated-certs"
BUNDLE_PATH="${IMAGES_DIR}/update-${VERSION}.raucb"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cp "${IMAGES_DIR}/rootfs.ext4" "${WORKDIR}/rootfs.ext4"

"${BOARD_DIR}/ensure-dev-certs.sh" "${OUTPUT_DIR}"

sed "s/@VERSION@/${VERSION}/" \
  "${BOARD_DIR}/bundle/manifest.raucm.in" \
  > "${WORKDIR}/manifest.raucm"

[ -x "${RAUC_BIN}" ] || {
  echo "error: rauc tool not found at ${RAUC_BIN}" >&2
  exit 1
}

rm -f "${BUNDLE_PATH}"

"${RAUC_BIN}" bundle \
  --cert="${CERTS_DIR}/dev.cert.pem" \
  --key="${CERTS_DIR}/dev.key.pem" \
  "${WORKDIR}" \
  "${BUNDLE_PATH}"
