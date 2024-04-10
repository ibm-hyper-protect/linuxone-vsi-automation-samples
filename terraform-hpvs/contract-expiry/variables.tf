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

variable "logdna_ingestion_key" {
  type        = string
  sensitive   = true
  description = <<-DESC
                  Ingestion key for IBM Log Analysis instance. This can be 
                  obtained from "Linux/Ubuntu" section of "Logging resource" 
                  tab of IBM Log Analysis instance
                DESC
}

variable "logdna_ingestion_hostname" {
  type        = string
  description = <<-DESC
                  rsyslog endpoint of IBM Log Analysis instance. 
                  Don't include the port. Example: 
                  syslog-a.<log_region>.logging.cloud.ibm.com
                  log_region is the region where IBM Log Analysis is deployed
                DESC
}