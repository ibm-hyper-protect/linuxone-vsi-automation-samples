# Validate Contract Script

This script validates unencrypted Hyper Protect contracts against the schema for different platforms using `contract-cli`. Validation helps catch errors before encryption and deployment, ensuring your contract structure is correct and compatible with the target platform.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `validateContract.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Prepare Contract File

Create a contract YAML file defining your workload configuration. Example `contract.yaml`:

```yaml
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
```

Update the contract file path in the script:
```bash
VALID_CONTRACT="contract.yaml"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x validateContract.sh
./validateContract.sh
```

## What the Script Does

The script demonstrates five validation examples:

### Example 1: Validate Contract for HPVS
- Validates contract against HPVS platform schema
- Ensures compatibility with Hyper Protect Virtual Server

### Example 2: Validate Contract for HPCR-RHVS
- Validates contract against HPCR-RHVS platform schema
- Ensures compatibility with Hyper Protect Container Runtime on Red Hat Virtualization

### Example 3: Validate Contract for HPCC-PeerPod
- Validates contract against HPCC-PeerPod platform schema
- Ensures compatibility with Hyper Protect Confidential Containers PeerPod

### Example 4: Validate with Default OS
- Validates using default platform settings
- Useful for general validation without specifying target platform

### Example 5: Demonstrate Validation Failure
- Shows how validation catches errors in invalid contracts
- Demonstrates error messages and debugging information

## Command Options

The `validate-contract` command supports the following flags:

### Required Flags
- `--in`: Path to unencrypted contract YAML file

### Optional Flags
- `--os`: Target Hyper Protect platform (hpvs, hpcr-rhvs, or hpcc-peerpod)

## Examples

### Validate for HPVS:
```bash
./contract-cli validate-contract \
  --in contract.yaml \
  --os hpvs
```

### Validate for HPCR-RHVS:
```bash
./contract-cli validate-contract \
  --in contract.yaml \
  --os hpcr-rhvs
```

### Validate for HPCC-PeerPod:
```bash
./contract-cli validate-contract \
  --in contract.yaml \
  --os hpcc-peerpod
```

### Validate with default platform:
```bash
./contract-cli validate-contract \
  --in contract.yaml
```

## Common Validation Errors

### Missing Required Fields
```text
Error: Missing required field 'type' in env section
```
**Solution**: Add all required fields to your contract

### Invalid Field Values
```text
Error: Invalid value for 'filesystem' field
```
**Solution**: Check allowed values for the field in platform documentation

### Incorrect YAML Syntax
```text
Error: YAML parsing error at line 15
```
**Solution**: Verify YAML indentation and syntax

## Troubleshooting

### Error: "Contract file not found"
- Verify the contract YAML file exists
- Check the file path in the script or command
- Ensure you have read permissions for the file

### Error: "Invalid contract structure"
- Review the contract schema for your target platform
- Check for missing required fields
- Verify field names are spelled correctly
- Ensure proper YAML indentation