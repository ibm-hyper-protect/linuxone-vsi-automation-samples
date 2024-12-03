variable "hpcr_private_key_path" {
  type = string
  description = "Path of private key for signature"
}

variable "hpcr_ca_privatekey_path" {
  type = string
  description = "Path to CA private key"
}

variable "hpcr_cacert_path" {
  type = string
  description = "Path to CA certificate"
}

variable "hpcr_csr_country" {
  type = string
  description = "HPCR CSR country"
}

variable "hpcr_csr_state" {
  type = string
  description = "HPCR CSR state"
}

variable "hpcr_csr_location" {
  type = string
  description = "HPCR CSR location"
}

variable "hpcr_csr_org" {
  type = string
  description = "HPCR CSR org"
}

variable "hpcr_csr_unit" {
  type = string
  description = "HPCR CSR unit"
}

variable "hpcr_csr_domain" {
  type = string
  description = "HPCR CSR domain"
}

variable "hpcr_csr_mail" {
  type = string
  description = "HPCR CSR Mail ID"
}

variable "hpcr_contract_expiry_days" {
  type = number
  description = "Number of days for contract to expire"
}

variable "icl_hostname" {
  type        = string
  description = <<-DESC
                  Host of IBM Cloud Logs. This can be
                  obtained from cloud logs tab under Logging instances
                DESC
}

variable "icl_iam_apikey" {
  type        = string
  sensitive   = true
  description = <<-DESC
                  This can be obtained from Access(IAM) under Manage
                DESC
}