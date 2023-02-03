locals {
  full_vpnclient_cert_common_name = "${var.region} ${var.vpnclient_cert_common_name}"
  full_ca_cert_common_name = "${var.region} ${var.ca_cert_common_name}"
  full_vpnserver_cert_common_name = "${var.region} ${var.vpnserver_cert_common_name}"
  rest_endpoint = "https://${var.secrets_manager_guid}.${var.region}.secrets-manager.appdomain.cloud"
  full_zone = "${var.region}-${var.zone}"
  vpn_protocol = "udp"
}