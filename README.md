<!--
    Copyright 2023 TII (SSRC) and the Ghaf contributors
    SPDX-License-Identifier: CC-BY-SA-4.0
-->


# Provisioning Yubikey


Start bash on the container (makes life easier)

`$ ./start.sh --bash

YubiKey found on a USB Bus: 003, Device: 008`

Check if the Yubikey is operational (there might be issues with pcscd service, in which case it will not work. See troubleshooting section)

`root@dd59f95cbd4e:/app# ykman list

YubiKey 5 NFC (5.4.3) [OTP+FIDO+CCID] Serial: 23646903

root@dd59f95cbd4e:/app# ykman list --serials

23646903`

Reset the PIV:

`root@dd59f95cbd4e:/app# ykman piv reset

WARNING! This will delete all stored PIV data and restore factory settings. Proceed? [y/N]: y

Resetting PIV data...

Success! All PIV data have been cleared from the YubiKey.

Your YubiKey now has the default PIN, PUK and Management Key:
	PIN:	123456
	PUK:	12345678
	Management Key:	010203040506070801020304050607080102030405060708`

Set the PIN:

`root@dd59f95cbd4e:/app# ykman piv access change-pin

Enter the current PIN: 

Enter the new PIN: 

Repeat for confirmation: 

New PIN set.`

Set the management key

`root@dd59f95cbd4e:/app# ykman piv access change-management-key

Enter the current management key [blank to use default key]:

Enter the new management key:

Repeat for confirmation:`


Generate the keypair and the cert for signing (remember to update the pin, corresponding to the pin set in previous steps)

`ykman piv keys generate --pin 123456 -a ECCP256 -F PEM 0x9C pubkey.pem`

`ykman piv certificates generate -P 123456 -s Ghaf -d 365 -a SHA256 0x9c pubkey.pem`

The pubkey.pem is the public key for the verefication part (also present on the Yubikey now).


# Example signing


Generate SHA256 hash:

`$ sha256sum 0r434a8n04i14s4sp3fam23cplwyn1iw-generic-x86_64-debug-nixos.img 

1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a  0r434a8n04i14s4sp3fam23cplwyn1iw-generic-x86_64-debug-nixos.img`

Sign the hash with the Yubikey:

`$ ./start.sh --sign --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a

YubiKey found on a USB Bus: 003, Device: 002

499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==`

Verify the signature (Valid case):

Note that output might differ. The main part is "Signature is valid" or "Invalid signature" line.


`alex@alex-unikie:~/repos/scs-pki-research/yubikey$ ./start.sh --verify --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a --sg=499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==

YubiKey found on USB Bus: 003, Device: 002

-------------

Hash:
1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a
Using slot 0 with a present token (0x0)
Using signature algorithm ECDSA
Signature is valid`


Verify the signature (Invalid case):


`$ ./start.sh --verify --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337b --sg=499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==

YubiKey found on USB Bus: 003, Device: 002

-------------

Hash:

1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337b

Using slot 0 with a present token (0x0)
Using signature algorithm ECDSA
Invalid signature`


# Troubleshooting

- Yubikey is not cooperating:

  - check if pcscd service is running and restart if needed:

`$ ./start.sh --bash

YubiKey found on a USB Bus: 003, Device: 008

root@0b45d93be2f5:/app# service pcscd status

* pcscd is not running

root@0b45d93be2f5:/app# service pcscd restart

* Restarting PCSC Lite resource manager pcscd`