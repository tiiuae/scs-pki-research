#!/bin/bash

# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

# Stop on any error
set -e

# Remove carriage returns
HASH="${1//$'\r'/}"
SIGN="${2//$'\r'/}"

# Remove new lines
HASH="${HASH//$'\n'/}"
SIGN="${SIGN//$'\n'/}"

# Check for valid input as xxd -r will silently ignore errors
if [[ ! $HASH =~ ^[0-9A-Fa-f]{64}$ ]]; then
    echo "Invalid hash given" >&2
    exit 1
fi

xxd -r -p <<< "$HASH" > digest.bin
base64 --decode <<< "$SIGN" > signature.bin

RESULT="$(pkcs11-tool --verify --signature-format openssl -m ECDSA-SHA256 --id 02 --input-file digest.bin --signature-file signature.bin --pin 81728172)"

if [[ $RESULT =~ .*Signature\ is\ valid.* ]]; then
    echo "Signature is valid"
    exit 0
fi

if [[  $RESULT =~ .*Invalid\ signature.* ]]; then
    echo "Invalid signature"
    exit 10
fi

echo "Something went wrong with pkcs11-tool" >&2
exit 1
