# Base64 Tar.gz Encoding Script

This script creates Base64-encoded tar.gz archives of container configurations using `contract-cli`. It compresses and encodes docker-compose.yaml or pods.yaml files for inclusion in Hyper Protect contracts.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `base64Tgz.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Prepare your container configuration
Create a folder containing your `docker-compose.yaml` or `pods.yaml` file. Update the `COMPOSE_FOLDER` variable in the script to point to this folder.

Example:
```text
COMPOSE_FOLDER=./compose
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x base64Tgz.sh
./base64Tgz.sh
```

## What the Script Does

The script demonstrates three usage examples:

### Example 1: Plain Base64 tar.gz
- Creates a compressed tar.gz archive of your container configuration
- Encodes it as Base64
- Saves the output to a file (`plain_base64tgz_output.txt`)

### Example 2: Encrypted Base64 tar.gz (commented out by default)
- Creates an encrypted Base64 tar.gz archive
- Requires an encryption certificate
- Supports different Hyper Protect platforms (hpvs, hpcr-rhvs, hpcc-peerpod)
- Uncomment the lines in the script when you have a valid certificate

### Example 3: Output to stdout
- Generates Base64 tar.gz and prints directly to the terminal
- Useful for piping to other commands or viewing the output immediately

## Command Options

The `base64-tgz` command supports the following flags:

- `--in`: (Required) Path to folder containing docker-compose.yaml or pods.yaml
- `--output`: Output format - `plain` (default) or `encrypt`
- `--out`: Path to save the Base64 tar.gz output (optional, prints to stdout if not specified)
- `--os`: Target Hyper Protect platform (hpvs, hpcr-rhvs, or hpcc-peerpod) - required for encrypted output
- `--cert`: Path to encryption certificate file - required for encrypted output

## Examples

### Plain encoding:
```bash
./contract-cli base64-tgz --in ./compose --output plain --out output.txt
```

### Encrypted encoding:
```bash
./contract-cli base64-tgz --in ./compose --output encrypt --os hpvs --cert ./encryption.crt --out encrypted_output.txt
```

### Output to stdout:
```bash
./contract-cli base64-tgz --in ./compose --output plain
```

## Notes

- The input folder must contain either a `docker-compose.yaml` or `pods.yaml` file
- For encrypted output, you need a valid encryption certificate from your Hyper Protect environment
- The generated Base64 string can be used directly in Hyper Protect contracts

## Troubleshooting

### Error: "Input folder not found"
- Verify the folder path is correct
- Ensure the folder exists and is accessible

### Error: "No docker-compose.yaml or pods.yaml found"
- Check that your folder contains one of these files
- Verify the file name matches exactly (case-sensitive)

### Error: "Encryption certificate not found"
- Download the certificate using `download-certificate` command
- Ensure the certificate path is correct

### Encrypted Output Fails
- Verify you have a valid encryption certificate
- Check that the certificate matches your target platform
- Ensure the `--os` flag is specified for encrypted output
- The tar.gz compression reduces the size of the configuration before encoding

## Related Commands

- `base64`: Encode text and JSON to Base64
- `encrypt`: Encrypt complete contract files
- `download-certificate`: Download encryption certificates
- `validate-contract`: Validate contracts before deployment
