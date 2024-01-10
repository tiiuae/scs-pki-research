# SPDX-FileCopyrightText: 2024 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

"""Demo script for cert based signing with keyvault"""

import hashlib

from azure.identity import ClientSecretCredential
from azure.keyvault.certificates import CertificateClient
from azure.keyvault.keys import KeyClient
from azure.keyvault.keys.crypto import CryptographyClient, SignatureAlgorithm

# Keyvault specific data for token generation
#
# THIS IS FOR DEMO ONLY! DO NOT HARDCODE ANY AUTH MATERIAL IN PRODUCTION CODE!
#
TENANT_ID = ""
CLIENT_ID = ""
CLIENT_SECRET = ""
KEYVAULT_URL = ""

credential = ClientSecretCredential(TENANT_ID, CLIENT_ID, CLIENT_SECRET)

# Certificate to be used
CERTIFICATE_NAME = "GhafSCSTest2"

# Instantiate a certificate client & key client to derive the key
# corresponding to the certificate
certificate_client = CertificateClient(vault_url=KEYVAULT_URL, credential=credential)
key_client = KeyClient (vault_url=KEYVAULT_URL, credential=credential)

certificate = certificate_client.get_certificate(CERTIFICATE_NAME)

print(certificate.name)
print(certificate.properties.version)

key = key_client.get_key(CERTIFICATE_NAME)

# Instantiate Cryptography client with the certificate private key
crypto_client = CryptographyClient(key, credential)

# Digest and hash a simple text
DIGEST = hashlib.sha256(b"mytext").digest()
result = crypto_client.sign(SignatureAlgorithm.es256, DIGEST)

print (result.key_id)
print (result.algorithm)
signature = result.signature
print(signature)
print ("-------------------------")

# Verify the signature
result = crypto_client.verify(SignatureAlgorithm.es256, DIGEST, signature)
print ("Verification result: ", result.is_valid)
assert result.is_valid
