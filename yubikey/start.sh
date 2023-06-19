#!/bin/bash

#docker run -d --privileged --device=/dev/bus/usb/003/012 -p 2222:22 yubikey-ssh-pcscd


#docker run --privileged -v /var/run/pcscd:/var/run/pcscd -v /tmp/testfolder:/myshare --device=/dev/bus/usb/003/002 -it yubikey /bin/bash

# ssh root@localhost -p 2222
# pkcs11 --sign --id 02 --input-file input.bin --output-file data.sig --pin 81728172
# pkcs11 --verify --id 02 --input-file input.bin --signature-file data.sig


if [ -z "$1" ]; then
    echo "Usage: $0 [OPT...] CMD"
    echo ""
    echo "  OPT = Option"
    echo "  CMD = Command"
    echo ""
    echo "  Options:"
    echo "    --sign      = Sign the binary using the hash"
    echo "    --verify    = Verify the signature"
    echo "    --h=HSH     = Set the hash for signing or verification"
    echo "    --sg=SGN    = Set the signature for verification (b64 format)"
    echo ""
    echo "  Example:"
    echo ""
    echo "$0 --sign -h 35b5d3b9746967f4c1984f90d9ccccda6862abd8dc2546a9b8c663c610696617 > signature.b64"
    echo ""
    echo "$0 --verify --h 35b5d3b9746967f4c1984f90d9ccccda6862abd8dc2546a9b8c663c610696617 -sg signature.b64"
    exit 1
fi

while [[ $1 == --* ]]; do
    case "$1" in
    --sign)
	SIGN=1
    ;;

    --verify)
	VERIFY=1
    ;;
    --h=*)
	HASH="${1##--h=}"
	HASHGIVEN=1
    ;;
    --sg=*)
	SGN="${1##--sg=}"
	SGNGIVEN=1
    ;;
    --*)
        echo "Unknown option: $1"
        exit 1
    esac
    shift
done


# Find the USB bus and device numbers for YubiKey
yubikey_info=$(lsusb -d 1050: | awk '{print $2, $4}' | sed 's/://')

if [[ -n "$yubikey_info" ]]; then
  # Extract the USB bus and device numbers
  usb_bus=$(echo "$yubikey_info" | cut -d ' ' -f 1)
  usb_device=$(echo "$yubikey_info" | cut -d ' ' -f 2)

  #  echo "YubiKey found on USB Bus: $usb_bus, Device: $usb_device"
  if [ ! -z "$SIGN" ]; then
      if [ -n "$HASHGIVEN" ]; then
      	 echo "No hash given!"
	 exit 1
      fi
#      echo "SIGNING!"
      docker run --device=/dev/bus/usb/$usb_bus/$usb_device -it yubikey ./sign.sh $HASH
      exit $?
  fi

  if [ ! -z "$VERIFY" ]; then
      if [ -z "$HASHGIVEN" ] || [ -z "$SGNGIVEN" ]; then
	  "No hash or signature given!"
	  exit 1
      fi
#      echo "VERIFYING!"
      docker run --device=/dev/bus/usb/$usb_bus/$usb_device -it yubikey ./verify.sh $HASH `cat $SGN`
      exit $?
  fi

else
  echo "YubiKey not found"
fi
