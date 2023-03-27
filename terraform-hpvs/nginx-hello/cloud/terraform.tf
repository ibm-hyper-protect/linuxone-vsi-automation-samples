terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.1"
    }

    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.37.1"
    }
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.4"
    }
  }
}

module "user_data" {
  source = "../user_data"
  logdna_ingestion_key        = var.logdna_ingestion_key
  logdna_ingestion_hostname   = var.logdna_ingestion_hostname
}

# make sure to target the correct region and zone
provider "ibm" {
  region = var.region
  zone   = "${var.region}-${var.zone}"
}

locals {
  # some reusable tags that identify the resources created by his sample
  tags = ["hpcr", "sample", var.prefix]
}

# the VPC
resource "ibm_is_vpc" "hello_world_vpc" {
  name = format("%s-vpc", var.prefix)
  tags = local.tags
}

# the security group
resource "ibm_is_security_group" "hello_world_security_group" {
  name = format("%s-security-group", var.prefix)
  vpc  = ibm_is_vpc.hello_world_vpc.id
  tags = local.tags
}

# rule that allows the VSI to make outbound connections, this is required
# to connect to the logDNA instance as well as to docker to pull the image
resource "ibm_is_security_group_rule" "hello_world_outbound" {
  group     = ibm_is_security_group.hello_world_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# rule that allows inbound traffic to the nginx server
resource "ibm_is_security_group_rule" "hello_world_inbound" {
  group     = ibm_is_security_group.hello_world_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

# the subnet
resource "ibm_is_subnet" "hello_world_subnet" {
  name                     = format("%s-subnet", var.prefix)
  vpc                      = ibm_is_vpc.hello_world_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone}"
  tags                     = local.tags
}

# create a random key pair, because for formal reasons we need to pass an SSH key into the VSI. It will not be used, that's why
# it can be random
resource "tls_private_key" "hello_world_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# we only need this because VPC expects this
resource "ibm_is_ssh_key" "hello_world_sshkey" {
  name       = format("%s-key", var.prefix)
  public_key = tls_private_key.hello_world_rsa_key.public_key_openssh
  tags       = local.tags
}

# locate all public image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"
}

# locate the latest hyper protect image
data "hpcr_image" "hyper_protect_image" {
  images = jsonencode(data.ibm_is_images.hyper_protect_images.images)
}

# construct the VSI
resource "ibm_is_instance" "hello_world_vsi" {
  name    = format("%s-vsi", var.prefix)
  image   = data.hpcr_image.hyper_protect_image.image
  profile = var.profile
  keys    = [ibm_is_ssh_key.hello_world_sshkey.id]
  vpc     = ibm_is_vpc.hello_world_vpc.id
  tags    = local.tags
  zone    = "${var.region}-${var.zone}"

  # the user data field carries the encrypted contract, so all information visible at the hypervisor layer is encrypted
  user_data = module.user_data.user_data

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.hello_world_subnet.id
    security_groups = [ibm_is_security_group.hello_world_security_group.id]
  }

}

# attach a floating IP since we would like to access the embedded server via the internet
resource "ibm_is_floating_ip" "hello_world_floating_ip" {
  name   = format("%s-floating-ip", var.prefix)
  target = ibm_is_instance.hello_world_vsi.primary_network_interface[0].id
  tags   = local.tags
}

# log the floating IP for convenience
output "ip" {
  value = resource.ibm_is_floating_ip.hello_world_floating_ip.address
  description = "The public IP address of the VSI" 
}

# output the contract as a plain text (debugging purpose)
resource "local_file" "user_data_plain" {
  content  = module.user_data.user_data_plan
  filename = "user-data-plain"
}

# output the contract (encrypted)
resource "local_file" "user_data" {
  content  = module.user_data.user_data
  filename = "user-data"
}