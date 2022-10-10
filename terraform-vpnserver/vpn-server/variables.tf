variable "region" {
  default = "jp-tok"
}

variable "zone" {
  default = "1"
}

variable "vpc" {
  default = "terraform-test"
}

variable "subnetwork_name" {
  default = "terraform-test"
}

variable "total_ipv4_address_count" {
    default = 256
}

variable "security_group_name" {
  default = "terraform-test"
}

variable "vpn_port" {
  default = 1194
}

variable "cert_service_name" {
  default = "SecretsManager-vpnserver"
}

variable "cert_service_region" {
  default = "us-south"
}

variable "vpnserver_secret_id" {
  type = string
}

variable "client_ca_secret_id" {
  type = string
}

variable "vpnserver_name" {
  type = string
  default = "terraform-test-vpnserver"
}

variable "vpnserver_client_ip_pool" {
  type = string
  default = "10.2.0.0/16"
}

variable "secrets_manager_guid" {
    type = string
}
