variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
}

variable "region" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb."
}

variable "zone" {
  type        = string
  description = "Zone to deploy to, e.g. 2."
}

variable "logdna_ingestion_key" {
  type        = string
  description = "Ingestion key for logDNA."
  sensitive   = true
}

variable "logdna_ingestion_hostname" {
  type        = string
  description = "Ingestion hostname (just the name not the port)."
}

variable "prefix" {
  type        = string
  description = "Prefix for all generated resources. Make sure to have a custom image with that name."
  default     = "hpcr-sample-hello-world"
}

variable "profile" {
  type        = string
  description = "Profile used for the VSI, this has to be a secure execution profile in the format Xz2e-YxZ, e.g. bz2e-1x4."
  default     = "bz2e-1x4"
}
