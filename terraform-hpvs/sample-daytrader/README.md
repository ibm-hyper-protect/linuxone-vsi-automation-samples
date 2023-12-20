## Contract generation example for the Daytrader sample application

This sample creates an encrypted and signed contract and stores it locally in a file. You can later use the contract to provision a HPVS for VPC instance.
The contract will define the container image, the container registry and the credentials for pulling your workload container image.

### Build the daytrader sample application
On LinuxONE, e.g. a virtual server for VPC with s390x architecture, build the container image for the DayTrader sample application.

To do so, clone or [download](https://github.com/OpenLiberty/sample.daytrader8/archive/master.zip) this [repository](https://github.com/OpenLiberty/sample.daytrader8/).

From inside the sample.daytrader8 directory, build the application with the following commands:
```
mvn clean package
docker build . -t daytrader:s390x
```

Then tag and push the resulting container image to your container registry.

### Prerequisite

Prepare your local environment according to [these steps](../README.md)

### Define your settings

Define your settings:
- logdna_ingestion_hostname: The ingestion host name of your Log instance which you provisioned previously
- logdna_ingestion_key: The ingestion key of your Log instance
- registry: The container registry where the workload container image is pulled from, e.g. `us.icr.io`
- pull_username: The container registry username for pulling your workload container image
- pull_password: The container registry password for pulling your workload container image

The settings are defined in form of Terraform variables.

Define the variables in a template file:

1. `cp my-settings.auto.tfvars-template my-settings.auto.tfvars`
2. Fill the values in `my-settings.auto.tfvars`

### Define your workload

Create the file `compose\pod.yml` for your workload. Adapt the value for `image` to reference your container registry and your container image including the digest, e.g.:

```
apiVersion: v1
kind: Pod
metadata:
  name: daytrader
spec:
  containers:
  - name: daytrader
    image: us.icr.io/sample/daytrader@sha256:5f4f20aee41e27858a8ed320faed6c2eb8b62dd4bf3e1737f54575a756c7a5da
    ports:
    - containerPort: 9080
      hostPort: 9080
      protocol: tcp
```

### Create the contract

```bash
terraform init
terraform apply
```

### Further steps

The contract will be written to the file `build/contract.yml` and can now be used for e.g. provisining a HPVS for VPC instance.

Note that you will need to create a public gateway in your VPC before creating the HPVS for VPC instance. This is necessary to allow the HPVS for VPC instance to reach your Log instance through the public gateway. Also assign a floating IP to your HPVS for VPC instance.

Once the instance is started, you can access the application at: `http://<floatingip>:9080/daytrader`

After provisioning the HPVS for VPC instance you can use JMeter to test your daytrader application. To do so follow [these instructions](https://github.com/OpenLiberty/sample.daytrader8/blob/main/README_LOAD_TEST.md).
