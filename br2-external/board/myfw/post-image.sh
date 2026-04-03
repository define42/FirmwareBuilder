#!/bin/sh
set -eu

BINARIES_DIR="$1"
BR2_CONFIG="$2"
BASE_DIR="$3"
shift 3

GENIMAGE_CFG="${BR2_EXTERNAL_MYFW_PATH}/board/myfw/genimage.cfg"

rm -rf "${BINARIES_DIR}/genimage.tmp"
mkdir -p "${BINARIES_DIR}/genimage.tmp"

genimage \
  --rootpath "${BASE_DIR}/target" \
  --tmppath "${BINARIES_DIR}/genimage.tmp" \
  --inputpath "${BINARIES_DIR}" \
  --outputpath "${BINARIES_DIR}" \
  --config "${GENIMAGE_CFG}"
