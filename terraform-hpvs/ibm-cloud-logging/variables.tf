variable "icl_iam_apikey" {
  type        = string
  sensitive   = true
  description = "IAM Key of IBM Cloud Logs"
}

variable "icl_hostname" {
  type        = string
  description = "Hostname of IBM Cloud Logs Instance"
}