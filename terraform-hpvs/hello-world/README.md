## Hello-World Sample

This sample deploys the [hello-world](https://hub.docker.com/_/hello-world) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

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
IC_API_KEY=
TF_VAR_zone=
TF_VAR_region=
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

This will create a sample virtual server instance. Monitor your ICL instance for logs.

Destroy the created resources:

```bash
terraform destroy
```
