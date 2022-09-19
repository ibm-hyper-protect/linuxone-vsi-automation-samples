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

# Make sure to target the correct region and zone
provider "ibm" {
  region           = var.region
  zone             = "${var.region}-${var.zone}"
  ibmcloud_api_key = var.ibmcloud_api_key
}

locals {
  # some reusable tags that identify the resources created 
  tags = ["mongodb", var.prefix]
}

# The VPC
resource "ibm_is_vpc" "mongodb_vpc" {
  name = format("%s-vpc", var.prefix)
  tags = local.tags
}

# The security group
resource "ibm_is_security_group" "mongodb_security_group" {
  name = format("%s-security-group", var.prefix)
  vpc  = ibm_is_vpc.mongodb_vpc.id
  tags = local.tags
}

# Rule that allows the VSI to make outbound connections, this is required
# to connect to the logDNA instance as well as to docker to pull the image
resource "ibm_is_security_group_rule" "mongodb_outbound" {
  group     = ibm_is_security_group.mongodb_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Rule that allows inbound traffic to the mongo server
resource "ibm_is_security_group_rule" "mongodb_inbound" {
  group     = ibm_is_security_group.mongodb_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 27017
    port_max = 27017
  }
}

# The subnet
resource "ibm_is_subnet" "mongodb_subnet" {
  name                     = format("%s-subnet", var.prefix)
  vpc                      = ibm_is_vpc.mongodb_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone}"
  tags                     = local.tags
}

# Archive of the folder containing docker-compose file. This folder could create
# additional resources such as files to be mounted into containers, environment
# files etc. This is why all of these files get bundled in a tgz file (base64 encoded)
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
          "ingestionKey" : var.logdna_ingestion_key,
          "hostname" : var.logdna_ingestion_hostname,
        }
      },
      "env" : {
          "MONGO_INITDB_ROOT_USERNAME" : var.mongo_user,
          "MONGO_INITDB_ROOT_PASSWORD" : var.mongo_password,
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

# Create a random key pair. For formal reasons, we need to pass an SSH key
# into the VSI. It will not be used, that's why it can be random
resource "tls_private_key" "mongodb_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# We only need this because VPC expects this
resource "ibm_is_ssh_key" "mongodb_sshkey" {
  name       = format("%s-key", var.prefix)
  public_key = tls_private_key.mongodb_rsa_key.public_key_openssh
  tags       = local.tags
}

# Locate the latest hyper protect image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"

}

locals {
  # Filter the available images down to the hyper protect one
  hyper_protect_image = one(toset([for each in data.ibm_is_images.hyper_protect_images.images : each if each.os == "hyper-protect-1-0-s390x" && each.architecture == "s390x"]))
}

# In this step, we encrypt the fields of the contract and sign the env and workload field.
# The certificate to execute the encryption is built into the provider and matches the
# latest hyper protect image. If required, it can be overridden. 
# We use a temporary, random keypair to execute the signature. This could also be overriden. 
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
}

# Construct the VSI
resource "ibm_is_instance" "mongodb_vsi" {
  name    = format("%s-vsi", var.prefix)
  image   = local.hyper_protect_image.id
  profile = var.profile
  keys    = [ibm_is_ssh_key.mongodb_sshkey.id]
  vpc     = ibm_is_vpc.mongodb_vpc.id
  tags    = local.tags
  zone    = "${var.region}-${var.zone}"

  # user data field carries the encrypted contract, so all information visible at
  # the hypervisor layer is encrypted
  user_data = hpcr_contract_encrypted.contract.rendered

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.mongodb_subnet.id
    security_groups = [ibm_is_security_group.mongodb_security_group.id]
  }
}

# Attach a floating IP since VSI needs to push logs to logDNA server
resource "ibm_is_floating_ip" "mongodb_floating_ip" {
  name   = format("%s-floating-ip", var.prefix)
  target = ibm_is_instance.mongodb_vsi.primary_network_interface[0].id
  tags   = local.tags
}

# Log the floating IP for convenience
output "ip" {
  value = resource.ibm_is_floating_ip.mongodb_floating_ip.address
  description = "The public IP address of the VSI" 
}
