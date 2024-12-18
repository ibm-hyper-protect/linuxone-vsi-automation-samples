## Encrypted Log Messages Example

In this project we investigate how a deployer of a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se) can selectively encrypt log messages that are produced by a container. Per default log messages are sent via TLS to a logging backend but appear in clear text in that backend. We recommend to not include any sensitive information in these log message for that reason.

Our solution assumes the following:

- sensitive data is encrypted via hybrid encryption, e.g. by using the public part of an asymmetric key and a random passphrase per encryption step
- encryption requires an explicit coding step in the container that produces the log
- the result of the encryption step is a string that can be downloaded from the logging backend and decrypted using the private key that is in the hand of the deployer

Implementation decisions:

- we auto-generate the public/private keypair as part of this example. This is not required, the keypair could also be created out of band
- we use the `hyper-protect-basic` token approach to implement hybrid encryption, because other parts of the [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se) offering also use that schema. This is however an arbitrary decision, you may decide to use a different approach, e.g. using [gpg](https://www.gnupg.org/), the fundamental workflow stays the same.
- the docker container requires the `openssl` binary to implement the encryption step, ideally the binary should be part of the docker container. However in order to be able to use the off-the-shelf docker [ubuntu](https://hub.docker.com/_/ubuntu) image we install the `openssl` binary at container startup time. This is **not suggested** for production use.

Implementation outline:

This sample deploys a container as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

The deployment will auto create a private/public key-pair. The public part will be added to the [contract](https://cloud.ibm.com/docs/vpc?topic=vpc-about-contract_se) and then mounted into the container. The container in turn uses it to **encrypt selected logging messages**. These logging messages will appear in their encrypted version on the logging backend.

The deployer can now read the encrypted logs from the logging backend and decrypt them via the provided private key.

FAQ:

- *How is the public key embedded into the contract?* The public key is stored as a file in the same folder as the `docker-compose.yml` file, you may also use a subdirectory. The contract preparation step generates a `tgz` file out of this folder and embeds it as `base64` in the contract document. The server will untar this data, so the public key resides in the server side file system next to the compose file. From there it can be referenced via a `volumes` field and mounted into the container

- *What is the encryption/decryption algorithm?* The `hyper-protect-basic` encryption algorithm is described as part of the [attestation](https://cloud.ibm.com/docs/vpc?topic=vpc-about-attestation) documentation. For convenience this example provides the [encrypt-basic.sh](./compose/bin/encrypt-basic.sh) script to encrypt records and the [decrypt-basic.sh](./support/decrypt-basic.sh) script to decrypt the records.

### Prerequisite

Prepare your environment (also refer to the [generic REAME](../README.md). Make sure to setup IBM Cloud Logs Instance.

### Settings

Use one of the following options to set you settings:

#### Environment variables

Set the following environment variables:

```text
IC_API_KEY=
TF_VAR_zone=
TF_VAR_region=
TF_VAR_icl_iam_apikey=
TF_VAR_icl_hostname=
TF_VAR_artifactory_user=
TF_VAR_artifactory_key=
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

The encrypted message can be decrypted by running the [decrypt-basic.sh](./support/decrypt-basic.sh) command:

```bash
echo hyper-protect-basic.rdf...EqM | decrypt-basic.sh build/key.priv
```
