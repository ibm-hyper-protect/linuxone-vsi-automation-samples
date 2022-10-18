## Postgres - Running s390x version of Postgres
​
This sample deploys one instance of [postgres](https://hub.docker.com/r/s390x/postgres/) on [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se) in a given region.
​
### Prerequisite
​
Prepare your environment according to [these steps](https://github.com/ibm-hyper-protect/linuxone-vsi-automation-samples/blob/master/terraform-hpvs/README.md)
​
### Settings
​
Set the following environment variables:
​
```text
export IBMCLOUD_API_ENDPOINT=https://test.cloud.ibm.com
export IBMCLOUD_IAM_API_ENDPOINT=https://iam.test.cloud.ibm.com
export IBMCLOUD_IS_NG_API_ENDPOINT=https://us-south-*.cloud.ibm.com/v1 #set the value
export IBMCLOUD_IS_API_ENDPOINT=https://us-south-*.cloud.ibm.com #set the value
```
​
Set the default vaule of variables.tf:
​
```text
"ibmcloud_api_key"
"region"
"zone" 
"logdna_ingestion_key"
"logdna_ingestion_hostname"
"prefix"
"profile" 
"ssh_public_key"
```
​
### Run the Example
​
- Initialize terraform:
​
```bash
terraform init
```
​
- Deploy the postgres container
​
```bash
terraform apply
```
​
This will create one instances of Hyper Protect Virtual Server for VPC instances in a given region and prints the public IP address of the VSI as an output to the console. You could use clients `psql` to connect to the database. 
​
```bash
psql -h ${vsi_ip} -p 5432 -U postgres
```
​
- Destroy the created resources:
​
```bash
terraform destroy
```
