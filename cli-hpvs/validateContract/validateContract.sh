#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Sample contract files
VALID_CONTRACT="contract.yaml"
INVALID_CONTRACT="invalid_contract.yaml"

echo "=== Validate Hyper Protect Contract Schema ==="
echo ""
echo "This script validates unencrypted Hyper Protect contracts against the schema"
echo "for different platforms (HPVS, HPCR-RHVS, HPCC-PeerPod). Validation helps"
echo "catch errors before encryption and deployment."
echo ""

# Check if contract file exists
if [ ! -f "$VALID_CONTRACT" ]; then
    echo "WARNING: Sample contract file not found: $VALID_CONTRACT"
    echo ""
    echo "Create a sample contract file first. Example structure:"
    echo ""
    cat << 'EOF'
env:
  type: env
  logging:
    logRouter:
      hostname: f61xxxxxx......ingress.us-south.logs.cloud.ibm.com
      iamApiKey: <your api key>
      port: 443
  volumes:
    volume1:
      mount: /data
      seed: seed1
      filesystem: ext4

workload:
  type: workload
  compose:
    archive: <base64-encoded-docker-compose>
  auths:
    docker.io:
      username: <username>
      password: <password>
EOF
    echo ""
    echo "Save this as $VALID_CONTRACT and run the script again."
    exit 1
fi

# Example 1: Validate contract for HPVS
echo "=== Example 1: Validate contract for HPVS ==="
if "$CLI" validate-contract \
  --in "$VALID_CONTRACT" \
  --os hpvs; then
    echo "Contract is valid for HPVS platform"
else
    echo "Contract validation failed for HPVS"
fi
echo ""


# Example 2: Validate contract for HPCR-RHVS
echo "=== Example 2: Validate contract for HPCR-RHVS ==="
if "$CLI" validate-contract \
  --in "$VALID_CONTRACT" \
  --os hpcr-rhvs; then
    echo "Contract is valid for HPCR-RHVS platform"
else
    echo "Contract validation failed for HPCR-RHVS"
fi
echo ""


# Example 3: Validate contract for HPCC-PeerPod
echo "=== Example 3: Validate contract for HPCC-PeerPod ==="
if "$CLI" validate-contract \
  --in "$VALID_CONTRACT" \
  --os hpcc-peerpod; then
    echo "Contract is valid for HPCC-PeerPod platform"
else
    echo "Contract validation failed for HPCC-PeerPod"
fi
echo ""


# Example 4: Validate without specifying OS (uses default)
echo "=== Example 4: Validate with default OS ==="
if "$CLI" validate-contract \
  --in "$VALID_CONTRACT"; then
    echo "Contract is valid (default platform)"
else
    echo "Contract validation failed"
fi
echo ""


# Example 5: Validate using stdin (pipe)
echo "=== Example 5: Validate using stdin (pipe) ==="
if cat "$VALID_CONTRACT" | "$CLI" validate-contract \
  --in - \
  --os hpvs; then
    echo "Contract is valid for HPVS platform (stdin input)"
else
    echo "Contract validation failed"
fi
echo ""


# Example 6: Demonstrate validation failure (if invalid contract exists)
if [ -f "$INVALID_CONTRACT" ]; then
    echo "=== Example 5: Validate invalid contract (expected to fail) ==="
    if "$CLI" validate-contract \
      --in "$INVALID_CONTRACT" \
      --os hpvs 2>&1; then
        echo "Contract is valid"
    else
        echo "Contract validation failed (as expected for invalid contract)"
        echo "   This demonstrates how validation catches errors before encryption"
    fi
    echo ""
fi
echo "Script completed!"

