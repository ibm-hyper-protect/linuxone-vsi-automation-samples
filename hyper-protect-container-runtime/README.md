## IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC Examples

## Preparation

- Install the [terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) for your environment
- Follow the description for the [IBM Cloud Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs#authentication) to setup authentication via environment variables (e.g. using the `IC_API_KEY` variable)
- Follow the description for [HPCR](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se#hpcr_setup_logging) to setup a logging instance. Capture the endpoint as the environment variable `TF_VAR_LOGDNA_INGESTION_HOSTNAME` and the ingestion key as `TF_VAR_LOGDNA_INGESTION_KEY`
- Select a region and zone to deploy the example to, set the `TF_VAR_IBMCLOUD_REGION` environment variable to the region and `TF_VAR_IBMCLOUD_ZONE` to the zone, e.g. like so:

  ```bash
  TF_VAR_IBMCLOUD_REGION=eu-gb
  TF_VAR_IBMCLOUD_ZONE=eu-gb-2
  ```

After completing these steps you have the following environment variables filled in:

```text
IC_API_KEY=
TF_VAR_IBMCLOUD_ZONE=
TF_VAR_IBMCLOUD_REGION=
TF_VAR_LOGDNA_INGESTION_KEY=
TF_VAR_LOGDNA_INGESTION_HOSTNAME=
```

## Examples

Follow the README in the subdirectory of the examples for further instructions:

- [hello-world](hello-world/README.md) - a minimal hello world example
  