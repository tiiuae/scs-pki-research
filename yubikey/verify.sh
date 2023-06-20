#!/bin/bash
echo "$2"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode > signature.bin
echo "-------------"
echo Hash:
echo $1 > digest.hex
cat digest.hex

xxd -r -p digest.hex digest.bin
pkcs11-tool --verify --id 02 --input-file digest.bin --signature-file signature.bin --pin 81728172
