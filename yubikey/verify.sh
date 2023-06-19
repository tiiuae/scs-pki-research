#!/bin/bash
#sha256sum /myshare/$1 > test.txt
#awk '{print $1}' test.txt > digest.txt
# 1 - hash
# 2 - signature in b64 format

echo $1 > digest.txt
echo $2 > data.sig
cat data.sig
base64 -d data.sig > signature.bin

xxd -r -p digest.txt digest.bin
pkcs11-tool --verify --id 02 --input-file digest.bin --signature-file signature.bin --pin 81728172
