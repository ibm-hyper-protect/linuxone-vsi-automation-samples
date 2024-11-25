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

variable "registry" {
  type        = string
  description = <<-DESC
                  Prefix of the container registry used to pull the image
                DESC
}

variable "pull_username" {
  type        = string
  description = <<-DESC
                  Username to pull from the above registry
                DESC
}

variable "pull_password" {
  type        = string
  description = <<-DESC
                  Password to pull from the above registry
                DESC
}
