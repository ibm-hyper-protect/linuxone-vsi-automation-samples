## Contract generation example

This sample creates an encrypted and signed contract and stores it locally in a file. 

### Prerequisite

Prepare your environment according to [these steps](../README.md). Make sure to setup IBM Cloud Logs Instance.

### Settings

Use one of the following options to set you settings:

#### Template file

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

#### Environment variables

Set the following environment variables:

```text
TF_VAR_icl_iam_apikey=
TF_VAR_icl_hostname=
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
