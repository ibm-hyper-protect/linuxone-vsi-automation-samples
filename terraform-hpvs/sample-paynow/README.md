## Contract generation example for the PayNow sample application

This sample creates an encrypted and signed contract and stores it locally in a file. You can later use the contract to provision a HPVS for VPC instance.
The contract will define the container image, the container registry and the credentials for pulling your workload container image, as well as a server certificate and server key.

For more information, see this [tutorial](https://cloud.ibm.com/docs/vpc?topic=vpc-financial-transaction-confidential-computing-on-hyper-protect-virtual-server-for-vpc) and the [PayNow sample application](https://github.com/ibm-hyper-protect/paynow-website).

### Prerequisite

Prepare your local environment according to [these steps](../README.md). Make sure to setup IBM Cloud Logs Instance.

### Define your settings

In file `compose\pod.yml` adapt the value for `image` to reference your container registry and your container image including the digest.

Define your settings:
- icl_hostname: The host name of your ICL Log instance which you provisioned previously
- icl_iam_apikey: The API key of your Log instance
- registry: The container registry where the workload container image is pulled from, e.g. `us.icr.io`
- pull_username: The container registry username for pulling your workload container image
- pull_password: The container registry password for pulling your workload container image
- server_cert: The base64-encoded SSL server certificate
- server_key: The base64-encoded SSL server key

The settings are defined in form of Terraform variables in a template file:

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
