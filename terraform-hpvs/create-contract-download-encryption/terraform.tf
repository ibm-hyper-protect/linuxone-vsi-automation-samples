terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.12"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.37.1"
    }
  }
}

# make sure to target the correct region and zone
provider "ibm" {
  region           = var.region
  zone             = "${var.region}-${var.zone}"
  ibmcloud_api_key = var.ibmcloud_api_key
}

# archive of the folder containing docker-compose file. This folder could create additional resources such as files 
# to be mounted into containers, environment files etc. This is why all of these files get bundled in a tgz file (base64 encoded)
resource "hpcr_tgz" "contract" {
  folder = "compose"
}

# locate all public image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"
}

# locate the latest hyper protect image from the list of available images
data "hpcr_image" "hyper_protect_image" {
  images = jsonencode(data.ibm_is_images.hyper_protect_images.images)
}

# load the certificate for the selected image versions
# in this case we only download the certificate for the selected version of the image
data "hpcr_encryption_certs" "enc_certs" {
  versions = [data.hpcr_image.hyper_protect_image.version]
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
      }
    }
  })
}

# In this step we encrypt the fields of the contract and sign the env and workload field. The certificate to execute the 
# encryption it built into the provider and matches the latest HPCR image. If required it can be overridden. 
# We use a temporary, random keypair to execute the signature. This could also be overriden. 
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
  cert     = data.hpcr_encryption_certs.enc_certs.certs[data.hpcr_image.hyper_protect_image.version]
}

resource "local_file" "contract" {
  content  = hpcr_contract_encrypted.contract.rendered
  filename = "${path.module}/build/contract.yml"
}
