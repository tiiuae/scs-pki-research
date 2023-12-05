# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
# SPDX-License-Identifier: Apache-2.0

import jwt
from base64 import urlsafe_b64encode

from azure.identity import ClientSecretCredential
from azure.keyvault.keys import KeyClient

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ec

from cryptography.hazmat.primitives.asymmetric.ec import SECP256R1, SECP384R1, SECP521R1

# Keyvault specific data for token generation
key_vault_url = ""
tenant_id = ""
client_id = ""
client_secret = ""

credential = ClientSecretCredential(tenant_id, client_id, client_secret)

key_client = KeyClient(vault_url=key_vault_url, credential=credential)
key = key_client.get_key("testKey")

usable_jwk = {}
for k in vars(key.key):
    value = vars(key.key)[k]
    if value:
        usable_jwk[k]=urlsafe_b64encode(value) if isinstance(value,bytes) else value

public_key=jwt.algorithms.ECAlgorithm.from_jwk(usable_jwk)
public_pem = public_key.public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

print (public_pem)
#with open ('public_key.pem', 'wb') as file:
#    file.write(public_pem)
    
