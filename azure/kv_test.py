from azure.identity import ClientSecretCredential
from azure.keyvault.keys import KeyClient

import hashlib
from azure.keyvault.keys.crypto import CryptographyClient, SignatureAlgorithm

# Keyvault specific data for token generation
key_vault_url = ""
tenant_id = ""
client_id = ""
client_secret = ""

credential = ClientSecretCredential(tenant_id, client_id, client_secret)

key_client = KeyClient(vault_url=key_vault_url, credential=credential)
keys = key_client.list_properties_of_keys()

for key in keys:
    print(key.name)

key = key_client.get_key(key.name)
crypto_client = CryptographyClient(key, credential)

digest = hashlib.sha256(b"mytext").digest()
result = crypto_client.sign(SignatureAlgorithm.es256, digest)
print (result.key_id)
print (result.algorithm)
signature = result.signature

print (result.signature)

print ("--------------------")
result = crypto_client.verify(SignatureAlgorithm.es256, digest, signature)
print ("Verification result: ", result.is_valid)
assert result.is_valid

with open("signature.bin", "wb") as file:
    file.write(signature)

#digest=hashlib.sha256(b"notmytext").digest()
#result = crypto_client.verify(SignatureAlgorithm.es256, digest, signature)
#print ("Verification result: ", result.is_valid)
#assert result.is_valid
