## Contract generation example with support for dynamic container registry definition

This sample creates an encrypted and signed contract and stores it locally in a file. You can later use the contract to provision a HPVS for VPC instance.
The contract will define the container registry and the credentials for pulling your workload container image.

### Prerequisite

Prepare your environment according to [these steps](../README.md)

### Define your settings

Define your settings:
- logdna_ingestion_hostname: The ingestion host name of your Log instance which you provisioned previously
- logdna_ingestion_key: The ingestion key of your Log instance
- registry: The container registry to pull your workload container image from
- pull_username: The container registry username for pulling your workload container image
- pull_password: The container registry password for pulling your workload container image

The settings are defined in form of Terraform variables.

Use one of the following options to define the variables:

#### Define the variables in a template file

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

#### Define environment variables

Set the following environment variables:

```text
TF_VAR_logdna_ingestion_key=
TF_VAR_logdna_ingestion_hostname=
TF_VAR_registry=
TF_VAR_pull_username=
TF_VAR_pull_password=
```

### Define your workload

Create the file `compose\docker-compose.yml` for your workload. Specify at least the container image digest and use the `${REGISTRY}` variable to reference the container registry defined in your settings, e.g.:

```
services:
  helloworld:
    image: ${REGISTRY}/hpse-docker-hello-world-s390x@sha256:43c500c5f85fc450060b804851992314778e35cadff03cb63042f593687b7347
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

### Further steps

The contract will be written to the file `build/contract.yml` and can now be used for e.g. provisining a HPVS for VPC instance.

Note that you will need to create a public gateway in your VPC before creating the HPVS for VPC instance. This is necessary to allow the HPVS for VPC instance to reach your Log instance through the public gateway. 
