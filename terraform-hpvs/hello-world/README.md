## Hello-World Sample

This sample deploys the [hello-world](https://hub.docker.com/_/hello-world) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

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

This will create a sample virtual server instance. Monitor your logDNA instance for

```text
hpcr-sample-hello-world-vsi compose-helloworld-1 info
hpcr-sample-hello-world-vsi compose-helloworld-1 info Hello from Docker!
hpcr-sample-hello-world-vsi compose-helloworld-1 info This message shows that your installation appears to be working correctly.
hpcr-sample-hello-world-vsi compose-helloworld-1 info
hpcr-sample-hello-world-vsi compose-helloworld-1 info To generate this message, Docker took the following steps:
hpcr-sample-hello-world-vsi compose-helloworld-1 info 1. The Docker client contacted the Docker daemon.
hpcr-sample-hello-world-vsi compose-helloworld-1 info 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
hpcr-sample-hello-world-vsi compose-helloworld-1 info     (s390x)
hpcr-sample-hello-world-vsi compose-helloworld-1 info 3. The Docker daemon created a new container from that image which runs the
hpcr-sample-hello-world-vsi compose-helloworld-1 info     executable that produces the output you are currently reading.
hpcr-sample-hello-world-vsi compose-helloworld-1 info 4. The Docker daemon streamed that output to the Docker client, which sent it
hpcr-sample-hello-world-vsi compose-helloworld-1 info     to your terminal.
hpcr-sample-hello-world-vsi compose-helloworld-1 info
hpcr-sample-hello-world-vsi compose-helloworld-1 info To try something more ambitious, you can run an Ubuntu container with:
hpcr-sample-hello-world-vsi compose-helloworld-1 info $ docker run -it ubuntu bash
hpcr-sample-hello-world-vsi compose-helloworld-1 info
hpcr-sample-hello-world-vsi compose-helloworld-1 info Share images, automate workflows, and more with a free Docker ID:
hpcr-sample-hello-world-vsi compose-helloworld-1 info https://hub.docker.com/
hpcr-sample-hello-world-vsi compose-helloworld-1 info
hpcr-sample-hello-world-vsi compose-helloworld-1 info For more examples and ideas, visit:
hpcr-sample-hello-world-vsi compose-helloworld-1 info https://docs.docker.com/get-started/
hpcr-sample-hello-world-vsi compose-helloworld-1 info
```

Destroy the created resources:

```bash
terraform destroy
```
