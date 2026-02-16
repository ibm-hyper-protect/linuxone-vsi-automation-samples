#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Paths to required files
ENCRYPTED_ATTESTATION_FILE="./se-checksums.txt.enc"
PRIVATE_KEY_FILE="./private.key"
DECRYPTED_OUTPUT_FILE="decrypted_attestation.txt"

echo "=== Decrypt Attestation Records ==="
echo ""
echo "This script decrypts encrypted attestation records from Hyper Protect instances."
echo "Attestation records are typically found at /var/hyperprotect/se-checksums.txt.enc"
echo ""

# Check if required files exist
if [ ! -f "$ENCRYPTED_ATTESTATION_FILE" ]; then
    echo "Error: Encrypted attestation file not found at: $ENCRYPTED_ATTESTATION_FILE"
    echo "Please ensure you have downloaded the encrypted attestation file from your HPVS instance."
    exit 1
fi

if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "Error: Private key file not found at: $PRIVATE_KEY_FILE"
    echo "Please ensure you have the private key that corresponds to the public key used during instance creation."
    exit 1
fi

echo "Found required files:"
echo "  - Encrypted attestation: $ENCRYPTED_ATTESTATION_FILE"
echo "  - Private key: $PRIVATE_KEY_FILE"
echo ""

# Example 1: Decrypt and save to file
echo "=== Example 1: Decrypt and save to file ==="
"$CLI" decrypt-attestation \
  --in "$ENCRYPTED_ATTESTATION_FILE" \
  --priv "$PRIVATE_KEY_FILE" \
  --out "$DECRYPTED_OUTPUT_FILE"

echo "Decrypted attestation saved to: $DECRYPTED_OUTPUT_FILE"
echo ""


# Example 2: Decrypt and output to stdout
echo "=== Example 2: Decrypt and output to stdout ==="
"$CLI" decrypt-attestation \
  --in "$ENCRYPTED_ATTESTATION_FILE" \
  --priv "$PRIVATE_KEY_FILE"

echo ""
echo "Script completed successfully!"
echo ""
echo "The decrypted attestation records contain cryptographic hashes that can be used to:"
echo "  - Verify workload integrity"
echo "  - Confirm the contract deployed matches expectations"
echo "  - Validate the security configuration of your HPVS instance"
