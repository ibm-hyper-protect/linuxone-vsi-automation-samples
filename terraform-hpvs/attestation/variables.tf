variable "ibmcloud_api_key" {
  description = <<-DESC
                  Enter your IBM Cloud API Key, you can get your IBM Cloud API key using:
                   https://cloud.ibm.com/iam#/apikeys
                DESC
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to deploy to, e.g. eu-gb"

  validation {
    condition = (var.region == "eu-gb" ||
      var.region == "br-sao" ||
      var.region == "ca-tor" ||
      var.region == "jp-tok" ||
    var.region == "us-east")
    error_message = "Value of region must be one of eu-gb/br-sao/ca-tor/jp-tok/us-east."
  }
}

variable "zone" {
  type        = string
  default     = "2"
  description = "Zone to deploy to, e.g. 2."

  validation {
    condition = (var.zone == "1" ||
      var.zone == "2" ||
    var.zone == "3")
    error_message = "Value of zone must be one of 1/2/3."
  }
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

variable "prefix" {
  type        = string
  default     = "hpcr-sample-attestation"
  description = "Prefix to be attached to name of all generated resources"
}

variable "profile" {
  type        = string
  default     = "bz2e-1x4"
  description = <<-DESC
                  Profile used for the VSI. This has to be a secure execution 
                  profile in the format Xz2e-YxZ, e.g. bz2e-1x4
                DESC
}
