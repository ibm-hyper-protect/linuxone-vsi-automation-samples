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
  default = "hpcr-rhvs"
}

variable "icic_domain_name" {
  type        = string
  default     = "default"
  description = "ICIC domain name"
}

variable "hpcr_rhvs_image_path" {
  type = string
  description = "Path to HPCR RHVS image"
}

variable "icic_network_name" {
  type = string
  description = "ICIC network name"
}

variable "icic_target_compute_node" {
  type = string
  description = "Target compute node"
}

variable "icl_iam_apikey" {
  type        = string
  sensitive   = true
  description = "IAM Key of IBM Cloud Logs"
}

variable "icl_hostname" {
  type        = string
  description = "Hostname of IBM Cloud Logs"
}

variable "hpcr_rhvs_image_cert_path" {
  type = string
  description = "Path to your HPCR image certificate"
}