terraform {
  required_providers {
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
# make sure to target the correct region and zone
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  zone             = "${var.region}-${var.zone}"
}
locals {
  # some reusable tags that identify the resources created by his sample
  tags = ["zvsi", "sample", var.prefix]
}
# the VPC
resource "ibm_is_vpc" "postgres_vpc" {
  name = format("%s-vpc", var.prefix)
  tags = local.tags
}
# the security group
resource "ibm_is_security_group" "postgres_security_group" {
  name = format("%s-security-group", var.prefix)
  vpc  = ibm_is_vpc.postgres_vpc.id
  tags = local.tags
}
resource "ibm_is_security_group_rule" "postgres_outbound" {
  group     = ibm_is_security_group.postgres_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
# Rule that allows inbound traffic to the postgres server
# to connect to the logDNA instance as well as to docker to pull the image
resource "ibm_is_security_group_rule" "postgres_inbound" {
  group     = ibm_is_security_group.postgres_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 5432
    port_max = 5432
  }
}
# the subnet
resource "ibm_is_subnet" "postgres_subnet" {
  name                     = format("%s-subnet", var.prefix)
  vpc                      = ibm_is_vpc.postgres_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone}"
  tags                     = local.tags
}
resource "hpcr_tgz" "contract" {
  folder = "compose"
}
locals {
  # contract in clear text
  contract = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logRouter" : {
          "hostname" : var.icl_hostname,
          "iamApiKey" : var.icl_iam_apikey,
        }
      },
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    }
  })
}
resource "ibm_is_ssh_key" "postgres_sshkey" {
  name       = "key-terr"
  public_key = file(var.ssh_public_key)
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
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
}
# construct the VSI
resource "ibm_is_instance" "postgres_vsi" {
  name      = format("%s-vsi", var.prefix)
  image     = data.hpcr_image.hyper_protect_image.image
  profile   = var.profile
  keys      = ["${ibm_is_ssh_key.postgres_sshkey.id}"]
  vpc       = ibm_is_vpc.postgres_vpc.id
  tags      = local.tags
  zone      = "${var.region}-${var.zone}"
  user_data = hpcr_contract_encrypted.contract.rendered
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.postgres_subnet.id
    security_groups = [ibm_is_security_group.postgres_security_group.id]
  }
}
resource "ibm_is_floating_ip" "postgres_fip" {
  name   = format("%s-vsi", var.prefix)
  target = ibm_is_instance.postgres_vsi.primary_network_interface[0].id
}
output "sshcommand" {
  value       = resource.ibm_is_floating_ip.postgres_fip.address
  description = "The public IP address of the VSI"
}