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
secp256 is used for the demonstration purposes, however, secp521 is recommended for production use, both for EcDSA signing and ECDH key agreement.

### Demo CA Structure

The CA follows the three-tier CA from the [Ghaf PKI document](https://tiiuae.github.io/ghaf/scs/pki.html "Ghaf PKI document"). 

![Ghaf PKI](https://tiiuae.github.io/ghaf/img/ca_implementation.drawio.png "Ghaf PKI")

The CA will have the following directory structure:

 certs - root CA
 config - configuration files for certificate creation and signing
 intermediate - intermediate CA CSRs and certificates
 subordinate - subordinate CA CSRs and certificates

### CA Configuration Parameters

CA Configuration is done using OpenSSL configuration files. The syntax is very well explained in the man page, thus only brief description is provided in this document. For more details, please refer to [OpenSSL man page](https://www.openssl.org/docs/man3.1/man5/config.html "OpenSSL man page")

The following configuration files were created

  - create_root_cert.ini - creating Root Certificate
  - create_intermediate_csr.ini - create CSR for the Intermediate Certificate
  - create_subordinate_csr.ini - create CSR for the Subordinate Certificate
  - sign_intermediate_csr.ini - sign the CSR of the Intermediate Certificate
  - sign_subordinate_csr.ini - sign the CSR of the Subordinate Certificate

create_root_cert.ini is used to create the Root CA. Among st others, it contains the following sections:

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/create_root_cert.ini#L20-L26

Defines the policy of the fields. 

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/create_root_cert.ini#L28-L33

default_md represents the default message digest algorithm. sha512 in this case.

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/create_root_cert.ini#L35-L40

Defines Distinguished Name for the certificate to be created.

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/create_root_cert.ini#L42-L46

subjectKeyIdentifier is chosen to follow the process, specified in RFC 5280 section 4.2.1.2 (1):
 The keyIdentifier is composed of the 160-bit SHA-1 hash of the value of the BIT STRING subjectPublicKey (excluding the tag, length, and number of unused bits). 

authorityKeyIdentifier is chosen to copy SKID from the issuer certificate except if the issuer certifiate is the same as the current one and it is not self-signed. The hash of the public key related to the signing key is taken as fallback if the issuer certificate is the same as the current certificate. If no value can be obtained, an error is returned.

basicConstraints is a multi-valued extension, indicating whether a certificate is a CA cetificate.

keyUsage is a multi-valued extension, indicating permitted key usages. The following values are used in this CA:

  - digitalSignature - may be used to apply a digital signature
  - cRLSign - public key is used to verify signatures on revocation information, such as CRL
  - keyCertSign - public key is used to verify signatures on certificates

https://github.com/tiiuae/scs-pki-research/blob/4ea9d818c62f8a0e5eada41fba0b15888651c538/nitroCA/config/sign_intermediate_csr.ini#L36

In case of signing configurations, basicConstraints contains pathlen parameter. It defines how many certificates can be below the current certificate. In case of intermediate certificate the pathlen is 1, whereas in case of subordinate it is 0. Thus, subordinate certificate can not be used to sign certificates.


### CA Creation Steps

Generate Root secp256r1 (just for the demo) keypair on HSM

```
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

Create Root Certificate using create_root_cert.ini

```
$ openssl req -config create_root_cert.ini -engine pkcs11 -keyform engine -key df797e0543b6a04c0bb96b8934770f5b1da8d624 -new -x509 -days 3650 -sha512 -extensions v3_ca -out ../certs/root.crt

Engine "pkcs11" set.
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):
```

The contents can be displayed with the following openSSL command:

```
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

Create keypair for the Intermediate CA

```
alex@alex-unikie:~/SCS/PKI/config$ pkcs11-tool -l --keypairgen --key-type EC:secp256r1 --label intermediate
Using slot 0 with a present token (0x0)
Logging in to "SmartCard-HSM (UserPIN)".
Please enter User PIN:
Key pair generated:
Private Key Object; EC
  label:      intermediate
  ID:         74941030853c16e9bc916f13c1afefaf097dc0d9
  Usage:      sign, derive
  Access:     none
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104f065b5ecf77a5c9da0ed99b0a905644cfa94d05714220cb9608e6fbd6c2f49ff01531ae8692a0e8debb\
6053c06409601d226a2333faeb9809092b6b09bc136d2
  EC_PARAMS:  06082a8648ce3d030107
  label:      intermediate
  ID:         74941030853c16e9bc916f13c1afefaf097dc0d9
  Usage:      verify, derive
  Access:     none
  
```

Create Certificate Signing Request for Intermediate CA

```
alex@alex-unikie:~/SCS/PKI/config$ openssl req -config create_intermediate_csr.ini -engine pkcs11 -keyform engine -key 74941030853c16e9bc916f13c1afefaf097dc0d9 -new -sha512 -out ../intermediate/csr/intermediate.csr

Engine "pkcs11" set.
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN): 
```

Display the contents of the CSR

```
alex@alex-unikie:~/SCS/PKI/config$ openssl req -text -noout -verify -in ../interme\
diate/csr/intermediate.csr
Certificate request self-signature verify OK
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate A\
uthority, CN = Unikie Oy Intermediate CA
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:f0:65:b5:ec:f7:7a:5c:9d:a0:ed:99:b0:a9:05:
                    64:4c:fa:94:d0:57:14:22:0c:b9:60:8e:6f:bd:6c:
                    2f:49:ff:01:53:1a:e8:69:2a:0e:8d:eb:b6:05:3c:
                    06:40:96:01:d2:26:a2:33:3f:ae:b9:80:90:92:b6:
                    b0:9b:c1:36:d2
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        Attributes:
            (none)
            Requested Extensions:
    Signature Algorithm: ecdsa-with-SHA512
    Signature Value:
        30:44:02:20:65:8b:06:ec:91:b0:24:52:af:ab:c8:b5:36:51:
        74:de:c3:1f:6e:97:bf:7a:29:07:2c:8e:c3:ae:31:33:d7:42:
        02:20:00:b7:69:a2:1b:57:13:89:9a:84:0c:96:01:35:e2:fd:
        04:1d:a7:f3:4f:5f:3e:37:d4:35:f8:23:12:7c:8d:61
```

Sign the CSR -> Generate the Intermediate CA

```
alex@alex-unikie:~/SCS/PKI/config$ openssl ca -config sign_intermediate_csr.ini -engine pkcs11 -keyform engine -extensions v3_intermediate_ca -days 1825 -notext -md sha512 -create_serial -in ../intermediate/csr/intermediate.csr -out ../intermediate/certs/intermediate.crt
Engine "pkcs11" set.
Using configuration from sign_intermediate_csr.ini
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            54:96:4c:8e:4c:78:f6:ad:6b:d1:a4:8d:5d:0a:39:8e:7c:95:66:80
        Validity
            Not Before: Jan 13 21:52:18 2023 GMT
            Not After : Jan 12 21:52:18 2028 GMT
        Subject:
            countryName               = FI
            stateOrProvinceName       = Uusimaa
            organizationName          = Unikie Oy
            organizationalUnitName    = Unikie Oy Certificate Authority
            commonName                = Unikie Oy Intermediate CA
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                68:31:ED:A8:D6:04:03:85:54:6B:2D:43:F8:3F:50:85:D0:8A:B5:C3
            X509v3 Authority Key Identifier:
                0B:70:A7:50:6A:74:EF:A9:3B:BA:32:69:58:71:E5:93:B5:FC:14:03
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
Certificate is to be certified until Jan 12 21:52:18 2028 GMT (1825 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```
Verify Intermediate CA against Root CA

```
alex@alex-unikie:~/SCS/PKI/config$ openssl verify -CAfile ../certs/root.crt ../intermediate/certs/intermediate.crt
../intermediate/certs/intermediate.crt: OK
```
Create the certificate chain (RootCA-IntermediateCA)

```
alex@alex-unikie:~/SCS/PKI/config$ cat ../intermediate/certs/intermediate.crt ../certs/root.crt > ../intermediate/certs/chain.crt
```
Create the Subordinate CA keypair

```
alex@alex-unikie:~/SCS/PKI/config$ pkcs11-tool -l --keypairgen --key-type EC:secp256r1 --label subordinate
Using slot 0 with a present token (0x0)
Logging in to "SmartCard-HSM (UserPIN)".
Please enter User PIN:
Key pair generated:
Private Key Object; EC
  label:      subordinate
  ID:         415f2f0588fbfd484f4e7026e30ee44178b6b952
  Usage:      sign, derive
  Access:     none
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104d9e2f6624ef5f001ab6237f936a1a2f522d9fc5a1147a3738a713b2c33e204\
3e8c85056d0312b51722059f9b1c7a6d136a1b5b1a308c5e3e7d978b8298aa83a0
  EC_PARAMS:  06082a8648ce3d030107
  label:      subordinate
  ID:         415f2f0588fbfd484f4e7026e30ee44178b6b952
  Usage:      verify, derive
  Access:     none
```
Create CSR for the Subordinate Certificate

```
alex@alex-unikie:~/SCS/PKI/config$ openssl req -config create_subordinate_csr.ini -engine pkcs11 -keyform engine -key 415f2f0588fbfd484f4e7026e30ee44178b6b952 -new -sha512 -out ../subordinate/csr/subordinate.csr
Engine "pkcs11" set.
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):
```
Display the contents of the CSR

```
alex@alex-unikie:~/SCS/PKI/config$ openssl req -text -noout -verify -in ../subordinate/csr/subordinate.csr
Certificate request self-signature verify OK
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate A\
uthority, CN = Unikie Oy Subordinate CA
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:d9:e2:f6:62:4e:f5:f0:01:ab:62:37:f9:36:a1:
                    a2:f5:22:d9:fc:5a:11:47:a3:73:8a:71:3b:2c:33:
                    e2:04:3e:8c:85:05:6d:03:12:b5:17:22:05:9f:9b:
                    1c:7a:6d:13:6a:1b:5b:1a:30:8c:5e:3e:7d:97:8b:
                    82:98:aa:83:a0
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        Attributes:
            (none)
            Requested Extensions:
    Signature Algorithm: ecdsa-with-SHA512
    Signature Value:
        30:44:02:20:58:ae:d5:39:ce:5d:b1:38:e9:f0:d1:c9:80:cd:
        a1:80:c8:e8:94:74:57:a8:45:f0:e7:9d:f0:28:64:c9:c7:3e:
        02:20:20:ad:f8:3a:41:00:fb:1c:36:e4:97:dc:ab:18:50:1b:
        a2:2f:54:05:6f:e5:af:1d:79:fc:85:d7:56:e8:04:89
```

Sign the Subordinate CSR -> Generate the Subordinate Certificate

```
alex@alex-unikie:~/SCS/PKI/config$ openssl ca -config sign_subordinate_csr.ini -engine pkcs11 -keyform engine -extensions v3_subordinate_ca -days 365 -notext -md sha512 -create_serial -in ../subordinate/csr/subordinate.csr --out ../subordinate/certs/subordinate.crt
Engine "pkcs11" set.
Using configuration from sign_subordinate_csr.ini
Enter PKCS#11 token PIN for SmartCard-HSM (UserPIN):
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number:
            54:96:4c:8e:4c:78:f6:ad:6b:d1:a4:8d:5d:0a:39:8e:7c:95:66:81
        Validity
            Not Before: Jan 13 22:48:56 2023 GMT
            Not After : Jan 13 22:48:56 2024 GMT
        Subject:
            countryName               = FI
            stateOrProvinceName       = Uusimaa
            organizationName          = Unikie Oy
            organizationalUnitName    = Unikie Oy Certificate Authority
            commonName                = Unikie Oy Subordinate CA
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                7B:E8:E7:24:96:A9:F1:E2:DF:6C:C6:FD:60:9B:16:FE:6F:25:EE:29
            X509v3 Authority Key Identifier:
                68:31:ED:A8:D6:04:03:85:54:6B:2D:43:F8:3F:50:85:D0:8A:B5:C3
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
Certificate is to be certified until Jan 13 22:48:56 2024 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

Display the contents of the Subordinate Certificate

```
alex@alex-unikie:~/SCS/PKI/config$ openssl x509 --noout -text -in ../subordinate/certs/subordinate.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            54:96:4c:8e:4c:78:f6:ad:6b:d1:a4:8d:5d:0a:39:8e:7c:95:66:81
        Signature Algorithm: ecdsa-with-SHA512
        Issuer: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate Au\
thority, CN = Unikie Oy Intermediate CA
        Validity
            Not Before: Jan 13 22:48:56 2023 GMT
            Not After : Jan 13 22:48:56 2024 GMT
        Subject: C = FI, ST = Uusimaa, O = Unikie Oy, OU = Unikie Oy Certificate A\
uthority, CN = Unikie Oy Subordinate CA
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:d9:e2:f6:62:4e:f5:f0:01:ab:62:37:f9:36:a1:
                    a2:f5:22:d9:fc:5a:11:47:a3:73:8a:71:3b:2c:33:
                    e2:04:3e:8c:85:05:6d:03:12:b5:17:22:05:9f:9b:
                    1c:7a:6d:13:6a:1b:5b:1a:30:8c:5e:3e:7d:97:8b:
                    82:98:aa:83:a0
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                7B:E8:E7:24:96:A9:F1:E2:DF:6C:C6:FD:60:9B:16:FE:6F:25:EE:29
            X509v3 Authority Key Identifier:
                68:31:ED:A8:D6:04:03:85:54:6B:2D:43:F8:3F:50:85:D0:8A:B5:C3
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
    Signature Algorithm: ecdsa-with-SHA512
    Signature Value:
        30:45:02:20:3c:8c:a7:b3:c8:7d:c1:62:1e:a5:55:ca:67:93:
        09:ba:aa:87:da:df:23:70:da:cd:54:d2:33:ba:d9:04:84:5b:
        02:21:00:ab:72:9d:6e:81:ba:80:ea:be:f7:3f:53:e7:f9:b4:
        4e:f1:74:36:1a:40:c9:c4:05:78:6a:8a:4c:1b:c9:3c:b4
```

Verify the Subordinate Certificate against the Certificate Chain (RootCA-IntermediateCA)

```
alex@alex-unikie:~/SCS/PKI$ openssl verify -CAfile intermediate/certs/chain.crt subordinate/certs/subordinate.crt
subordinate/certs/subordinate.crt: OK
```
