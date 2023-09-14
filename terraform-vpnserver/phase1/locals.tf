locals {
  full_vpnclient_cert_common_name = "${var.region} ${var.vpnclient_cert_common_name}"
  full_ca_cert_common_name = "${var.region} ${var.ca_cert_common_name}"
  full_vpnserver_cert_common_name = "${var.region} ${var.vpnserver_cert_common_name}"
  full_zone = "${var.region}-${var.zone}"
  vpn_protocol = "udp"
}
