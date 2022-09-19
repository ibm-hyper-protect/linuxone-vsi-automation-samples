#!/bin/bash

key_file=$1

TMPDIR=$(mktemp -d)

data_file=${TMPDIR}/data
cat > "$data_file"

password_enc=${TMPDIR}/password_enc
ciphertext_enc=${TMPDIR}/ciphertext_enc

cut -d. -f 2 "$data_file" | base64 -d > "$password_enc"
cut -d. -f 3 "$data_file" | base64 -d > "$ciphertext_enc"

openssl rsautl -decrypt -inkey "${key_file}" -in $password_enc | openssl aes-256-cbc -d -pbkdf2 -in $ciphertext_enc -pass stdin

rm -rf "$TMPDIR"