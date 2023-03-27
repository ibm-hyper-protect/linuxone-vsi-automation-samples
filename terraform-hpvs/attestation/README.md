## Attestation Sample

This sample deploys the [attestation](https://hub.docker.com/_/attestation) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

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
IC_API_KEY=
TF_VAR_zone=
TF_VAR_region=
TF_VAR_logdna_ingestion_key=
TF_VAR_logdna_ingestion_hostname=
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

This will create a sample virtual server instance. Monitor your logDNA instance for

```text
hpcr-sample-attestation-vsi compose-helloworld-1 info
hpcr-sample-attestation-vsi compose-helloworld-1 info Hello from Docker!
hpcr-sample-attestation-vsi compose-helloworld-1 info This message shows that your installation appears to be working correctly.
hpcr-sample-attestation-vsi compose-helloworld-1 info
hpcr-sample-attestation-vsi compose-helloworld-1 info To generate this message, Docker took the following steps:
hpcr-sample-attestation-vsi compose-helloworld-1 info 1. The Docker client contacted the Docker daemon.
hpcr-sample-attestation-vsi compose-helloworld-1 info 2. The Docker daemon pulled the "attestation" image from the Docker Hub.
hpcr-sample-attestation-vsi compose-helloworld-1 info     (s390x)
hpcr-sample-attestation-vsi compose-helloworld-1 info 3. The Docker daemon created a new container from that image which runs the
hpcr-sample-attestation-vsi compose-helloworld-1 info     executable that produces the output you are currently reading.
hpcr-sample-attestation-vsi compose-helloworld-1 info 4. The Docker daemon streamed that output to the Docker client, which sent it
hpcr-sample-attestation-vsi compose-helloworld-1 info     to your terminal.
hpcr-sample-attestation-vsi compose-helloworld-1 info
hpcr-sample-attestation-vsi compose-helloworld-1 info To try something more ambitious, you can run an Ubuntu container with:
hpcr-sample-attestation-vsi compose-helloworld-1 info $ docker run -it ubuntu bash
hpcr-sample-attestation-vsi compose-helloworld-1 info
hpcr-sample-attestation-vsi compose-helloworld-1 info Share images, automate workflows, and more with a free Docker ID:
hpcr-sample-attestation-vsi compose-helloworld-1 info https://hub.docker.com/
hpcr-sample-attestation-vsi compose-helloworld-1 info
hpcr-sample-attestation-vsi compose-helloworld-1 info For more examples and ideas, visit:
hpcr-sample-attestation-vsi compose-helloworld-1 info https://docs.docker.com/get-started/
hpcr-sample-attestation-vsi compose-helloworld-1 info
```

Destroy the created resources:

```bash
terraform destroy
```
