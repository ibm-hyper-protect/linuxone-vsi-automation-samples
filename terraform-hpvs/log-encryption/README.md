## Encrypted Log Messages Example

This sample deploys a container as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

The deployment will create a private/public key-pair. The public part will be added to the [contract](https://cloud.ibm.com/docs/vpc?topic=vpc-about-contract_se) and then mounted into the container. The container in turn uses it to **encrypt selected logging messages**. These logging messages will appear in their encrypted version on the logging backend.

The deployer can now read the encrypted logs from the logging backend and decrypt them via the provided private key.

### Prerequisite

Prepare your environment:

### Settings

Use one of the following options to set you settings:

#### Environment variables

Set the following environment variables:

```text
IC_API_KEY=
TF_VAR_zone=
TF_VAR_region=
TF_VAR_logdna_ingestion_key=
TF_VAR_logdna_ingestion_hostname=
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

This will create a sample virtual server instance. Monitor your logDNA instance for

```text
Sep 6 14:35:19 hpcr-customer-encryption-key-logging-vsi compose-logging-1 info unencrypted message
Sep 6 14:35:19 hpcr-customer-encryption-key-logging-vsi compose-logging-1 info hyper-protect-basic.rdfpSzcyDiR7JIDgL1EiFMMmPlM6e44R916Gq44WiA0Hlwz5Mt3O2vPn66SVXAkRHWWGnTYgyLURRoKCsFs/PWcMzQLDI+M6z5H6DEVv7kAGESEmjiNxNrR3zjXHcoOBNVOgEdrZIUlI7r6eg3yN+iMz50zTm4C1j1raW6n420pr9BVcVlytP2CuAjz+nWhbK5/bkbGfrmUHVad/cduPL/ucyXwS0LQzBVFYvomSu0PqFYAQY6QxGVpmeKuUKChJ+kerIWncX2Qbao09PMZOtq9LBNqq7QxLSRcc6/MrMF2Imi8M/Ho94sRdX04zU86yEklJJhf5FMNL1FplZcE0ekWUOI0nDEo0cu8PwpCDuz9POC9+3fK5mvM1w4GrRbz5DqGb7HZF9Bq5Llw/cu5T63j52B+h9EDkUQ8wUodpcrG1+tPAfioXYLJYXbypVq+VeCrCAS+3iYJgoduQ1tcvKmm53rGL8v5TIda1tzAYXHXitVaaoheXd74P5U/2mxl6FNtOEHhDxCp7ZHMH2omyyf4pUnV+HezsMoX5c7QR9C0FqaHeSOeuLCASXuhe0Ak76RktwdQYl7AuFsT9jCMfnCUxTSSwimknTsN+PjYitaVWLnuvBlE4Q9nY3oQ35zueektWBJpzl2yDObuE07MEK69Ds0b3wPH5dxQLZtywBJw=.U2FsdGVkX18VMC96BdITb/s3ck+e7Z6rjA2HycHvzMnzivGZDMf2xk0kBc+cTEqM
```

Destroy the created resources:

```bash
terraform destroy
```

The encrypted message can be decrypted by running the [decrypt-basic.sh](./support/decrypt-basic.sh) command:

```bash
echo hyper-protect-basic.rdf...EqM | decrypt-basic.sh build/key.priv
```
