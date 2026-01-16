terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 1.2.0"
    }
  }
}

# archive of the folder containing the pod.yml file. This folder could create additional resources such as files 
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
        "logRouter" : {
          "hostname" : var.icl_hostname,
          "iamApiKey" : var.icl_iam_apikey,
        }
      },
      "auths" : {
        (var.registry) : {
          "username" : var.pull_username,
          "password" : var.pull_password
        }
      },
      "env" : {
        "REGISTRY" : var.registry,
        "CERT": var.server_cert,
        "KEY": var.server_key
      }
    },
    "workload" : {
      "type" : "workload",
      "play" : {
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
}

resource "local_file" "contract" {
  content  = hpcr_contract_encrypted.contract.rendered
  filename = "${path.module}/build/contract.yml"
}