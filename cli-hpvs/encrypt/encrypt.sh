#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Required files
CONTRACT_FILE="./contract.yaml"
ENCRYPTION_CERT="./encryption.crt"
PRIVATE_KEY="./private.key"
OUTPUT_FILE="encrypted_contract.txt"

echo "=== Generate Signed and Encrypted Contract ==="
echo ""
echo "This script creates a signed and encrypted contract"
echo "for Hyper Protect Virtual Server deployment."
echo ""

# Check if required files exist
if [ ! -f "$CONTRACT_FILE" ]; then
    echo "Error: Contract file not found at: $CONTRACT_FILE"
    echo "Please create a contract YAML file with your workload configuration."
    exit 1
fi

if [ ! -f "$ENCRYPTION_CERT" ]; then
    echo "Error: Encryption certificate not found at: $ENCRYPTION_CERT"
    echo "Download it using one of these methods:"
    echo "  1. Direct download: ./contract-cli download-certificate --version <version> --format json --out encryption.crt"
    echo "  2. Download and extract: ./contract-cli download-certificate --version <version> --format json --out certs.json"
    echo "                           ./contract-cli get-certificate --in certs.json --version <version> --out encryption.crt"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "Error: Private key not found at: $PRIVATE_KEY"
    echo "Generate a key pair using: openssl genrsa -out private.key 4096"
    exit 1
fi

echo "Found required files:"
echo "  - Contract: $CONTRACT_FILE"
echo "  - Encryption certificate: $ENCRYPTION_CERT"
echo "  - Private key: $PRIVATE_KEY"
echo ""

# Example 1: Basic signed and encrypted contract
echo "=== Example 1: Basic Signed and Encrypted Contract ==="
"$CLI" encrypt \
  --in "$CONTRACT_FILE" \
  --cert "$ENCRYPTION_CERT" \
  --priv "$PRIVATE_KEY" \
  --out "$OUTPUT_FILE"

echo "Encrypted contract saved to: $OUTPUT_FILE"
echo ""


# Example 2: Signed and encrypted contract with OS version
echo "=== Example 2: With Specific OS Version ==="
"$CLI" encrypt \
  --in "$CONTRACT_FILE" \
  --os hpvs \
  --cert "$ENCRYPTION_CERT" \
  --priv "$PRIVATE_KEY" \
  --out "encrypted_contract_hpvs.txt"

echo "HPVS-specific encrypted contract saved to: encrypted_contract_hpvs.txt"
echo ""


# Example 3: Output to stdout
echo "=== Example 3: Output to Stdout ==="
echo "Generating encrypted contract (first 200 characters):"
"$CLI" encrypt \
  --in "$CONTRACT_FILE" \
  --cert "$ENCRYPTION_CERT" \
  --priv "$PRIVATE_KEY" | head -c 200
echo "..."
echo ""


# Example 4: Contract with expiry (commented out - requires additional files)
echo "=== Example 4: Contract with Expiry Feature ==="
echo "For contracts with expiry, you need additional CA certificate and key files."
echo "Uncomment the following lines if you have the required files:"
echo ""
echo "# CA_CERT=\"./ca.crt\""
echo "# CA_KEY=\"./ca.key\""
echo "# CSR_PARAMS=\"./csr_params.json\""
echo "# CSR_FILE=\"./csr.pem\""
echo "# EXPIRY_DAYS=90"
echo "#"
echo "# $CLI encrypt \\"
echo "#   --in \"$CONTRACT_FILE\" \\"
echo "#   --cert \"$ENCRYPTION_CERT\" \\"
echo "#   --priv \"$PRIVATE_KEY\" \\"
echo "#   --contract-expiry \\"
echo "#   --cacert \"$CA_CERT\" \\"
echo "#   --cakey \"$CA_KEY\" \\"
echo "#   --csrParam \"$CSR_PARAMS\" \\"
echo "#   --csr \"$CSR_FILE\" \\"
echo "#   --expiry $EXPIRY_DAYS \\"
echo "#   --out encrypted_contract_expiry.txt"
echo ""

echo "Script completed successfully!"
echo ""
echo "The encrypted contract can now be used to deploy your workload on:"
echo "  - Hyper Protect Virtual Server (HPVS)"
echo "  - Hyper Protect Container Runtime on Red Hat Virtualization (HPCR-RHVS)"
echo "  - Hyper Protect Confidential Containers (HPCC) Peer Pods"
