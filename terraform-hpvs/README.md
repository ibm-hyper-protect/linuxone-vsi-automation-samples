## IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC Examples

## Preparation

- Make sure to have the [OpenSSL](https://www.openssl.org/) binary installed (see [details](#openssl))
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
  

## OpenSSL

The [terraform provider](https://registry.terraform.io/providers/ibm-hyper-protect/hpcr/) leverages the [OpenSSL](https://www.openssl.org/) binary for all cryptographic operations in favour of the [golang crypto](https://pkg.go.dev/crypto) packages. This is because the golang libraries are not [FIPS](https://en.wikipedia.org/wiki/FIPS_140-2) certified whereas there exist certified OpenSSL binaries a customer can select. 

Make sure to have the binaries installed for your platform. **Note:** on some platforms the default binary is actually a [LibreSSL](https://www.libressl.org/) installation, which is **not** compatible.

Verify your installation via running:

```bash
openssl version
```

this should give an output similar to the following:

```text
OpenSSL 1.1.1q  5 Jul 2022
```

In case you cannot change the OpenSSL binary in the path, you may override the version used by the [terraform provider](https://registry.terraform.io/providers/ibm-hyper-protect/hpcr/) by setting the `OPENSSL_BIN` environment variable to the absolute path of the correct binary, e.g. 

```cmd
OPENSSL_BIN="C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
```
