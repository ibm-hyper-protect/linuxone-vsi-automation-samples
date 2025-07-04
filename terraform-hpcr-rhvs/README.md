## IBM Hyper Protect Container Runtime for Red Hat Virtualization Services for On Prem Examples

## Preparation

1. Make sure to have the [OpenSSL](https://www.openssl.org/) binary installed (see [details](#openssl)).
2. Install the [terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) for your environment.
3. Make sure you have valid API Key for push logs to IBM Cloud Logs.
4. Follow the description for [HPCR](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se#hpcr_setup_logging) to setup a logging instance.
5. Set either environment variables or fill the template file according to the example README.

## Examples

Follow the README in the subdirectory of the examples for further instructions:

- [IBM Cloud Infrastructure Center](hello-world/README.md) - An Example to bring up nginx through ICIC
  

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
