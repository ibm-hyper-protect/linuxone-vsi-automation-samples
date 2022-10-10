
module "create_secret_manager" {

source = "./secret-manager"

region = var.region
ibmcloud_api_key = var.ibmcloud_api_key
cert_service_name = var.cert_service_name
}

module "publish_secrets" {

source = "./upload-secrets"

cert_service_name = var.cert_service_name
region = var.region
ibmcloud_api_key = var.ibmcloud_api_key
secrets_manager_guid = module.create_secret_manager.secrets_manager_guid
ca_cert_common_name = var.ca_cert_common_name
vpnserver_cert_common_name = var.vpnserver_cert_common_name
vpnclient_cert_common_name = var.vpnclient_cert_common_name
}

module "create_vpn_server" {

source = "./vpn-server"

cert_service_name = var.cert_service_name
region = var.region
ibmcloud_api_key = var.ibmcloud_api_key
zone = var.zone
vpc = var.vpc
subnetwork_name = var.subnetwork_name
total_ipv4_address_count = var.total_ipv4_address_count
security_group_name = var.security_group_name
vpn_port = var.vpn_port
client_ca_secret_id = module.publish_secrets.vpnclient_cert_id
vpnserver_secret_id = module.publish_secrets.vpnserver_cert_id
vpnserver_name = var.vpnserver_name
vpnserver_client_ip_pool = var.vpnserver_client_ip_pool
secrets_manager_guid = module.create_secret_manager.secrets_manager_guid
}
