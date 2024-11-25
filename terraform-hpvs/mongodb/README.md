## MongoDB - Running s390x version of MongoDB

This sample deploys 3 instances of [mongodb](https://hub.docker.com/r/s390x/mongo/) on [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se) across 3 avaiability zones of a given region

### Prerequisite

Prepare your environment according to [these steps](https://github.com/ibm-hyper-protect/linuxone-vsi-automation-samples/blob/master/terraform-hpvs/README.md). Make sure to setup IBM Cloud Logs Instance.

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
TF_VAR_icl_iam_apikey=
TF_VAR_icl_hostname=
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

This will create 3 instances of Hyper Protect Virtual Server for VPC instances across 3 availability zones of a given region and prints the public IP address of each VSIs as an output to the console. You could use clients such as `mongosh` or `MongoDB Compass` to connect to the database.

Before starting to use this setup as a cluster, login to any of the MongoDB instances and then setup the replica set.

```text
mongodb://<public_ip_vsi_1>:27017

Note: This establishes a session to MongoDB instance
```
Once inside the instance,  execute below commands at `test>` prompt
```
test> rs.show

test> rs.initiate({ _id: "<replica_set_name", members: [ {_id: 0, host: "vsi_1_public_ip:27017"}, {_id: 1, host: "vsi_2_public_ip:27017"}, {_id: 2, host: "vsi_3_public_ip:27017"} ] })

The above command should give `ok: 1,` as a result in success.

After the successful operation, execute:

test> rs.status()

This command should give an array with 3 instances of MongoDB having 1 PRIMARY and 2 SECONDARY
```
Example:
```
test> rs.show

test> rs.initiate({ _id: "replicaSet01", members: [ {_id: 0, host: "xx.xx.xx.xx:27017"}, {_id: 1, host: "yy.yy.yy.yy:27017"}, {_id: 2, host: "zz.zz.zz.zz.118:27017"} ] })
{
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1663579880, i: 1 }),
    signature: {
      hash: Binary(Buffer.from("0000000000000000000000000000000000000000", "hex"), 0),
      keyId: Long("0")
    }
  },
  operationTime: Timestamp({ t: 1663579880, i: 1 })
}

test> rs.status()
{
  set: 'replicaSet01',
  date: ISODate("2022-09-19T09:31:25.003Z"),
  myState: 2,
  term: Long("0"),
.....
......
 members: [
    {
      _id: 0,
      name: 'xx.xx.xx.xx:27017',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
	  ...
	  ...
	},
	{
      _id: 1,
      name: 'yy.yy.yy.yy:27017',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',
	  ...
	  ...
	},
	{
	      _id: 2,
      name: 'zz.zz.zz.zz:27017',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
	}```

TEST: You could reboot the `PRIMARY` node and see that the cluster will have a new `PRIMARY` elected.

After setting up the cluster, exit and then login to the cluster by passing-in `IP:port` of all the 3 instances as given below:

```
mongosh mongodb://xx.xx.xx.xx:27017,yy.yy.yy.yy:27017,zz.zz.zz.zz:27017
```
- Destroy the created resources:

```bash
terraform destroy
```

**TODO**: Currently the auth is disabled while setting up replication. This repo will be updated once there is support for enabling authentication.
