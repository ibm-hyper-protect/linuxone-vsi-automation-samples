# Download Encryption Certificates Script

This script downloads encryption certificates from the IBM Hyper Protect Repository using `contract-cli`. These certificates are essential for encrypting contracts and securing workload configurations in Hyper Protect environments.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `downloadCertificate.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Run the Script
Make the script executable and run it:

```bash
chmod +x downloadCertificate.sh
./downloadCertificate.sh
```

## What the Script Does

The script demonstrates five usage examples:

### Example 1: Download Specific Versions (JSON format)
- Downloads multiple certificate versions (e.g., 1.0.23, 1.0.24)
- Saves output in JSON format
- Useful for storing multiple versions for different environments

### Example 2: Download Specific Versions (YAML format)
- Downloads certificates in YAML format
- Alternative format for integration with YAML-based workflows

### Example 3: Output to Stdout
- Downloads and prints certificates directly to terminal
- Useful for piping to other commands or immediate inspection

### Example 4: Download Latest Version
- Shows how to download the most recent certificate version
- Check IBM documentation for current version numbers

## Command Options

### download-certificate Command

- `--version`: (Required) Certificate versions to download (comma-separated, e.g., 1.0.23,1.0.24)
- `--format`: Output format - `json` (default), `yaml`, or `text`
- `--out`: (Optional) Path to save downloaded certificates (prints to stdout if not specified)

## Examples

### Download multiple versions in JSON:
```bash
./contract-cli download-certificate \
  --version 1.0.23,1.0.24 \
  --format json \
  --out certificates.json
```

### Download single version in YAML:
```bash
./contract-cli download-certificate \
  --version 1.0.24 \
  --format yaml \
  --out certificate.yaml
```

### Download and output to stdout:
```bash
./contract-cli download-certificate \
  --version 1.0.23 \
  --format json
```

## Troubleshooting

### Error: "required flag '--version' is missing"
- Ensure you specify at least one version number
- Use comma-separated values for multiple versions

### Invalid Version Number
- Verify the version number exists in IBM's repository
- Check IBM documentation for available versions
- Ensure correct format (e.g., 1.0.23, not v1.0.23)

## Related Commands

- `get-certificate`: Extract specific certificate versions from downloaded certificates
- `validate-encryption-certificate`: Validate downloaded certificates
- `encrypt`: Encrypt contracts using downloaded certificates
- `encrypt-string`: Encrypt sensitive strings using downloaded certificates