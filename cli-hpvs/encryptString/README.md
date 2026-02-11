# Encrypt String Script

This script encrypts sensitive strings (passwords, API keys, credentials) in Hyper Protect format using `contract-cli`. The encrypted strings can be safely included in contracts and will only be decrypted within the secure Hyper Protect environment.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## What is String Encryption?

String encryption in Hyper Protect format:
- Encrypts sensitive data like passwords, API keys, and credentials
- Uses the platform's encryption certificate
- Produces output in format: `hyper-protect-basic.<encrypted-password>.<encrypted-string>`
- Ensures data is only decrypted within the Hyper Protect secure environment
- Supports both plain text and JSON format inputs

## Usage

### 1. Configure the CLI path
Open the `encryptString.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Obtain Encryption Certificate

Download the encryption certificate for your target HPCR version using one of these methods:

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

Update the certificate path in the script:
```bash
ENCRYPTION_CERT="./encryption.crt"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x encryptString.sh
./encryptString.sh
```

## What the Script Does

The script demonstrates four usage examples:

### Example 1: Encrypt Plain Text String
- Encrypts a simple password or secret
- Saves to a file

### Example 2: Encrypt JSON String
- Encrypts structured JSON data
- Useful for complex credentials with multiple fields
- Maintains JSON structure after decryption

### Example 3: Encrypt with Specific OS Version
- Targets a specific Hyper Protect platform (hpvs, hpcr-rhvs, hpcc-peerpod)
- Ensures compatibility with the target environment

### Example 4: Output to Stdout
- Generates encrypted string and prints to terminal

## Command Options

The `encrypt-string` command supports the following flags:

### Required Flags
- `--in`: String data to encrypt (text or JSON)

### Optional Flags
- `--format`: Input data format - `text` (default) or `json`
- `--cert`: Path to encryption certificate file
- `--os`: Target Hyper Protect platform (hpvs, hpcr-rhvs, or hpcc-peerpod)
- `--out`: Path to save encrypted output (prints to stdout if not specified)

## Examples

### Encrypt plain text password:
```bash
./contract-cli encrypt-string \
  --in "MySecretPassword123!" \
  --format text \
  --cert encryption.crt \
  --out encrypted_password.txt
```

### Encrypt JSON credentials:
```bash
./contract-cli encrypt-string \
  --in '{"username":"admin","password":"secret"}' \
  --format json \
  --cert encryption.crt \
  --out encrypted_creds.txt
```

### Encrypt with specific OS version:
```bash
./contract-cli encrypt-string \
  --in "DatabasePassword456" \
  --format text \
  --os hpvs \
  --cert encryption.crt \
  --out encrypted_db_pass.txt
```

### Output to stdout:
```bash
./contract-cli encrypt-string \
  --in "api-key-xyz789" \
  --format text \
  --cert encryption.crt
```

## Troubleshooting

### Error: "Encryption certificate not found"
- Download the certificate using `download-certificate` command
- Or use `get-certificate` to extract from downloaded certificates
- Ensure the certificate version matches your target HPCR version

### Error: "Invalid input format"
- Verify you're using either `text` or `json` for the `--format` flag
- For JSON input, ensure proper JSON syntax with escaped quotes if needed

### Encryption Fails
- Check that the encryption certificate is valid and not corrupted
- Verify the certificate matches your target platform version
- Ensure input data doesn't contain special characters that need escaping

### Decryption Issues in Contract
- Verify you're using the complete encrypted string including the prefix
- Ensure the HPCR version matches the certificate version used for encryption
- Check that the encrypted string wasn't truncated or modified