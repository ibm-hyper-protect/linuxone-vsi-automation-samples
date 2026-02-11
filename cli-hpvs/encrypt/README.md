# Encrypt Contract Script

This script generates signed and encrypted contracts for Hyper Protect Virtual Server deployment using `contract-cli`. The encrypted contract ensures that only authorized Hyper Protect instances can decrypt and execute your workload.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `encrypt.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Prepare Required Files

You need three essential files:

#### a. Contract YAML File
Create a contract file defining your workload configuration. Example `contract.yaml`:

```yaml
env:
  type: env
  logging:
    logRouter:
      hostname: f61xxxxxx.....ingress.us-south.logs.cloud.ibm.com
      iamApiKey: <your api key>
      port: 443
workload:
  type: workload
  compose:
    archive: <base64-encoded-tar.gz>
```

#### b. Encryption Certificate
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

#### c. Private Key
Generate a private key for signing (if you don't have one):

```bash
openssl genrsa -out private.key 4096
```

Extract the public key (needed for instance creation):

```bash
openssl rsa -in private.key -pubout -out public.key
```

Update the file paths in the script:
```bash
CONTRACT_FILE="./contract.yaml"
ENCRYPTION_CERT="./encryption.crt"
PRIVATE_KEY="./private.key"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x encrypt.sh
./encrypt.sh
```

## What the Script Does

The script demonstrates four usage examples:

### Example 1: Basic Signed and Encrypted Contract
- Signs the contract with your private key
- Encrypts with the platform certificate
- Saves to a file

### Example 2: With Specific OS Version
- Targets a specific Hyper Protect platform (hpvs, hpcr-rhvs, hpcc-peerpod)
- Ensures compatibility with the target environment

### Example 3: Output to Stdout
- Generates encrypted contract and prints to terminal
- Useful for piping to other commands or immediate inspection

### Example 4: Contract with Expiry (Advanced)
- Adds time-based expiry to contracts
- Requires additional CA certificate and key files
- Enhances security by limiting contract validity period

## Command Options

The `encrypt` command supports the following flags:

### Required Flags
- `--in`: Path to unencrypted contract YAML file

### Optional Flags
- `--cert`: Path to encryption certificate file
- `--priv`: Path to private key file for signing
- `--os`: Target Hyper Protect platform (hpvs, hpcr-rhvs, or hpcc-peerpod)
- `--out`: Path to save signed and encrypted contract (prints to stdout if not specified)

### Contract Expiry Flags (Advanced)
- `--contract-expiry`: Enable contract expiry feature
- `--cacert`: Path to CA certificate file
- `--cakey`: Path to CA private key file
- `--csrParam`: Path to CSR parameters JSON file
- `--csr`: Path to Certificate Signing Request (CSR) file
- `--expiry`: Contract validity period in days

## Examples

### Basic encryption:
```bash
./contract-cli encrypt \
  --in contract.yaml \
  --cert encryption.crt \
  --priv private.key \
  --out encrypted_contract.txt
```

### With specific OS version:
```bash
./contract-cli encrypt \
  --in contract.yaml \
  --os hpvs \
  --cert encryption.crt \
  --priv private.key \
  --out encrypted_contract.txt
```

### Output to stdout:
```bash
./contract-cli encrypt \
  --in contract.yaml \
  --cert encryption.crt \
  --priv private.key
```

### With contract expiry (90 days):
```bash
./contract-cli encrypt \
  --in contract.yaml \
  --cert encryption.crt \
  --priv private.key \
  --contract-expiry \
  --cacert ca.crt \
  --cakey ca.key \
  --csrParam csr_params.json \
  --csr csr.pem \
  --expiry 90 \
  --out encrypted_contract_expiry.txt
```

## Troubleshooting

### Error: "Contract file not found"
- Verify the contract YAML file exists
- Check the file path in the script

### Error: "Encryption certificate not found"
- Download the certificate using `download-certificate` command
- Or use `get-certificate` to extract from downloaded certificates
- Ensure the certificate version matches your target HPCR version

### Error: "Private key not found"
- Generate a new key pair using OpenSSL
- Ensure the private key is in PEM format

### Encryption Fails
- Verify the contract YAML is valid
- Check that the encryption certificate matches the target platform
- Ensure the private key is not password-protected (or provide password)

### Contract Deployment Fails
- Verify the encrypted contract was generated successfully
- Ensure the public key used during instance creation matches your private key
- Check that the HPCR version matches the certificate version