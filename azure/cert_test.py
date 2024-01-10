# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

from azure.identity import ClientSecretCredential                                                                                                                            
from azure.keyvault.certificates import CertificateClient, CertificatePolicy
import hashlib
from azure.keyvault.keys import KeyClient
from azure.keyvault.keys.crypto import CryptographyClient, SignatureAlgorithm

# Keyvault specific data for token generation                                                                                       
tenant_id = ""
client_id = ""
client_secret = ""
key_vault_url = ""

credential = ClientSecretCredential(tenant_id, client_id, client_secret)

# Certificate to be used
certificate_name = "GhafSCSTest2"

# Instantiate a certificate client & key client to derive the key
# corresponding to the certificate
certificate_client = CertificateClient(vault_url=key_vault_url, credential=credential)
key_client = KeyClient (vault_url=key_vault_url, credential=credential)

certificate = certificate_client.get_certificate(certificate_name)

print(certificate.name)
print(certificate.properties.version)

key = key_client.get_key(certificate_name)

# Instantiate Cryptography client with the certificate private key
crypto_client = CryptographyClient(key, credential)

# Digest and hash a simple text
digest = hashlib.sha256(b"mytext").digest()
result = crypto_client.sign(SignatureAlgorithm.es256, digest)

print (result.key_id)
print (result.algorithm)
signature = result.signature
print(signature)
print ("-------------------------")

# Verify the signature
result = crypto_client.verify(SignatureAlgorithm.es256, digest, signature)
print ("Verification result: ", result.is_valid)
assert result.is_valid
