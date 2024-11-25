variable "region" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb."
}

variable "zone" {
  type        = string
  description = "Zone to deploy to, e.g. 2."
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
  default     = "log-encryption"
}

variable "profile" {
  type        = string
  description = "Profile used for the VSI, this has to be a secure execution profile in the format Xz2e-YxZ, e.g. bz2e-1x4."
  default     = "bz2e-1x4"
}
