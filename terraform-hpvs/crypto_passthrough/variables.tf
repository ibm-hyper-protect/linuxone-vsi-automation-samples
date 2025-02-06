variable "prefix" {
  type        = string
  default     = "crypto_passthrough"
  description = "Prefix to be attached to name of all generated resources"
}

variable "libvirt_host" {
  type        = string
  description = "Your libvirt host name."
}

variable "libvirt_port" {
  type = string
  default = "22"
  description = "Your libvirt host port."  
}

variable "libvirt_user" {
  type        = string
  description = "User name authorized by a SSH server in your libvirt host."
}

variable "vsi_image_path" {
  type        = string
  description = "Path to your VSI image."
}

variable "hostname" {
  type        = string
  description = "Hostname of your virtual machine."
  default     = "hpvs_onprem_cryptopassthrough"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to your SSH private key file"
  default     = "~/.ssh/id_rsa"
}

variable "storage_pool_path" {
  type        = string
  description = "Path to the desired directory"
  default     = "/var/lib/libvirt/hpvs"
}

variable "hpcr_image_cert_path" {
  type        = string
  description = "Path to your HPCR image certificate"
}

variable "icl_iam_apikey" {
  type        = string
  sensitive   = true
  description = "IAM Key of IBM Cloud Logs"
}

variable "icl_hostname" {
  type        = string
  description = "Hostname of IBM Cloud Logs Instance"
}

variable "crypto_domain_id" {
  type = string
  description = "Domain ID of crypto card"
}

variable "crypto_secret" {
  type = string
  description = "secret for crypto card"
}

variable "crypto_mkvp" {
  type = string
  description = "MKVP of crypto card"
}

variable "hkd_path" {
  type = string
  description = "HKD path"
}

variable "crypto_card_uuid" {
  type = string
  description = "UUID of the crypto card"
}