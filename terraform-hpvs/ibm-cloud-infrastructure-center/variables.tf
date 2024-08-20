variable "icic_username" {
  type        = string
  default     = "root"
  description = "Username to access ICIC"
}

variable "icic_password" {
  type        = string
  description = "Password to access ICIC"
}

variable "icic_tenant_name" {
  type        = string
  default     = "ibm-default"
  description = "Tenant name for ICIC account"
}

variable "icic_auth_url" {
  type        = string
  description = "ICIC authentication URL"
}

variable "prefix" {
  type = string
  description = "name prefix"
  default = "hpvs-icic"
}

variable "icic_domain_name" {
  type        = string
  default     = "default"
  description = "ICIC domain name"
}

variable "hpvs_image_path" {
  type = string
  description = "Path to HPVS image"
}

variable "icic_network_name" {
  type = string
  description = "ICIC network name"
}

variable "icic_target_compute_node" {
  type = string
  description = "Target compute node"
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

variable "hpcr_image_cert_path" {
  type = string
  description = "Path to your HPCR image certificate"
}