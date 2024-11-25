## Contract generation with contract expiry example

This sample creates an encrypted and signed contract with expiry enabled and stores it locally in a file. In addition this example identifies
the latest version of HPCR in the VPC cloud and then downloads the matching encryption certifcicate.

### Prerequisite

Prepare your environment according to [these steps](../README.md). Make sure to setup IBM Cloud Logs Instance.

### Settings

#### Prerequisites

1. Generate private key using the following commnad:
    ```bash
    openssl genrsa -out private.pem 4096
    ```
2. Generate CA private key using the following command:
    ```bash
    openssl genrsa -out personal_ca.key 2048
    ```
3. Generate CA certificate using the following command:
    ```bash
    openssl req -new -x509 -days 365 -key personal_ca.key -out personal_ca.crt
    ```

Use one of the following options to set your settings:

#### Template file

1. Copy contents of `my-settings.auto.tfvars-template` to `my-settings.auto.tfvars`.
    ```bash
    cp my-settings.auto.tfvars-template my-settings.auto.tfvars
    ```
2. Update `my-settings.auto.tfvars` to appropriate values.

#### Environment variables

Set the following environment variables:

```text
TF_VAR_icl_iam_apikey="<ICL IAM Key>"
TF_VAR_icl_hostname="<ICL Hostname>"

TF_VAR_hpcr_csr_country="<CSR - Country>"
TF_VAR_hpcr_csr_state="<CSR - State>"
TF_VAR_hpcr_csr_location="<CSR - Location>"
TF_VAR_hpcr_csr_org="<CSR - Organisation>"
TF_VAR_hpcr_csr_unit="<CSR - Unit>"
TF_VAR_hpcr_csr_domain="<CSR - Domain>"
TF_VAR_hpcr_csr_mail="<CSR - Mail>"

TF_VAR_hpcr_private_key_path="<Private key path>"
TF_VAR_hpcr_contract_expiry_days=<Expiry days>
TF_VAR_hpcr_ca_privatekey_path="<CA private key path>"
TF_VAR_hpcr_cacert_path="<CA certificate path>"
```

### Run the Example

Initialize terraform:

```bash
terraform init
```

Deploy the example:

```bash
terraform apply
```

The contract will be persisted in the `build/contract.yml` folder for further use.