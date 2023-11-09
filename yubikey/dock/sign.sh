#!/bin/bash

# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

# Stop on any error
set -e

# Remove carriage returns
HASH="${1//$'\r'/}"
# Remove new lines
HASH="${HASH//$'\n'/}"

# Check for valid input as xxd -r will silently ignore errors
if [[ ! $HASH =~ ^[0-9A-Fa-f]{64}$ ]]; then
    echo "Invalid hash given" >&2
    exit 1
fi

xxd -r -p <<< "$HASH" > digest.bin

pkcs11-tool --module /usr/lib/x86_64-linux-gnu/libykcs11.so --sign --signature-format openssl -m ECDSA-SHA256 --id 02 -i digest.bin --output-file data.sig --pin 81728172 >/dev/null
SIGN="$(base64 --wrap=0 data.sig)"
# Remove carriage returns (just in case)
SIGN="${SIGN//$'\r'/}"
# Remove new lines (just in case)
SIGN="${SIGN//$'\n'/}"

printf "%s\n" "$SIGN"
