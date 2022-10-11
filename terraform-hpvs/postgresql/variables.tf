variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
  default = "QlJsS2YUlLe-mZ7wRtmF3ntStXpMSOQx2cYERvsyiTGH"
#  default = "R3uNGdAO9oGwu96DKiCSUOYN8tg_9dSELAUefpmxnWct" 
}
variable "region" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb."
  default = "us-south"
}
variable "zone" {
  type        = string
  description = "Zone to deploy to, e.g. 2."
  default = "2"
}
variable "logdna_ingestion_key" {
  type        = string
  description = "Ingestion key for IBM Log Analysis instance. This can be obtained from 'Linux/Ubuntu' section of 'Logging resource' tab of IBM Log Analysis instance"
  default = "0a272ec8ea1997672ab4cf4833a58cc9"
}
variable "logdna_ingestion_hostname" {
  type        = string
  description = "rsyslog endpoint of IBM Log Analysis instance. Don't include the port. Example: syslog-a.<region>.logging.cloud.ibm.com"
  default = "syslog-a.us-south.logging.cloud.ibm.com"
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
# variable "image" {
#   default = "r134-622ffa9c-47e1-450f-9a02-4f0567b7139f"
# }
