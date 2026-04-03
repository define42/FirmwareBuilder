#!/bin/sh
set -eu

TARGET_DIR="$1"
BOARD_DIR="$(dirname "$0")"

chmod +x "${TARGET_DIR}/etc/init.d/S40rauc-mark-good"

install -d "${TARGET_DIR}/etc/rauc"
install -m 0644 "${BOARD_DIR}/certs/dev-ca.cert.pem" \
  "${TARGET_DIR}/etc/rauc/ca.cert.pem"

mkdir -p "${TARGET_DIR}/data"
mkdir -p "${TARGET_DIR}/var"
mkdir -p "${TARGET_DIR}/var/lib"

rm -rf "${TARGET_DIR}/var/log"
ln -s /data/log "${TARGET_DIR}/var/log"

echo "Build: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "${TARGET_DIR}/etc/build-info"
