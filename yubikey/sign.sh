#!/bin/bash
sha256sum /myshare/$1 > test.txt
awk '{print $1}' test.txt > digest.txt
xxd -r -p digest.txt digest.bin
pkcs11-tool --verbose --sign --id 02 -i digest.bin --output-file /myshare/data.sig --pin 81728172
