# NitroHSM Usage guideline

## Creating CA Fast Forward

This article demonstrates the process of creating 3 Tier CA backed by NitroHSM 2. Which means that all of the private keys will be created and stored on HSM, thus keeping them secure. The certificate chain can be kept public in such case.

### Cryptography

NitroHSM2 module supports the following algorithms:

 - rsa 1024, 2048, 3072 and 4096
 - NIST-P 192, 256 and 384-521
 - Brainpool 192, 256-320 and 348-521
 - secp 192, 256 and 521

Curve25519 is not supported, which makes it harder to use it with NixOS.
secp256 is used for the demonstration purposes, however, secp521 is recommended for production use, both for ECDSA signing and ECDH key agreement.

### Demo CA Structure

The CA follows the three-tier CA from the ![Ghaf PKI document](https://tiiuae.github.io/ghaf/scs/pki.html "Ghaf PKI document"). 

![Ghaf PKI](https://tiiuae.github.io/ghaf/img/ca_implementation.drawio.png "Ghaf PKI")

The CA will have the following directory structure:

 certs - root CA
 config - configuration files for certificate creation and signing
 intermediate - intermediate CA CSRs and certificates
 subordinate - subordinate CA CSRs and certificates

### CA Configuration

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/create_root_cert.ini#L4-L10

### CA Creation Steps

Generate Root keypair on HSM

```bash
$ pkcs11-tool --keypairgen --key-type EC:secp256r1 --label root --pin <hsmpin>

Using slot 0 with a present token (0x0)
Key pair generated:
Private Key Object; EC
  label:      root
  ID:         df797e0543b6a04c0bb96b8934770f5b1da8d624
  Usage:      sign, derive
  Access:     none
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104ffbd7b5278e008271bac2449ce9885f2ba0e0456cfea46f5e427107b62ebd50b62294dda514144963edea76ccfe85133c6873ee9c5e9804cc2aa7790a040ba53
  EC_PARAMS:  06082a8648ce3d030107
  label:      root
  ID:         df797e0543b6a04c0bb96b8934770f5b1da8d624
  Usage:      verify, derive
  Access:     none
```

Create Root Certificate using 



```bash
$ openssl req -config create_root_cert.ini -engine pkcs11 -keyform engine -key df797e0543b6a04c0bb96b8934770f5b1da8d624 -new -x509 -days 3650 -sha512 -extensions v3_ca -out ../certs/root.crt

Engine "pkcs11" set.
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):
alex@alex-unikie:~/SCS/PKI/config$ openssl x509 -noout -text -in ../certs/root.crt 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            21:22:3b:95:df:8b:a9:13:18:6d:10:85:bf:2f:b5:52:b7:b1:22:25
        Signature Algorithm: ecdsa-with-SHA512
        Issuer: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate Authority, CN = Unikie Oy Root CA
        Validity
            Not Before: Jan 13 21:24:26 2023 GMT
            Not After : Jan 10 21:24:26 2033 GMT
        Subject: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate Authority, CN = Unikie Oy Root CA
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:ff:bd:7b:52:78:e0:08:27:1b:ac:24:49:ce:98:
                    85:f2:ba:0e:04:56:cf:ea:46:f5:e4:27:10:7b:62:
                    eb:d5:0b:62:29:4d:da:51:41:44:96:3e:de:a7:6c:
                    cf:e8:51:33:c6:87:3e:e9:c5:e9:80:4c:c2:aa:77:
                    90:a0:40:ba:53
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                0B:70:A7:50:6A:74:EF:A9:3B:BA:32:69:58:71:E5:93:B5:FC:14:03
            X509v3 Authority Key Identifier: 
                0B:70:A7:50:6A:74:EF:A9:3B:BA:32:69:58:71:E5:93:B5:FC:14:03
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
    Signature Algorithm: ecdsa-with-SHA512
    Signature Value:
        30:45:02:20:6b:52:08:e1:b1:c8:ca:9a:b0:af:b7:67:ff:d1:
        74:58:32:80:c2:55:09:8d:e9:02:01:0b:c6:4f:99:50:66:3b:
        02:21:00:b0:16:6e:c6:b0:1d:06:43:ea:13:08:82:43:5a:0d:
        02:c9:a0:5c:4e:0c:6c:93:63:f0:ce:41:b2:d4:2a:30:fd
```
