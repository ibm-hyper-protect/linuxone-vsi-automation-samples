# Validate Encryption Certificate Script

This script validates Hyper Protect encryption certificates using `contract-cli` to ensure they are valid and not expired. Validating certificates before using them for encryption operations helps prevent deployment failures due to expired or invalid certificates.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `validateEncryptionCertificate.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Obtain Encryption Certificate

Download an encryption certificate for validation using one of these methods:

**Method 1: Direct download**
```bash
./contract-cli download-certificate --version 1.0.23 --format json --out encryption.crt
```

**Method 2: Download and extract**
```bash
# Download multiple versions
./contract-cli download-certificate --version 1.0.23,1.0.24 --format json --out certs.json

# Extract specific version
./contract-cli get-certificate --in certs.json --version 1.0.23 --out encryption.crt
```

Update the certificate file path in the script:
```bash
CERT_FILE="encryption.crt"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x validateEncryptionCertificate.sh
./validateEncryptionCertificate.sh
```

## What the Script Does

The script demonstrates four validation examples:

### Example 1: Validate Encryption Certificate
- Validates a single encryption certificate
- Checks certificate validity and expiration status
- Reports validation results

### Example 2: Validate Certificate from Different Location
- Demonstrates validating certificates from different directories
- Useful for managing multiple certificate versions

### Example 3: Complete Validation Workflow
- Downloads a certificate
- Validates the downloaded certificate
- Demonstrates end-to-end workflow
- Cleans up temporary files

## Command Options

The `validate-encryption-certificate` command supports the following flags:

### Required Flags
- `--in`: Path to encryption certificate file to validate

## Examples

### Validate single certificate:
```bash
./contract-cli validate-encryption-certificate \
  --in encryption.crt
```

### Validate certificate from specific location:
```bash
./contract-cli validate-encryption-certificate \
  --in /path/to/certs/encryption_1.0.24.crt
```

### Validate as part of workflow:
```bash
# Download certificate
./contract-cli download-certificate \
  --version 1.0.23 \
  --format json \
  --out encryption.crt

# Validate certificate
./contract-cli validate-encryption-certificate \
  --in encryption.crt

# If valid, use for encryption
./contract-cli encrypt \
  --in contract.yaml \
  --cert encryption.crt \
  --out encrypted_contract.txt
```

## Troubleshooting

### Error: "Certificate file not found"
- Verify the certificate file exists at the specified path
- Download the certificate using `download-certificate` command

### Error: "Certificate is expired"
- Download a newer certificate version
- Check the latest available HPCR versions

### Validation Succeeds but Encryption Fails
- Verify the certificate version matches your target HPCR version
- Check that you're using the correct certificate for the platform
- Ensure the certificate file is accessible during encryption

## Related Commands

- `download-certificate`: Download encryption certificates from IBM repository
- `get-certificate`: Extract specific certificate versions
- `encrypt`: Encrypt contracts using validated certificates
- `encrypt-string`: Encrypt strings using validated certificates
