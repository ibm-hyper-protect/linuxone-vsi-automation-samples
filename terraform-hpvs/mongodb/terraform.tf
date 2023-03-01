terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.4"
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
  for_each                 = toset(["1", "2", "3"])
  name                     = format("%s-subnet-%s", var.prefix, each.key)
  vpc                      = ibm_is_vpc.mongodb_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${each.key}"
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
        "MONGO_REPLICA_SET_NAME" : var.mongo_replica_set_name,
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

# locate all public image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"
}

# locate the latest hyper protect image
data "hpcr_image" "hyper_protect_image" {
  images = jsonencode(data.ibm_is_images.hyper_protect_images.images)
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
  for_each = toset(["1", "2", "3"])
  name     = format("%s-vsi-%s", var.prefix, each.key)
  image    = data.hpcr_image.hyper_protect_image.image
  profile  = var.profile
  keys     = [ibm_is_ssh_key.mongodb_sshkey.id]
  vpc      = ibm_is_vpc.mongodb_vpc.id
  tags     = local.tags
  zone     = "${var.region}-${each.key}"

  # user data field carries the encrypted contract, so all information visible at
  # the hypervisor layer is encrypted
  user_data = hpcr_contract_encrypted.contract.rendered

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.mongodb_subnet[each.key].id
    security_groups = [ibm_is_security_group.mongodb_security_group.id]
  }
}

# Attach a floating IP since VSI needs to push logs to logDNA server
resource "ibm_is_floating_ip" "mongodb_floating_ip" {
  for_each = toset(["1", "2", "3"])
  name     = format("%s-floating-ip-%s", var.prefix, each.key)
  target   = ibm_is_instance.mongodb_vsi[each.key].primary_network_interface[0].id
  tags     = local.tags
}

# Log the floating IP for convenience
output "ip_vsi_1" {
  value       = resource.ibm_is_floating_ip.mongodb_floating_ip[1].address
  description = "The public IP address of the VSI_1"
}

# Log the floating IP for convenience
output "ip_vsi_2" {
  value       = resource.ibm_is_floating_ip.mongodb_floating_ip[2].address
  description = "The public IP address of the VSI_2"
}

# Log the floating IP for convenience
output "ip_vsi_3" {
  value       = resource.ibm_is_floating_ip.mongodb_floating_ip[3].address
  description = "The public IP address of the VSI_3"
}
