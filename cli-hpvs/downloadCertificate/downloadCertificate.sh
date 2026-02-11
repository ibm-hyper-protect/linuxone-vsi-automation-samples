#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Output files
CERTIFICATES_JSON="certificates.json"
CERTIFICATES_YAML="certificates.yaml"
SINGLE_CERT_FILE="encryption_cert.crt"

echo "=== Download Encryption Certificates ==="
echo ""
echo "This script downloads encryption certificates from the IBM Hyper Protect Repository."
echo "These certificates are required for encrypting contracts and workload configurations."
echo ""

# Example 1: Download specific certificate versions in JSON format
echo "=== Example 1: Download specific versions (JSON format) ==="
"$CLI" download-certificate \
  --version 1.0.23,1.0.24 \
  --format json \
  --out "$CERTIFICATES_JSON"

echo "Downloaded certificates saved to: $CERTIFICATES_JSON"
echo ""


# Example 2: Download specific certificate versions in YAML format
echo "=== Example 2: Download specific versions (YAML format) ==="
"$CLI" download-certificate \
  --version 1.0.23,1.0.24 \
  --format yaml \
  --out "$CERTIFICATES_YAML"

echo "Downloaded certificates saved to: $CERTIFICATES_YAML"
echo ""


# Example 3: Download and output to stdout (JSON)
echo "=== Example 3: Download and output to stdout ==="
"$CLI" download-certificate \
  --version 1.0.23 \
  --format json

echo ""


# Example 4: Download latest version
echo "=== Example 4: Download latest certificate version ==="
echo "To download the latest version, check IBM documentation for the current version number."
echo "Example command:"
echo "  $CLI download-certificate --version 1.0.24 --format json --out latest_cert.json"
echo ""

echo "Script completed successfully!"
