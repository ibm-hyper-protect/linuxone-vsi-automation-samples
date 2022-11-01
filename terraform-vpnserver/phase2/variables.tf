variable "cert_service_name" {
  type = string
}

variable "region" {
  type = string
}

variable "secrets_manager_guid" {
  type = string
}

variable "ca_cert_common_name" {
  type = string
}

variable "vpnserver_cert_common_name" {
  type = string
}

variable "vpnclient_cert_common_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "total_ipv4_address_count" {
  type = number
}

variable "security_group_name" {
  type = string
}

variable "vpn_port" {
  type = number
}

variable "vpnserver_name" {
  type = string
}

variable "vpnserver_client_ip_pool" {
  type = string
}

variable "vpc_guid" {
  type = string
}

variable "vpc_address_prefixes_map" {
  type = map
}