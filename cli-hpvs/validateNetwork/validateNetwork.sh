#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Sample network configuration file
NETWORK_CONFIG="network-config.yaml"

echo "=== Validate Network Configuration ==="
echo ""
echo "This script validates network-config YAML files against the schema for"
echo "on-premise deployments. Validation ensures all required fields are present"
echo "and properly formatted before deployment."
echo ""

# Check if network config file exists
if [ ! -f "$NETWORK_CONFIG" ]; then
    echo "WARNING: Sample network config file not found: $NETWORK_CONFIG"
    echo ""
    echo "Create a sample network-config.yaml file first. Example structure:"
    echo ""
    cat << 'EOF'
network:
 version: 2
 ethernets:
  enc1:
    dhcp4: false
    addresses:
     - x.x.x.x/x
    gateway4: x.x.x.x
    nameservers:
     addresses:
      - 8.8.8.8
EOF
    echo ""
    echo "Save this as $NETWORK_CONFIG and run the script again."
    exit 1
fi

# Example 1: Validate network configuration
echo "=== Example 1: Validate network configuration ==="
if "$CLI" validate-network \
  --in "$NETWORK_CONFIG"; then
    echo "Network configuration is valid"
else
    echo "Network configuration validation failed"
fi
echo ""


# Example 2: Validate using stdin (pipe)
echo "=== Example 2: Validate using stdin (pipe) ==="
if cat "$NETWORK_CONFIG" | "$CLI" validate-network \
  --in -; then
    echo "Network configuration is valid (stdin input)"
else
    echo "Network configuration validation failed"
fi
echo ""

echo "Script completed!"
