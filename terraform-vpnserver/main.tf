
module "phase1" {

source = "./phase1"

region = var.region
ibmcloud_api_key = var.ibmcloud_api_key
cert_service_name = var.cert_service_name
vpc = var.vpc
ca_cert_common_name = var.ca_cert_common_name
vpnserver_cert_common_name = var.vpnserver_cert_common_name
vpnclient_cert_common_name = var.vpnclient_cert_common_name
zone = var.zone
subnetwork_name = var.subnetwork_name
total_ipv4_address_count = var.total_ipv4_address_count
security_group_name = var.security_group_name
vpn_port = var.vpn_port
vpnserver_name = var.vpnserver_name
vpnserver_client_ip_pool = var.vpnserver_client_ip_pool
}

resource "local_file" "ovpn" {
    filename = "${var.vpc}-${var.region}.ovpn"
    content = "client\ndev tun\nproto ${module.phase1.vpn_protocol}\nport ${var.vpn_port}\nremote ${module.phase1.vpn_hostname}\nresolv-retry infinite\nremote-cert-tls server\nnobind\n\nauth SHA256\ncipher AES-256-GCM\nverb 3\nreneg-sec 0\n<ca>\n${module.phase1.vpn_ca_cert_content}</ca>\n<cert>\n${module.phase1.vpn_client_cert_content}</cert>\n<key>\n${module.phase1.vpn_client_key_content}</key>"
}