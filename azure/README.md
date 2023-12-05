## Demo Scripts for Azure Key Vault Operations

This folder contains a set of Python scripts designed for demonstration purposes. These scripts showcase various operations using Azure Key Vault, including key management and cryptographic operations.

### Execution Prerequisites

Before running these scripts, ensure that the following Azure Python SDK modules are installed in your environment:

*   `azure-keyvault`
*   `azure-identity`

You can install these modules using pip:

**Bash**

```plaintext
pip install azure-keyvault azure-identity
```

**NixOS**

```plaintext
  environment.systemPackages = with pkgs; [
    (python38.withPackages(ps: with ps; [azure-keyvault azure-identity flask]))
  ];
```

### Script Descriptions

#### 1\. `kv_export_key.py`

This script is used to export the public key from an Azure Key Vault key pair.

**Usage**:

```plaintext
python kv_export_key.py
```

#### 2\. `kv_test.py`

This script demonstrates how to list keys stored in Azure Key Vault. It also shows how to sign a hash using EdDSA with a private key from Azure Key Vault and then verify the signature using the corresponding public key.

**Usage**:

```plaintext
python kv_test.py
```

#### 3\. `conv_sig.py`

This script converts a binary signature into ASN.1 format, which is readable by OpenSSL. This is useful for interoperability with systems and tools that utilize OpenSSL for cryptographic operations.

**Usage**:

```plaintext
python conv_sig.py
```

---

## Additional Information

Ensure that you have the necessary permissions and configurations set up in Azure Key Vault to perform these operations. For more detailed information on Azure Key Vault and its SDK, please refer to the [Azure Key Vault documentation](https://docs.microsoft.com/en-us/azure/key-vault/).
