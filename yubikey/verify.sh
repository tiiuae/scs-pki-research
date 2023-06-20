#!/bin/bash
#sha256sum /myshare/$1 > test.txt
#awk '{print $1}' test.txt > digest.txt
# 1 - hash
# 2 - signature in b64 format

#echo $0 > digest.txt
#cat - > signature.b64
#cat mysig.b64 > signature.b64
#base64 -d signature.b64
#echo "Signature:"
#sig=`cat signature.b64`
echo "$2"==== | fold -w 4 | sed '$ d' | tr -d '\n' | base64 --decode > signature.bin
echo "-------------"
#base64 -d signature.b64 
echo Hash:
echo $1 > digest.hex
cat digest.hex

xxd -r -p digest.hex digest.bin
pkcs11-tool --verify --id 02 --input-file digest.bin --signature-file signature.bin --pin 81728172
