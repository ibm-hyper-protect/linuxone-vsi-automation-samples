variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
  default     = "*********"
}

variable "region" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb."
  default     = "us-south"
}

variable "zone_master" {
  type        = string
  description = "Zone to deploy master to, e.g. 1."
  default     = "1"
}

variable "zone_slave_1" {
  type        = string
  description = "Zone to deploy slave_1 to, e.g. 2."
  default     = "2"
}

variable "zone_slave_2" {
  type        = string
  description = "Zone to deploy slave_2 to, e.g. 3."
  default     = "3"
}

variable "icl_hostname" {
  type        = string
  sensitive   = true
  description = <<-DESC
                  Host of IBM Cloud Logs. This can be
                  obtained from cloud logs tab under Logging instances
                DESC
}

variable "icl_iam_apikey" {
  type        = string
  description = <<-DESC
                  This can be obtained from Access(IAM) under Manage
                DESC
}

variable "prefix" {
  type        = string
  description = "Prefix for all generated resources. Make sure to have a custom image with that name."
  default     = "zvsi-sample-postgres"
}

variable "profile" {
  type        = string
  description = "Profile used for the VSI, this is a profile for normal zlinux VSI , the profile in the format Xz2-YxZ, e.g. bz2-1x4."
  default     = "bz2e-1x4"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
