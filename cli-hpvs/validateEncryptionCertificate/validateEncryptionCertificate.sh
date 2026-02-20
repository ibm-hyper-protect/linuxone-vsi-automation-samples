#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Sample certificate file
CERT_FILE="encryption.crt"

echo "=== Validate Hyper Protect Encryption Certificate ==="
echo ""
echo "This script validates encryption certificates to ensure they are valid"
echo "and not expired. This helps verify certificates before using them for"
echo "contract encryption operations."
echo ""

# Check if certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "WARNING: Certificate file not found: $CERT_FILE"
    echo ""
    echo "Download a certificate first using one of these methods:"
    echo ""
    echo "Method 1: Direct download"
    echo "  ./contract-cli download-certificate --version 1.0.23 --format json --out encryption.crt"
    echo ""
    echo "Method 2: Download and extract"
    echo "  ./contract-cli download-certificate --version 1.0.23,1.0.24 --format json --out certs.json"
    echo "  ./contract-cli get-certificate --in certs.json --version 1.0.23 --out encryption.crt"
    echo ""
    exit 1
fi

# Example 1: Validate encryption certificate
echo "=== Example 1: Validate encryption certificate ==="
if "$CLI" validate-encryption-certificate \
  --in "$CERT_FILE"; then
    echo "Certificate validation completed successfully"
else
    echo "Certificate validation failed"
    echo "   The certificate may be expired or invalid"
fi
echo ""


# Example 2: Validate using stdin (pipe)
echo "=== Example 2: Validate using stdin (pipe) ==="
if cat "$CERT_FILE" | "$CLI" validate-encryption-certificate \
  --in -; then
    echo "Certificate validation completed successfully (stdin input)"
else
    echo "Certificate validation failed"
    echo "   The certificate may be expired or invalid"
fi
echo ""


# Example 3: Validate certificate from different location
CERT_FILE_2="./certs/encryption_1.0.24.crt"
if [ -f "$CERT_FILE_2" ]; then
    echo "=== Example 2: Validate certificate from different location ==="
    if "$CLI" validate-encryption-certificate \
      --in "$CERT_FILE_2"; then
        echo "Certificate validation completed successfully"
    else
        echo "Certificate validation failed"
    fi
    echo ""
fi

# Example 3: Demonstrate validation workflow
echo "=== Example 4: Complete validation workflow ==="
echo "Step 1: Download certificate"
if "$CLI" download-certificate \
  --version 1.0.23 \
  --format json \
  --out temp_cert.crt 2>/dev/null; then
    echo "  Certificate downloaded"
    
    echo "Step 2: Validate downloaded certificate"
    if "$CLI" validate-encryption-certificate \
      --in temp_cert.crt; then
        echo "Certificate is valid and ready for use"
    else
        echo "Certificate validation failed"
    fi
    
    # Clean up
    rm -f temp_cert.crt
else
    echo "  Certificate download failed (this is expected if offline)"
fi
echo ""

echo "Script completed!"

