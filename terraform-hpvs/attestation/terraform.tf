terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.6"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.1"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
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

resource "random_uuid" "attestation_uuid" {
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

# locate the COS instance
data "ibm_resource_instance" "attestation_cos_instance" {
  name     = "secure-execution"
  location = "global"
  service  = "cloud-object-storage"
}

# create a bucket we use to upload the attestation record
resource "ibm_cos_bucket" "attestation_cos_bucket" {
  resource_instance_id = data.ibm_resource_instance.attestation_cos_instance.id
  bucket_name          = format("%s-bucket", var.prefix)
  region_location      = var.region
  storage_class        = "standard"
}

# get the authentication token we use to upload the attestation record
data "ibm_iam_auth_token" "attestation_auth_token" {
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
  # URL to the attestation object
  attestationKey = format("%s.enc", random_uuid.attestation_uuid.result)
  attestationURL = format("https://%s/%s/%s", ibm_cos_bucket.attestation_cos_bucket.s3_endpoint_public, urlencode(ibm_cos_bucket.attestation_cos_bucket.bucket_name), urlencode(local.attestationKey))
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
      "env" : {
        "AUTHORIZATION" : data.ibm_iam_auth_token.attestation_auth_token.iam_access_token,
        "S3_URL" : local.attestationURL
      }
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    },
    "attestationPublicKey" : tls_private_key.attestation_enc_rsa_key.public_key_pem
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


# huhh, this is not nice
resource "time_sleep" "wait_for_attestation" {
  depends_on = [
    ibm_is_instance.attestation_vsi    
  ]

  create_duration = "45s"
}

data "ibm_cos_bucket_object" "attestation_record" {
  bucket_crn      = ibm_cos_bucket.attestation_cos_bucket.crn
  bucket_location = ibm_cos_bucket.attestation_cos_bucket.region_location
  key             = local.attestationKey
  endpoint_type   = "public"
  depends_on = [
    time_sleep.wait_for_attestation
  ]
}

data "hpcr_attestation" "attestation_decoded" {
  attestation = data.ibm_cos_bucket_object.attestation_record.body
  privkey = tls_private_key.attestation_enc_rsa_key.private_key_pem  
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

resource "local_file" "attestation_record" {
  content  = jsonencode(data.hpcr_attestation.attestation_decoded.checksums)
  filename = "${path.module}/build/se-checksums.json"
}