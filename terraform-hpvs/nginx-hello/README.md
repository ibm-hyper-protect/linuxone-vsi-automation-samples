## Hello-World Sample

This sample deploys the [nginx-hello](https://hub.docker.com/r/nginxdemos/hello/) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

### Prerequisite

Prepare your environment according to [these steps](../README.md)

### Run the Example

Initialize terraform:

```bash
terraform init
```

Deploy the example:

```bash
terraform apply
```

This will create a sample virtual server instance and prints the public IP address of your VSI as an output to the console. Use your browser to access:

```text
http://<IP>
```

This will show a sceen like this:

![nginx](images/nginx.jpg)

Destroy the created resources:

```bash
terraform destroy
```
