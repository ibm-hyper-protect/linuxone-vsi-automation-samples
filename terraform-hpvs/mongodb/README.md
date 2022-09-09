## MongoDB - Running s390x version of MongoDB

This sample deploys the [mongodb](https://hub.docker.com/r/s390x/mongo/) on [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

### Prerequisite

Prepare your environment according to [these steps](https://github.com/ibm-hyper-protect/linuxone-vsi-automation-samples/blob/master/terraform-hpvs/README.md)

### Settings

Use one of the following methods to apply the settings:

#### Method_A: Using a template file

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

#### Method_B: Setting the environment variables

Set the following environment variables:

```text
IC_API_KEY=
TF_VAR_zone=
TF_VAR_region=
TF_VAR_logdna_ingestion_key=
TF_VAR_logdna_ingestion_hostname=
TF_VAR_mongo_user=
TF_VAR_mongo_password=
```

### Run the Example

- Initialize terraform:

```bash
terraform init
```

- Deploy the mongodb container

```bash
terraform apply
```

This will create a Hyper Protect Virtual Server for VPC instance and prints the public IP address of your VSI as an output to the console. You could use clients such as `mongosh` or `MongoDB Compass` to connect to the database.

```text
mongodb://<mongo_user>:<mongo_password>@<public_ip>:27017/?authMechanism=DEFAULT

Note: Default credentials are : mongouser/mongouser
```

Example: 
```text
mongosh -u mongouser -p mongouser mongodb://x.x.x.x:27017/
Current Mongosh Log ID:	631af8b8c895c1ef42790efb
Connecting to:	mongodb://<credentials>@x.x.x.x:27017/?directConnection=true&appName=mongosh+1.5.4
Using MongoDB:	4.4.6
Using Mongosh:	1.5.4
.........
.........
test>
```

- Destroy the created resources:

```bash
terraform destroy
```
