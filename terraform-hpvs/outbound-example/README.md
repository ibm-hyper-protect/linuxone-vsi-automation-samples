# Outbound VPN connection example
This project will show how you can build and run an example workload container image on [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se). The example workload will use a VPN to connect to a given example web server running outside the IBM Cloud VPC.

## Before you begin
- Setup [OpenVPN](https://openvpn.net/) on your premises and create a corresponding `vpn.ovpn` client configuration file
- Run a web server, e.g. [NGINX](https://www.nginx.com/) on a server in your VPN and note its IP address and the port

## Prerequisites
- Sign up an IBM Cloud account
- Create an API key for your account
- Create a IBM Container Registry namespace in a region of your choice, e.g. by following https://cloud.ibm.com/registry/start

## Step 1: Build the example container image

- Provision a IBM Z, LinuxOne Virtual server for VPC instance on IBM Cloud. To do so, go to https://cloud.ibm.com/vpc-ext/provision/vs
- Login to this instance and build your example workload container image:
    - Install Docker CE
	- Install git
	- Clone this repository
    - Copy your `vpn.ovpn` client configuration file as well as related files (e.g. `.key` and `.crt` files) to the sub directory `terraform-hpvs/outbound-example/compose/image/vpn`
    - Adapt the file `terraform-hpvs/outbound-example/compose/image/vpn/start-vpn.sh`: Secify the IP address and port of your web server in line 5:
    - Go to directory `terraform-hpvs/outbound-example/compose/image` and run the following commands
```
docker build -t  outboundexample .
docker login -u iamapikey -p <your apikey> <region, e.g. uk>.icr.io
docker tag outboundexample <region>.icr.io/<namespace>/outboundexample
docker push <region>.icr.io/<namespace>/outboundexample
```
- Note the sha of your container image, you will need to specify it in a subsequent step.

## Step 2: Provision your VPC and run the example

### Settings

Perform the following steps in our local development environment:
- Clone this repository
- Prepare your environment. To do so refer to the [generic REAME](../README.md) file.
- In file `my-settings.auto.tfvars` add line:
```
private_container_registry="<region, e.g. uk>.icr.io"
```

- Adapt file `compose/docker-compose.yml`, e.g.:
```
services:
  outboundexample:
    image: <region>.icr.io/<namespace>/outboundexample@sha256:<sha>
    privileged: true
 ```

- Be sure to set the following environment variable:
```
IC_API_KEY=<your API key>
```

### Run the Example
```
terraform init
terraform apply
```

This creates a VPC named `hpcr-outbound-sample-vpc`, comprising one subnet including an attached instance named `hpcr-outbound-sample-vsi` (running your example workload) as well as a public gateway. To view your VPCs go to https://cloud.ibm.com/vpc-ext/network/vpcs

### Verify the example output 

- Open the Dashboard of your Logging instance
- Find the output of script `start-vpn.sh` in the logs. The script invokes `wget` on your web server and prints the received output, typically the contents of the `index.html` file of your web server, to the log.
- Check if you can see the contents of said file `index.html` in the log. If so, the VPN connection to your server and the HTTP GET request were successful.

## Step 3: Clean up
```
terraform destroy
```

You can also deprovision your IBM Z, LinuxOne Virtual server for VPC instance used for building the example workload container image.
