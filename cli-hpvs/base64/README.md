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

## Command Options

The `base64` command supports the following flags:

### Required Flags
- `--in`: String data to encode (text or JSON)

### Optional Flags
- `--format`: Input data format - `text` (default) or `json`
- `--out`: Path to save encoded output (prints to stdout if not specified)

## Examples

### Encode plain text:
```bash
./contract-cli base64 \
  --in "Hello World" \
  --format text
```

### Encode JSON:
```bash
./contract-cli base64 \
  --in '{"key":"value"}' \
  --format json \
  --out encoded.txt
```

## Troubleshooting

### Error: "Invalid input format"
- Verify you're using either `text` or `json` for the `--format` flag
- For JSON input, ensure proper JSON syntax

### Encoding Fails
- Check that input data doesn't contain special characters that need escaping
- Verify the input string is properly quoted
- Prints the encoded values to standard output

## Related Commands

- `base64-tgz`: Create Base64-encoded tar.gz archives
- `encrypt-string`: Encrypt and encode sensitive strings
- `encrypt`: Encrypt complete contract files
