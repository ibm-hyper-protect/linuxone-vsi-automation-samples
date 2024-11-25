variable "icl_iam_apikey" {
  type        = string
  description = "IAM Key of IBM Cloud Logs"
}

variable "icl_hostname" {
  type        = string
  sensitive   = true
  description = "Hostname of IBM Cloud Logs Instance"
}