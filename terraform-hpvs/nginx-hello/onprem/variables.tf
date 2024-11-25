variable "prefix" {
  type        = string
  default     = "hpcr-sample-nginx-hello"
  description = "Prefix to be attached to name of all generated resources"
}

variable "libvirt_host" {
  type        = string
  description = "Your libvirt host name."
}

variable "libvirt_user" {
  type        = string
  description = "User name authorized by a SSH server in your libvirt host."
}

variable "vsi_image" {
  type        = string
  description = "Path to your VSI image."
}

variable "hostname" {
  type        = string
  description = "Hostname of your virtual machine."
  default     = "hpcr-sample-nginx-hello"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to your SSH private key file"
  default     = "~/.ssh/id_rsa"
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
