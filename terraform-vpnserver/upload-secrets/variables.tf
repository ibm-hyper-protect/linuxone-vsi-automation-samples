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
