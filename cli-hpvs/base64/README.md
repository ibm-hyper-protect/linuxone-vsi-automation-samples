# Base64 Encoding Script

This script encodes **text** and **JSON** inputs into Base64 using `contract-cli`.
Encode text or JSON data to Base64 format. Useful for encoding data that needs to be included in contracts or configurations.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `base64.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI_PATH=./contract-cli
```

### 2. Run the Script
Make the script executable and run it:

```bash
chmod +x base64.sh
./base64.sh
```

### What the Script Does
- Encodes a plain text string into Base64
- Encodes a JSON object into Base64
- Stores the encoded output in shell variables
- Prints the encoded values to standard output
