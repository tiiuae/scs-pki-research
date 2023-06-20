# scs-pki-research
PKI research material

# Example signing:

Generate SHA256 hash

`$ sha256sum 0r434a8n04i14s4sp3fam23cplwyn1iw-generic-x86_64-debug-nixos.img 
1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a  0r434a8n04i14s4sp3fam23cplwyn1iw-generic-x86_64-debug-nixos.img`

Sign the hash with Yubikey

`$ ./start.sh --sign --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a
YubiKey found on USB Bus: 003, Device: 002
499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==`

Verify the signature (Valid case)
`alex@alex-unikie:~/repos/scs-pki-research/yubikey$ ./start.sh --verify --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a --sg=499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==
YubiKey found on USB Bus: 003, Device: 002
-------------
Hash:
1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337a
Using slot 0 with a present token (0x0)
Using signature algorithm ECDSA
Signature is valid`

Verofy signature (Invalid case)

`$ ./start.sh --verify --h=1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337b --sg=499OENQ5B08XVLL4nBJdeoWfYl2TbQEatp1SxeDMnqf527ie6OVBrNCh9SmfCD24rw6v/C/QQ13OOBHBehKQEA==
YubiKey found on USB Bus: 003, Device: 002
-------------
Hash:
1e648d85a8ca1c6f55fcc060bbcbd24a4ff2deb5844e198088689ca840f3337b
Using slot 0 with a present token (0x0)
Using signature algorithm ECDSA
Invalid signature`
