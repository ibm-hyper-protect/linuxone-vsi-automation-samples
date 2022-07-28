## Hello-World Sample

This sample deploys the [nginx-hello](https://hub.docker.com/r/nginxdemos/hello/) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

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
export IC_API_KEY=
export TF_VAR_zone=
export TF_VAR_region=
export TF_VAR_logdna_ingestion_key=
export TF_VAR_logdna_ingestion_hostname=
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

This will create a sample virtual server instance and prints the public IP address of your VSI as an output to the console. Use your browser to access:

```text
http://<IP>
```

This will show a sceen like this:

![nginx](images/nginx.jpg)

Destroy the created resources:

```bash
terraform destroy
```
