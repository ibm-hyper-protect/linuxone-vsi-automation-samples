## Postgres - Running s390x version of Postgres

This deploys a simple [postgres](https://hub.docker.com/r/s390x/postgres/) cluster on [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se). This will create a master instance and two slave instances. The postgres cluster only implements the function of master-slave backup. Slave instance backed up master instance.

### Prerequisite

Prepare your environment according to [these steps](https://github.com/ibm-hyper-protect/linuxone-vsi-automation-samples/blob/master/terraform-hpvs/README.md)

### Settings

Set the following environment variables:

```text
export IBMCLOUD_API_ENDPOINT=https://test.cloud.ibm.com
export IBMCLOUD_IAM_API_ENDPOINT=https://iam.test.cloud.ibm.com
export IBMCLOUD_IS_NG_API_ENDPOINT=https://us-south-*.cloud.ibm.com/v1 #set the value
export IBMCLOUD_IS_API_ENDPOINT=https://us-south-*.cloud.ibm.com #set the value
```

Set the default vaule of variables.tf:

```text
"ibmcloud_api_key"
"region"
"zone_master"
"zone_slave_1"
"zone_slave_2"
"logdna_ingestion_key"
"logdna_ingestion_hostname"
"prefix"
"profile" 
"ssh_public_key"
```

Create a new folder `compose_slave`:

```text
mkdir compose_slave
```

### Run the Example

- Initialize terraform:

```bash
terraform init
```

- Deploy the postgres container

```bash
terraform apply
```

This will create a master instance and two slave instances of Hyper Protect Virtual Server for VPC instances in given regions and prints the public IP address of the VSI as an output to the console. You could use clients `psql` to connect to the database.

```bash
psql -h ${vsi_ip} -p 5432 -U postgres
```

- Destroy the created resources:

```bash
terraform destroy
```
