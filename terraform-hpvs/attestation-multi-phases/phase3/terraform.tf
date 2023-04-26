terraform {
  required_providers {
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.6"
    }
  }
}

data "http" "attestation_record" {
  url = var.attestation_record_url

  request_headers = {
    Accept = "*/*"
  }
  insecure = true
}

data "hpcr_attestation" "attestation_decoded" {
  attestation =  data.http.attestation_record.response_body
  privkey = "${file("input/attestation.pem")}"
}

resource "local_file" "attestation_record" {
  content  = jsonencode(data.hpcr_attestation.attestation_decoded.checksums)
  filename = "${path.module}/build/se-checksums.json"

  lifecycle {
    postcondition {
      condition     = data.hpcr_attestation.attestation_decoded.checksums["cidata/user-data"] == filesha256("input/contract.yml")
      error_message = "Cannot validate the attestation record: The checksum of contract.yml does not match the checksum for cidata/user-data in the attestation record."
    }
  }
}

