variable "ibmcloud_api_key" {
  type = string
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
}

variable "region" {
  type = string
  default = "us-east"
}

variable "zone" {
  type = string
  default = "1"
}

variable "vpc" {
  type = string
  default = "terraform-test"
}

variable "subnetwork_name" {
  type = string
  default = "terraform-test"
}

variable "total_ipv4_address_count" {
    default = 256
}

variable "security_group_name" {
  type = string
  default = "terraform-test"
}

variable "vpn_port" {
  default = 1194
}

variable "secrets_manager_name" {
  type = string
  default = "terraform-test-secretsmanager"
}

variable "secrets_manager_group_name" {
  type = string
  default = "terraform-test-secretsmanager-group"
}

variable "vpnserver_name" {
  type = string
  default = "terraform-test-vpnserver"
}

variable "vpnserver_client_ip_pool" {
  type = string
  default = "10.2.0.0/16"
}

variable "ca_cert_common_name" {
  type = string
  default = "VPN Server CA"
}

variable "vpnserver_cert_common_name" {
  type = string
  default = "VPN Server"
}

variable "vpnclient_cert_common_name" {
  type = string
  default = "VPN Client"
}
