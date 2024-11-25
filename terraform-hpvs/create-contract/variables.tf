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
