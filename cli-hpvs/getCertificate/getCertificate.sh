#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Input file containing downloaded certificates
CERTIFICATES_JSON="certificates.json"

# Output files
SINGLE_CERT_FILE="encryption_cert.crt"
EXTRACTED_CERT_1="cert_1.0.23.crt"
EXTRACTED_CERT_2="cert_1.0.24.crt"

echo "=== Extract Encryption Certificate from Downloaded Certificates ==="
echo ""
echo "This script extracts specific certificate versions from a previously downloaded"
echo "certificates file. This is useful when you've downloaded multiple versions and"
echo "need to extract a specific one for encryption operations."
echo ""

# First, download certificates if not already present
if [ ! -f "$CERTIFICATES_JSON" ]; then
    echo "Downloading certificates first..."
    "$CLI" download-certificate \
      --version 1.0.23,1.0.24 \
      --format json \
      --out "$CERTIFICATES_JSON"
    echo "Downloaded certificates saved to: $CERTIFICATES_JSON"
    echo ""
fi

# Example 1: Extract specific version from downloaded certificates
echo "=== Example 1: Extract specific version (1.0.23) ==="
"$CLI" get-certificate \
  --in "$CERTIFICATES_JSON" \
  --version 1.0.23 \
  --out "$EXTRACTED_CERT_1"

echo "Extracted certificate version 1.0.23 saved to: $EXTRACTED_CERT_1"
echo ""


# Example 2: Extract different version
echo "=== Example 2: Extract different version (1.0.24) ==="
"$CLI" get-certificate \
  --in "$CERTIFICATES_JSON" \
  --version 1.0.24 \
  --out "$EXTRACTED_CERT_2"

echo "Extracted certificate version 1.0.24 saved to: $EXTRACTED_CERT_2"
echo ""


# Example 3: Extract and output to stdout
echo "=== Example 3: Extract and output to stdout ==="
"$CLI" get-certificate \
  --in "$CERTIFICATES_JSON" \
  --version 1.0.23

echo ""


# Example 4: Extract latest version for encryption
echo "=== Example 4: Extract for encryption operations ==="
echo "Extracting certificate for use with encrypt commands..."
"$CLI" get-certificate \
  --in "$CERTIFICATES_JSON" \
  --version 1.0.24 \
  --out "$SINGLE_CERT_FILE"

echo "Certificate ready for encryption: $SINGLE_CERT_FILE"
echo ""
echo "You can now use this certificate with encrypt or encrypt-string commands:"
echo "  $CLI encrypt --in contract.yaml --cert $SINGLE_CERT_FILE --out encrypted_contract.yaml"
echo "  $CLI encrypt-string --in 'MyPassword' --cert $SINGLE_CERT_FILE --out encrypted_password.txt"
echo ""

echo "Script completed successfully!"
