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
