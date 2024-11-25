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
