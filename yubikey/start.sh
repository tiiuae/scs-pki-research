#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

# Allow override of the container name for testing purposes
CONTAINER="${CONTAINER:-yubi}"

function Show_help {
    echo ""
    echo "Usage: $0 CMD [OPT...]"
    echo ""
    echo "  CMD = Command"
    echo "  OPT = Option"
    echo ""
    echo "Commands:"
    echo "          sign = Sign the binary using the hash"
    echo "        verify = Verify the signature"
    echo "          bash = Open bash shell into container"
    echo "   --help|help = Show this help"
    echo "  check-script = Check script itself with shellcheck and bashate"
    echo ""
    echo "Options:"
    echo "  -h=HASH|--hash=HASH = Set the hash for signing or verification"
    echo "  -s=SIGN|--sign=SIGN = Set the signature for verification"
    echo ""
    echo "Examples:"
    echo ""
    echo "  $0 sign -h=35b5d3b9746967f4c1984f90d9ccccda6862abd8dc2546a9b8c663c610696617 > signature.b64"
    echo "  $0 verify -h=35b5d3b9746967f4c1984f90d9ccccda6862abd8dc2546a9b8c663c610696617 \"-s=\$(<signature.b64)\""
    echo ""
}

case "$1" in
sign|verify|bash)
    CMD="$1"
;;
check-script)
    # Just to check for errors on development environment that has shellcheck and bashate installed
    if shellcheck --help > /dev/null 2>&1 && bashate --help > /dev/null 2>&1; then
        if shellcheck "$0" && bashate -i E006 "$0"; then
            echo "Nothing to complain"
            exit 0
        fi
    else
        echo "Please install shellcheck and bashate to use check-script functionality"
    fi
    exit 1
;;
--help|help)
    Show_help
    exit 0
;;
*)
    if [ -z "$1" ]; then
        echo "No command given!" >&2
    else
        echo "Invalid command: $1" >&2
    fi
    Show_help >&2
    exit 1
;;
esac

shift

while [ -n "$1" ]; do
    case "$1" in
    --hash=*)
        HASH="${1##--hash=}"
    ;;
    -h=*)
        HASH="${1##-h=}"
    ;;
    --sign=*)
        SIGN="${1##--sign=}"
    ;;
    -s=*)
        SIGN="${1##-s=}"
    ;;
    *)
        echo "Unknown option: $1"
        exit 1
    ;;
    esac
    shift
done


# Find the USB bus and device numbers for YubiKey
yubikey_info=$(lsusb -d 1050: | awk '{print $2, $4}' | sed 's/://')

if [[ -n "$yubikey_info" ]]; then
    # Extract the USB bus and device numbers
    usb_bus=$(echo "$yubikey_info" | cut -d ' ' -f 1)
    usb_device=$(echo "$yubikey_info" | cut -d ' ' -f 2)

    echo "YubiKey found on a USB Bus: ${usb_bus}, Device: $usb_device" >&2

    case "$CMD" in
    sign)
        if [ -z "$HASH" ]; then
            echo "No hash given!" >&2
            exit 1
        fi
        docker run --rm "--device=/dev/bus/usb/${usb_bus}/${usb_device}" "$CONTAINER" ./sign.sh "$HASH"
        exit
    ;;
    verify)
        if [ -z "$HASH" ] || [ -z "$SIGN" ]; then
            echo "No hash or signature given!" >&2
            exit 1
        fi
        docker run --rm --device="/dev/bus/usb/${usb_bus}/${usb_device}" "$CONTAINER" ./verify.sh "$HASH" "$SIGN"
        exit
    ;;
    bash)
        docker run --rm --device="/dev/bus/usb/${usb_bus}/${usb_device}" -it "$CONTAINER" /bin/bash
        exit
    ;;
    esac
else
    echo "YubiKey not found" >&2
fi
