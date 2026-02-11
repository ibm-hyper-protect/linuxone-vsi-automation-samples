# Get Certificate Script

This script extracts specific encryption certificate versions from a previously downloaded certificates file using `contract-cli`. This is useful when you've downloaded multiple certificate versions and need to extract a specific one for encryption operations.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Typical Workflow

1. **Download certificates** (multiple versions):
   ```bash
   ./contract-cli download-certificate --version 1.0.23,1.0.24 --format json --out certificates.json
   ```

2. **Extract specific version** for use:
   ```bash
   ./contract-cli get-certificate --in certificates.json --version 1.0.23 --out encryption.crt
   ```

3. **Use extracted certificate** for encryption:
   ```bash
   ./contract-cli encrypt --in contract.yaml --cert encryption.crt --out encrypted_contract.yaml
   ```

## Usage

### 1. Configure the CLI path
Open the `getCertificate.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Prepare Certificates File

You need a certificates file containing multiple versions. Download one using:

```bash
./contract-cli download-certificate \
  --version 1.0.23,1.0.24 \
  --format json \
  --out certificates.json
```

Update the input file path in the script:
```bash
CERTIFICATES_JSON="certificates.json"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x getCertificate.sh
./getCertificate.sh
```

## What the Script Does

The script demonstrates four usage examples:

### Example 1: Extract Specific Version (1.0.23)
- Extracts certificate version 1.0.23 from the downloaded certificates
- Saves to a dedicated file

### Example 2: Extract Different Version (1.0.24)
- Extracts a different certificate version
- Demonstrates extracting multiple versions from the same source file

### Example 3: Output to Stdout
- Extracts and prints certificate directly to terminal
- Useful for piping to other commands or immediate inspection

### Example 4: Extract for Encryption Operations
- Extracts certificate specifically for use with encrypt commands
- Shows the complete workflow from extraction to usage

## Command Options

### get-certificate Command

#### Required Flags
- `--in`: Path to the certificates file (JSON or YAML format)
- `--version`: Specific certificate version to extract (e.g., 1.0.23)

#### Optional Flags
- `--out`: Path to save extracted certificate (prints to stdout if not specified)

## Examples

### Extract specific version to file:
```bash
./contract-cli get-certificate \
  --in certificates.json \
  --version 1.0.23 \
  --out encryption_cert.crt
```

### Extract from YAML file:
```bash
./contract-cli get-certificate \
  --in certificates.yaml \
  --version 1.0.24 \
  --out cert_1.0.24.crt
```

### Extract and output to stdout:
```bash
./contract-cli get-certificate \
  --in certificates.json \
  --version 1.0.23
```

### Use extracted certificate for encryption:
```bash
# Extract certificate
./contract-cli get-certificate \
  --in certificates.json \
  --version 1.0.24 \
  --out encryption.crt

# Use for contract encryption
./contract-cli encrypt \
  --in contract.yaml \
  --cert encryption.crt \
  --out encrypted_contract.yaml

# Use for string encryption
./contract-cli encrypt-string \
  --in "MySecretPassword" \
  --cert encryption.crt \
  --out encrypted_password.txt
```

## Use Cases
```bash
# Download all needed versions once
./contract-cli download-certificate --version 1.0.23,1.0.24 --format json --out all_certs.json
./contract-cli get-certificate --in all_certs.json --version 1.0.23 --out staging_cert.crt
```

## Troubleshooting

### Error: "Certificate version not found"
- Verify the version exists in the input certificates file
- Check the version number format (e.g., 1.0.23, not v1.0.23)
- List available versions by viewing the certificates file

### Error: "Invalid input file format"
- Ensure the input file is valid JSON or YAML
- Verify the file was created by `download-certificate` command
- Check file is not corrupted or truncated

### Error: "Input file not found"
- Download certificates first using `download-certificate` command
- Verify the path to the certificates file is correct
- Ensure you have read permissions for the file

### Extracted Certificate Doesn't Work
- Verify you extracted the correct version for your HPCR environment
- Check that the extraction completed without errors
- Ensure the output file is not empty or corrupted
- Confirm the certificate version matches your target platform version

## Related Commands

- **download-certificate**: Download certificates from IBM repository
- **encrypt**: Encrypt contracts using extracted certificates
- **encrypt-string**: Encrypt sensitive strings using extracted certificates