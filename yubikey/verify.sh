#!/bin/bash
sha256sum /myshare/$1 > test.txt
awk '{print $1}' test.txt > digest.txt
xxd -r -p digest.txt digest.bin
pkcs11-tool --verify --id 02 --input-file digest.bin --signature-file /myshare/data.sig --pin 81728172
