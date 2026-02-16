#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Example 1: Plain Base64 tar.gz from docker-compose.yaml
COMPOSE_FOLDER="./compose"
PLAIN_OUTPUT_FILE="plain_base64tgz_output.txt"

echo "=== Example 1: Plain Base64 tar.gz ==="
"$CLI" base64-tgz \
  --in "$COMPOSE_FOLDER" \
  --output plain \
  --out "$PLAIN_OUTPUT_FILE"

echo "Plain Base64 tar.gz Output saved to: $PLAIN_OUTPUT_FILE"
echo ""


# Example 2: Encrypted Base64 tar.gz
ENCRYPTED_OUTPUT_FILE="encrypted_base64tgz_output.txt"
CERT_PATH="./encryption.crt"

echo "=== Example 2: Encrypted Base64 tar.gz ==="
echo "Note: This requires a valid encryption certificate at $CERT_PATH"
echo "Uncomment the following lines if you have a certificate:"
echo ""

# Uncomment these lines when you have a valid certificate
# "$CLI" base64-tgz \
#   --in "$COMPOSE_FOLDER" \
#   --output encrypt \
#   --os hpvs \
#   --cert "$CERT_PATH" \
#   --out "$ENCRYPTED_OUTPUT_FILE"
# 
# echo "Encrypted Base64 tar.gz Output saved to: $ENCRYPTED_OUTPUT_FILE"


# Example 3: Output to stdout (no --out flag)
echo "=== Example 3: Output to stdout ==="
"$CLI" base64-tgz \
  --in "$COMPOSE_FOLDER" \
  --output plain

echo ""
echo "Script completed successfully!"
