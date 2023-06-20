#!/bin/bash
#sha256sum /myshare/$1 > test.txt
#awk '{print $1}' test.txt > digest.txt

echo $1 > digest.txt
xxd -r -p digest.txt digest.bin

pkcs11-tool --sign --id 02 -i digest.bin --output-file data.sig --pin 81728172 2>1 > /dev/null
base64 --wrap=0 data.sig
echo ""
