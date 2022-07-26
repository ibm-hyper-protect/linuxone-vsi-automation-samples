variable "IBMCLOUD_ZONE" {
  type        = string
  description = "Zone to deploy to, e.g. eu-gb-3."
}

variable "IBMCLOUD_REGION" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb."
}

variable "LOGDNA_INGESTION_KEY" {
  type        = string
  description = "Ingestion key for logDNA."
  sensitive   = true
}

variable "LOGDNA_INGESTION_HOSTNAME" {
  type        = string
  description = "Ingestion hostname (just the name the port)."
}

variable "PREFIX" {
  type        = string
  description = "Prefix for all generated resources. Make sure to have a custom image with that name."
  default     = "hpcr-sample-hello-world"
}
