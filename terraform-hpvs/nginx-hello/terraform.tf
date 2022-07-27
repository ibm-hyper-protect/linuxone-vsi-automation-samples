terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.1"
    }

    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.37.1"
    }
  }
}

# make sure to target the correct region and zone
provider "ibm" {
  region = var.IBMCLOUD_REGION
  zone   = var.IBMCLOUD_ZONE
}

locals {
  # some reusable tags that identify the resources created by his sample
  tags = ["hpcr", "sample", var.PREFIX]
}

# the VPC
resource "ibm_is_vpc" "hello_world_vpc" {
  name = format("%s-vpc", var.PREFIX)
  tags = local.tags
}

# the security group
resource "ibm_is_security_group" "hello_world_security_group" {
  name = format("%s-security-group", var.PREFIX)
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
  name                     = format("%s-subnet", var.PREFIX)
  vpc                      = ibm_is_vpc.hello_world_vpc.id
  total_ipv4_address_count = 256
  zone                     = var.IBMCLOUD_ZONE
  tags                     = local.tags
}

# archive of the folder containing docker-compose file. This folder could create additional resources such as files 
# to be mounted into containers, environment files etc. This is why all of these files get bundled in a tgz file (base64 encoded)
resource "hpcr_tgz" "contract" {
  folder = "compose"
}

locals {
  # contract in clear text
  contract = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logDNA" : {
          "ingestionKey" : var.LOGDNA_INGESTION_KEY,
          "hostname" : var.LOGDNA_INGESTION_HOSTNAME,
        }
      }
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    }
  })
}

# create a random key pair, because for formal reasons we need to pass an SSH key into the VSI. It will not be used, that's why
# it can be random
resource "tls_private_key" "hello_world_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# we only need this because VPC expects this
resource "ibm_is_ssh_key" "hello_world_sshkey" {
  name       = format("%s-key", var.PREFIX)
  public_key = tls_private_key.hello_world_rsa_key.public_key_openssh
  tags       = local.tags
}

# locate the latest hyper protect image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"

}

locals {
  # filter the available images down to the hyper protect one
  hyper_protect_image = one(toset([for each in data.ibm_is_images.hyper_protect_images.images : each if each.os == "hyper-protect-1-0-s390x" && each.architecture == "s390x"]))
}

# In this step we encrypt the fields of the contract and sign the env and workload field. The certificate to execute the 
# encryption it built into the provider and matches the latest HPCR image. If required it can be overridden. 
# We use a temporary, random keypair to execute the signature. This could also be overriden. 
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
}

# construct the VSI
resource "ibm_is_instance" "hello_world_vsi" {
  name    = format("%s-vsi", var.PREFIX)
  image   = local.hyper_protect_image.id
  profile = var.PROFILE
  keys    = [ibm_is_ssh_key.hello_world_sshkey.id]
  vpc     = ibm_is_vpc.hello_world_vpc.id
  tags    = local.tags
  zone    = var.IBMCLOUD_ZONE

  # the user data field carries the encrypted contract, so all information visible at the hypervisor layer is encrypted
  user_data = hpcr_contract_encrypted.contract.rendered

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.hello_world_subnet.id
    security_groups = [ibm_is_security_group.hello_world_security_group.id]
  }

}

# attach a floating IP since we would like to access the embedded server via the internet
resource "ibm_is_floating_ip" "hello_world_floating_ip" {
  name   = format("%s-floating-ip", var.PREFIX)
  target = ibm_is_instance.hello_world_vsi.primary_network_interface[0].id
  tags   = local.tags
}

# log the floating IP for convenience
output "ip" {
  value = resource.ibm_is_floating_ip.hello_world_floating_ip.address
  description = "The public IP address of the VSI" 
}