## Contract generation example

This sample creates an encrypted and signed contract and stores it locally in a file. 

### Prerequisite

Prepare your environment according to [these steps](../README.md)

### Settings

Use one of the following options to set you settings:

#### Template file

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

#### Environment variables

Set the following environment variables:

```text
TF_VAR_logdna_ingestion_key=
TF_VAR_logdna_ingestion_hostname=
TF_VAR_registry=
TF_VAR_pull_username=
TF_VAR_pull_password=
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
