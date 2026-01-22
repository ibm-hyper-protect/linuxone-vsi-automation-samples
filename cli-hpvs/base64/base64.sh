#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Text input
textInput="Encode my message on base64"

# Output file
TEXT_OUTPUT_FILE="text_base64_output.txt"

# Encode text input to Base64 and write to file
"$CLI" base64 \
  --in "$textInput" \
  --format text \
  --out "$TEXT_OUTPUT_FILE"

echo "Text Base64 Output:"
cat "$TEXT_OUTPUT_FILE"



# JSON input
jsonInput='{"type": "workload"}'

# Output file
JSON_OUTPUT_FILE="json_base64_output.txt"

# Encode JSON input to Base64 and write to file
"$CLI" base64 \
  --in "$jsonInput" \
  --format json \
  --out "$JSON_OUTPUT_FILE"

echo "JSON Base64 Output:"
cat "$JSON_OUTPUT_FILE"
