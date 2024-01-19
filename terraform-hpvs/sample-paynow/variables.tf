variable "logdna_ingestion_key" {
  type        = string
  sensitive   = true
  description = <<-DESC
                  Ingestion key for IBM Log Analysis instance. This can be 
                  obtained from "Linux/Ubuntu" section of "Logging resource" 
                  tab of IBM Log Analysis instance
                DESC
}

variable "logdna_ingestion_hostname" {
  type        = string
  description = <<-DESC
                  rsyslog endpoint of IBM Log Analysis instance. 
                  Don't include the port. Example: 
                  syslog-a.<log_region>.logging.cloud.ibm.com
                  log_region is the region where IBM Log Analysis is deployed
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

variable "server_cert" {
  type        = string
  description = <<-DESC
                  Base64-encoded server certificate
                DESC
}

variable "server_key" {
  type        = string
  description = <<-DESC
                  Base64-encoded server key
                DESC
}
