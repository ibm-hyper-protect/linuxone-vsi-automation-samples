# Getting Started with IBM HElayers SDK and Hyper Protect Virtual Server for VPC

This tutorial explains the steps to deploy IBM HElayers SDK 1.5.2.0 in IBM Hyper Protect Virtual Server for VPC and illustrates how you can combine Fully Homomorphic Encryption and Confidential Computing.

## Introduction

IBM HElayers Software Development Kit provides a practical and efficient execution workspace for encrypted workloads using fully homormorphic encrypted data. 

Confidential Computing is the protection of data-in-use through a hardware-based technique. IBM Hyper Protect Virtual Server for VPC (HPVS) provides a Trusted Execution Environment based on IBM Secure Execution for Linux for the IBM HElayers Software Development Kit and protects data in use by the SDK on the HPVS instance, even from privileged access.

If you are working with homomorphically encrypted data, via FHE, it would be difficult for someone to be able to read your privately encrypted data, however, it does not ensure data and application integrity, as the data can still be manipulated in its encrypted state.  By combining these two privacy enhancing technologies, we solve this issue by launching your FHE enabled application in a secure Hyper Protect instance, creating a trusted runtime environment.  With the combination of the two, FHE to protect your data, and Hyper Protect Virtual Servers to prevent data manipulation, you can ensure your data is protected from outside threats. 

## Estimated time

Completing this tutorial takes approximately 30 minutes.

## Prerequisites
To complete this tutorial, you need to meet the following prerequisites:

- Create an IBM Cloud account.
- [Create an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey) for your user identity. Save the API key value for subsequent use.
- [Install IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli).
- Create a [Log Analysis instance](https://cloud.ibm.com/catalog/services/logdna?callback=%2Fobserve%2Flogging%2Fcreate) on IBM Cloud by following [these instructions}(https://cloud.ibm.com/docs/vpc?topic=vpc-logging-for-hyper-protect-virtual-servers-for-vpc#log-analysis). Make a note of the ingestion host and the ingestion key.
- Install [Git](https://git-scm.com/downloads)
- Install the OpenSSL binary. For more information, see this [information on OpenSSL](https://github.com/ibm-hyper-protect/linuxone-vsi-automation-samples/tree/master/terraform-hpvs#openssl).
- Install the Terraform CLI for your environment by following the [Terraform documentation](https://developer.hashicorp.com/terraform).
  
## Steps
### Step 1: Provision your HPVS instance and IBM HElayers SDK 1.5.2.0
1. Use Git to clone this repository.
2. Change to this directory, e.g. with the following command:
```
cd linuxone-vsi-automation-samples\terraform-hpvs\fhe-helayers-sdk
```
3. Run the following command to create file `my-settings.auto.tfvars`
```
cp my-settings.auto.tfvars-template my-settings.auto.tfvars
```
4. Adapt the values in `my-settings.auto.tfvars`: Edit the file and provide the values for `logdna_ingestion_key` and `logdna_ingestion_hostname` of your Log Analysis instance and provide your API key value in `ibmcloud_api_key`.
5. Run the following command to initialize Terraform:
```
terraform init
```
6. Run the Terraform script. This will create a sample virtual private cloud (VPC) with one HPVS for VPC instance running the IBM HElayers SDK. You can monitor your Log Analysis instance for the logs of HPVS for VPC and the IBM HElayers SDK.
```
terraform apply
```

### Step2: Use the  the IBM HElayers SDK 1.5.2.0 notebook:
When finished, the Terraform script will print something like this:
```
   Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

   Outputs:

   hpvs_vsi_floating_ip = "xxx.xx.xx.xxx"
```

The script has automatically assigned a public IP to your HPVS instance, and you can use the `hpvs_vsi_floating_ip` to access the IBM HElayers SDK 1.5.2.0 notebook under this URL:
```
<ip>:8888/lab
```

NOTE: The preconfigured default password for the notebook is `demo-experience-with-fhe-and-python`

### Step 3: Cleanup the created resources
You can cleanup the created resources by running this command
```
terraform destroy
```

## Summary
You have successfully deployed a HPVS for VPC instance that is running IBM HElayers SDK 1.5.2.0 using a Terraform automation script. By running IBM HElayers SDK in Confidential Computing, the data and keys that are in use by the SDK are protected, even from privileged access. 

## Next Steps
Visit this [page](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se) to start learning about Confidential Computing with LinuxOne and IBM Hyper Protect Virtual Server for VPC (HPVS).
