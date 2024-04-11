terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.5.0"
    }
  }
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
        "logDNA" : {
          "ingestionKey" : var.logdna_ingestion_key,
          "hostname" : var.logdna_ingestion_hostname,
        },
      },
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    }
  })

  csrParams = {
    "country": var.hpcr_csr_country,
    "state":  var.hpcr_csr_state,
    "location":  var.hpcr_csr_location,
    "org":  var.hpcr_csr_org,
    "unit":  var.hpcr_csr_unit,
    "domain":  var.hpcr_csr_domain,
    "mail": var.hpcr_csr_mail
  }
}

resource "hpcr_contract_encrypted_contract_expiry" "contract" {
  contract = local.contract
  privkey= file(var.hpcr_private_key_path)
  expiry = var.hpcr_contract_expiry_days
  cakey = file(var.hpcr_ca_privatekey_path)
  cacert = file(var.hpcr_cacert_path)
  csrparams = local.csrParams
}

resource "local_file" "contract" {
  content  = hpcr_contract_encrypted_contract_expiry.contract.rendered
  filename = "${path.module}/build/contract.yml"
}