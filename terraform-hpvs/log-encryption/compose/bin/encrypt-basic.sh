#!/bin/bash
#
# Usage:
#   se-encrypt-basic.sh <pub-key-file>

usage() {
    echo "Usage: $(basename "$0") <pub-key-file>"
    exit 1
}

# read clear-text from STDIN
test  "$#" -eq 1 || usage
key_file="$1"
cleartext_file="$(mktemp)"
trap 'rm "$cleartext_file"' EXIT
cat > "$cleartext_file"

set -eu -o pipefail

# create random password 32 Byte
password="$(openssl rand 32 | base64 -w0)"

# encrypt password with public rsa key
password_enc="$(
    echo -n "$password" | base64 -d | openssl rsautl \
    -encrypt \
    -inkey "$key_file" \
    -pubin \
    | base64 -w0)"

# encrypt cleartext-file with random password
cleartext_enc="$(
    echo -n "$password" | base64 -d | openssl enc \
    -aes-256-cbc \
    -pbkdf2 \
    -pass stdin \
    -in  "$cleartext_file" \
    | base64 -w0)"

echo "hyper-protect-basic.${password_enc}.${cleartext_enc}"
