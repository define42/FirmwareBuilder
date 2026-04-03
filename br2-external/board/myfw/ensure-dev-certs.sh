#!/bin/sh
set -eu

OUTPUT_DIR="${1:?usage: ensure-dev-certs.sh OUTPUT_DIR}"
CERTS_DIR="${OUTPUT_DIR}/generated-certs"

OPENSSL_BIN="${OPENSSL_BIN:-$(command -v openssl || true)}"

if [ -z "${OPENSSL_BIN}" ]; then
  echo "error: openssl not found; install openssl to generate development RAUC certificates" >&2
  exit 1
fi

mkdir -p "${CERTS_DIR}"

CA_CERT="${CERTS_DIR}/dev-ca.cert.pem"
CA_KEY="${CERTS_DIR}/dev-ca.key.pem"
CERT="${CERTS_DIR}/dev.cert.pem"
KEY="${CERTS_DIR}/dev.key.pem"
CSR="${CERTS_DIR}/dev.csr.pem"
EXT="${CERTS_DIR}/dev.ext"
SERIAL="${CERTS_DIR}/dev-ca.cert.srl"

cert_is_valid() {
  [ -s "$1" ] && "${OPENSSL_BIN}" x509 -in "$1" -noout >/dev/null 2>&1
}

key_is_valid() {
  [ -s "$1" ] && "${OPENSSL_BIN}" pkey -in "$1" -noout >/dev/null 2>&1
}

if cert_is_valid "${CA_CERT}" &&
   key_is_valid "${CA_KEY}" &&
   cert_is_valid "${CERT}" &&
   key_is_valid "${KEY}"; then
  exit 0
fi

echo "Generating development RAUC certificates in ${CERTS_DIR}" >&2

rm -f "${CA_CERT}" "${CA_KEY}" "${CERT}" "${KEY}" "${CSR}" "${EXT}" "${SERIAL}"

"${OPENSSL_BIN}" genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:2048 \
  -out "${CA_KEY}"
chmod 600 "${CA_KEY}"

"${OPENSSL_BIN}" req \
  -x509 \
  -new \
  -sha256 \
  -days 3650 \
  -subj "/CN=MyFW Development CA" \
  -key "${CA_KEY}" \
  -out "${CA_CERT}"

"${OPENSSL_BIN}" genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:2048 \
  -out "${KEY}"
chmod 600 "${KEY}"

"${OPENSSL_BIN}" req \
  -new \
  -sha256 \
  -subj "/CN=MyFW Development Bundle" \
  -key "${KEY}" \
  -out "${CSR}"

cat > "${EXT}" <<'EOF'
basicConstraints=CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF

"${OPENSSL_BIN}" x509 \
  -req \
  -sha256 \
  -days 3650 \
  -in "${CSR}" \
  -CA "${CA_CERT}" \
  -CAkey "${CA_KEY}" \
  -CAcreateserial \
  -extfile "${EXT}" \
  -out "${CERT}"

rm -f "${CSR}" "${EXT}" "${SERIAL}"
