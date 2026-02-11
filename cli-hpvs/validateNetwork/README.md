# Validate Network Script

This script validates network-config YAML files against the schema for on-premise deployments using `contract-cli`. Validation ensures all required fields are present and properly formatted before deployment, helping catch configuration errors early.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `validateNetwork.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Prepare Network Configuration File

Create a network-config YAML file defining your network configuration for on-premise deployments. Example `network-config.yaml`:

```yaml
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
```

Update the network config file path in the script:
```bash
NETWORK_CONFIG="network-config.yaml"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x validateNetwork.sh
./validateNetwork.sh
```

## What the Script Does

The script demonstrates three validation examples:

### Example 1: Validate Network Configuration
- Validates network-config YAML file against the schema
- Ensures all required fields are present
- Verifies field formats are correct

## Command Options

The `validate-network` command supports the following flags:

### Required Flags
- `--in`: Path to network-config YAML file

### Optional Flags
- `-h, --help`: Display help information

## Examples

### Validate network configuration:
```bash
./contract-cli validate-network \
  --in network-config.yaml
```

## Troubleshooting

### Error: "Network config file not found"
- Verify the network-config YAML file exists
- Check the file path in the script or command
- Ensure you have read permissions for the file

### Error: "Invalid network configuration structure"
- Review the network configuration schema
- Check for missing required fields
- Verify field names are spelled correctly
- Ensure proper YAML indentation