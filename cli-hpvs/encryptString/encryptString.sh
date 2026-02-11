#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Required files
ENCRYPTION_CERT="./encryption.crt"

echo "=== Encrypt String for Hyper Protect ==="
echo ""
echo "Output format: hyper-protect-basic.<encrypted-password>.<encrypted-string>"
echo ""

# Check if encryption certificate exists
if [ ! -f "$ENCRYPTION_CERT" ]; then
    echo "Error: Encryption certificate not found at: $ENCRYPTION_CERT"
    echo "Download it using one of these methods:"
    echo "  1. Direct download: ./contract-cli download-certificate --version <version> --format json --out encryption.crt"
    echo "  2. Download and extract: ./contract-cli download-certificate --version <version> --format json --out certs.json"
    echo "                           ./contract-cli get-certificate --in certs.json --version <version> --out encryption.crt"
    exit 1
fi

echo "Found encryption certificate: $ENCRYPTION_CERT"
echo ""

# Example 1: Encrypt plain text string
TEXT_INPUT="MySecretPassword123!"
TEXT_OUTPUT="encrypted_text.txt"

echo "=== Example 1: Encrypt Plain Text String ==="
echo "Input: $TEXT_INPUT"
"$CLI" encrypt-string \
  --in "$TEXT_INPUT" \
  --format text \
  --cert "$ENCRYPTION_CERT" \
  --out "$TEXT_OUTPUT"

echo "Encrypted text saved to: $TEXT_OUTPUT"
echo ""


# Example 2: Encrypt JSON string
JSON_INPUT='{"username":"admin","password":"secret123"}'
JSON_OUTPUT="encrypted_json.txt"

echo "=== Example 2: Encrypt JSON String ==="
echo "Input: $JSON_INPUT"
"$CLI" encrypt-string \
  --in "$JSON_INPUT" \
  --format json \
  --cert "$ENCRYPTION_CERT" \
  --out "$JSON_OUTPUT"

echo "Encrypted JSON saved to: $JSON_OUTPUT"
echo ""


# Example 3: Encrypt with specific OS version
echo "=== Example 3: Encrypt with Specific OS Version ==="
"$CLI" encrypt-string \
  --in "DatabasePassword456" \
  --format text \
  --os hpvs \
  --cert "$ENCRYPTION_CERT" \
  --out "encrypted_hpvs.txt"

echo "HPVS-specific encrypted string saved to: encrypted_hpvs.txt"
echo ""


# Example 4: Output to stdout
echo "=== Example 4: Output to Stdout ==="
echo "Encrypting API key and displaying result:"
"$CLI" encrypt-string \
  --in "api-key-xyz789" \
  --format text \
  --cert "$ENCRYPTION_CERT"

echo ""
echo "Script completed successfully!"
