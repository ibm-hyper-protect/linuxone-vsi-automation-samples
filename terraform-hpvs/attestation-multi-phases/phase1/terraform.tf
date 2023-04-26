terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.1"
    }
  }
}

# create a key pair for the purpose of encrypting the attestation record
resource "tls_private_key" "attestation_enc_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "attestation_pub_key" {
  content  = tls_private_key.attestation_enc_rsa_key.public_key_pem
  filename = "${path.module}/build/attestation.pub"
}

resource "local_file" "attestation_priv_key_pem" {
  content  = tls_private_key.attestation_enc_rsa_key.private_key_pem
  filename = "${path.module}/build/attestation.pem"
}
