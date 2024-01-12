## Contract generation example for the Paynow sample application

This sample creates an encrypted and signed contract and stores it locally in a file. You can later use the contract to provision a HPVS for VPC instance.
The contract will define the container image, the container registry and the credentials for pulling your workload container image, as well as a server certificate and server key.

### Prerequisite

Prepare your local environment according to [these steps](../README.md)

### Define your settings

In file `compose\pod.yml` adapt the value for `image` to reference your container registry and your container image including the digest.

Define your settings:
- logdna_ingestion_hostname: The ingestion host name of your Log instance which you provisioned previously
- logdna_ingestion_key: The ingestion key of your Log instance
- registry: The container registry where the workload container image is pulled from, e.g. `us.icr.io`
- pull_username: The container registry username for pulling your workload container image
- pull_password: The container registry password for pulling your workload container image
- server_cert: The base64-encoded server certificate
- server_key: The base64-encoded server key"

The settings are defined in form of Terraform variables.

Define the variables in a template file:

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

### Create the contract

```bash
terraform init
terraform apply
```

### Further steps

The contract will be written to the file `build/contract.yml` and can now be used for e.g. provisining a HPVS for VPC instance.

Note that you will need to create a public gateway in your VPC before creating the HPVS for VPC instance. This is necessary to allow the HPVS for VPC instance to reach your Log instance through the public gateway. Also assign a floating IP to your HPVS for VPC instance.

See this [repository](https://github.com/ibm-hyper-protect/paynow-website) for a description and the source code of the Paynow sample application.

