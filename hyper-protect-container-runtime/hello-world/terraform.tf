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
  tags = ["hpcr", "sample", var.PREFIX]
}

# the VPC
resource "ibm_is_vpc" "hello_world_vpc" {
  name = format("%s-vpc", var.PREFIX)
  tags = local.tags
}

resource "ibm_is_security_group" "hello_world_security_group" {
  name = format("%s-security-group", var.PREFIX)
  vpc  = ibm_is_vpc.hello_world_vpc.id
  tags = local.tags
}

resource "ibm_is_security_group_rule" "hello_world_outbound" {
  group     = ibm_is_security_group.hello_world_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_subnet" "hello_world_subnet" {
  name = format("%s-subnet", var.PREFIX)
  vpc  = ibm_is_vpc.hello_world_vpc.id
  zone = var.IBMCLOUD_ZONE
  tags = local.tags
}

resource "ibm_is_public_gateway" "hello_world_gateway" {
  name = format("%s-gateway", var.PREFIX)
  vpc  = ibm_is_vpc.hello_world_vpc.id
  zone = var.IBMCLOUD_ZONE
  tags = local.tags
}

resource "ibm_is_subnet_public_gateway_attachment" "hello_world_gateway_attachment" {
  subnet         = ibm_is_subnet.hello_world_subnet.id
  public_gateway = ibm_is_public_gateway.hello_world_gateway.id
}

# archive of the folder containing docker-compose
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

data "ibm_is_image" "hyper_protect_image" {
  name = "ibm-hyper-protect-container-runtime-1-0-s390x-3"
}

# encrypted and signed contract
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
}

# construct the VSI
resource "ibm_is_instance" "hello_world_vsi" {
  name    = format("%s-vsi", var.PREFIX)
  image   = data.ibm_is_image.hyper_protect_image.id
  profile = "bz2e-1x4"
  keys    = [ibm_is_ssh_key.hello_world_sshkey.id]
  vpc     = ibm_is_vpc.hello_world_vpc.id
  tags    = local.tags
  zone    = var.IBMCLOUD_ZONE

  user_data = hpcr_contract_encrypted.contract.rendered

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.hello_world_subnet.id
    security_groups = [ibm_is_security_group.hello_world_security_group.id]
  }

}


output "user_data" {
  value = hpcr_contract_encrypted.contract.rendered
}