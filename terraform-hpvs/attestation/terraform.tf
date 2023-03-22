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
resource "ibm_is_vpc" "attestation_vpc" {
  name = format("%s-vpc", var.prefix)
  tags = local.tags
}

# the security group
resource "ibm_is_security_group" "attestation_security_group" {
  name = format("%s-security-group", var.prefix)
  vpc  = ibm_is_vpc.attestation_vpc.id
  tags = local.tags
}

# rule that allows the VSI to make outbound connections, this is required
# to connect to the logDNA instance as well as to docker to pull the image
resource "ibm_is_security_group_rule" "attestation_outbound" {
  group     = ibm_is_security_group.attestation_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# the subnet
resource "ibm_is_subnet" "attestation_subnet" {
  name                     = format("%s-subnet", var.prefix)
  vpc                      = ibm_is_vpc.attestation_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone}"
  tags                     = local.tags
}

# we use a gateway to allow the VSI to connect to the internet to logDNA
# and docker. Without a gateway the VSI would need a floating IP. Without
# either the VSI will not be able to connect to the internet despite
# an outbound rule
resource "ibm_is_public_gateway" "attestation_gateway" {
  name = format("%s-gateway", var.prefix)
  vpc  = ibm_is_vpc.attestation_vpc.id
  zone = "${var.region}-${var.zone}"
  tags = local.tags
}

# attach the gateway to the subnet
resource "ibm_is_subnet_public_gateway_attachment" "attestation_gateway_attachment" {
  subnet         = ibm_is_subnet.attestation_subnet.id
  public_gateway = ibm_is_public_gateway.attestation_gateway.id
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
          "ingestionKey" : var.logdna_ingestion_key,
          "hostname" : var.logdna_ingestion_hostname,
        }
      }
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      },
      "auths" : {
        (var.registry) : {
          "username" : var.pull_username,
          "password" : var.pull_password
        }
      },
      "env" : {
        "REGISTRY" : var.registry
      }
    },
    "attestationPublicKey": tls_private_key.attestation_enc_rsa_key.public_key_pem
  })
}

# create a key pair for the purpose of encrypting the attestation record
resource "tls_private_key" "attestation_enc_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create a random key pair, because for formal reasons we need to pass an SSH key into the VSI. It will not be used, that's why
# it can be random
resource "tls_private_key" "attestation_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# we only need this because VPC expects this
resource "ibm_is_ssh_key" "attestation_sshkey" {
  name       = format("%s-key", var.prefix)
  public_key = tls_private_key.attestation_rsa_key.public_key_openssh
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

# In this step we encrypt the fields of the contract and sign the env and workload field. The certificate to execute the 
# encryption it built into the provider and matches the latest HPCR image. If required it can be overridden. 
# We use a temporary, random keypair to execute the signature. This could also be overriden. 
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
}

# construct the VSI
resource "ibm_is_instance" "attestation_vsi" {
  name    = format("%s-vsi", var.prefix)
  image   = data.hpcr_image.hyper_protect_image.image
  profile = var.profile
  keys    = [ibm_is_ssh_key.attestation_sshkey.id]
  vpc     = ibm_is_vpc.attestation_vpc.id
  tags    = local.tags
  zone    = "${var.region}-${var.zone}"

  # the user data field carries the encrypted contract, so all information visible at the hypervisor layer is encrypted
  user_data = hpcr_contract_encrypted.contract.rendered

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.attestation_subnet.id
    security_groups = [ibm_is_security_group.attestation_security_group.id]
  }

}

resource "local_file" "contract" {
  content  = hpcr_contract_encrypted.contract.rendered
  filename = "${path.module}/build/contract.yml"
}

resource "local_file" "attestation_pub_key" {
  content  = tls_private_key.attestation_enc_rsa_key.public_key_pem
  filename = "${path.module}/build/attestation.pub"
}

resource "local_file" "attestation_priv_key" {
  content  = tls_private_key.attestation_enc_rsa_key.private_key_pem_pkcs8
  filename = "${path.module}/build/attestation"
}
