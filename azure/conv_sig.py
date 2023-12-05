from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes
import base64
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature, encode_dss_signature

# Read the raw signature from 'signature.bin'
with open('signature.bin', 'rb') as f:
    raw_signature = f.read()

# Assuming the signature is a 64-byte concatenation of r and s values (32 bytes each)
r = int.from_bytes(raw_signature[:32], byteorder='big')
s = int.from_bytes(raw_signature[32:], byteorder='big')

# Encode the signature in ASN.1/DER format
der_signature = encode_dss_signature(r, s)

# Write the converted signature to a new file
with open('converted_signature.der', 'wb') as f:
    f.write(der_signature)
