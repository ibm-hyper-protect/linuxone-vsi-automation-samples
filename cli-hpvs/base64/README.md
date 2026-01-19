# Base64 Encoding Script

This script encodes **text** and **JSON** inputs into Base64 using `contract-cli`.
Encode text or JSON data to Base64 format. Useful for encoding data that needs to be included in contracts or configurations.

## Prerequisites

Prepare your environment according to [these steps](../README.md).

## Usage

### 1. Update CLI Path

Edit the script and replace the `CLI` variable with the downloaded CLI binary matching your operating system.

```bash
CLI=./contract-cli-darwin-*
```

## Example
```bash
CLI=./contract-cli-darwin-amd64
```

Ensure the binary is executable:
```bash
chmod +x contract-cli-*
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
