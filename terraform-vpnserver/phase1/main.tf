

resource "ibm_resource_instance" "secrets_mgr" {
  name     = var.cert_service_name
  location = var.region
  plan     = "trial"
  service  = "secrets-manager"
}

# Create a VPC
resource "ibm_is_vpc" "vpc" {
  name = var.vpc
}

data "ibm_is_vpc_address_prefixes" "vpc_addresses" {
  vpc  = ibm_is_vpc.vpc.id
}

output "secrets_manager_guid" {
  value = ibm_resource_instance.secrets_mgr.guid
}

output "vpc_guid" {
  value = ibm_is_vpc.vpc.id
}

locals{
vpc_address_prefixes_map = tomap({ for addrs in data.ibm_is_vpc_address_prefixes.vpc_addresses.address_prefixes: addrs.id => addrs })
}

resource "ibm_sm_secret_group" "sm_secret_group"{
  instance_id   = ibm_resource_instance.secrets_mgr.guid
  region        = var.region
  name        = "${var.cert_service_name}-secret-group"
  description = "Secrets group for ${var.cert_service_name}"
}


# Create private key for certificate authority 
resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

# Create private key for vpn server 
resource "tls_private_key" "vpnserver_private_key" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

# Create private key for vpn client 
resource "tls_private_key" "vpnclient_private_key" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

# Create CA certificate
resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_private_key.private_key_pem
  allowed_uses = [
    "cert_signing"
  ]
  validity_period_hours = 8766*5  # 5 years
  subject {
    common_name = local.full_ca_cert_common_name
  }
  is_ca_certificate = true
}

# Create certificate request for VPN Server 
resource "tls_cert_request" "vpnserver_csr" {
  private_key_pem = tls_private_key.vpnserver_private_key.private_key_pem

  subject{
    common_name = local.full_vpnserver_cert_common_name
  }
  
}

# Create certificate request for VPN Client 
resource "tls_cert_request" "vpnclient_csr" {
  private_key_pem = tls_private_key.vpnclient_private_key.private_key_pem

  subject{
    common_name = local.full_vpnclient_cert_common_name
  }
  
}

# Sign the certificate request for VPN Server 
resource "tls_locally_signed_cert" "vpnserver_cert" {
  cert_request_pem = tls_cert_request.vpnserver_csr.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca_cert.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8766*1  # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Sign the certificate request for VPN client 
resource "tls_locally_signed_cert" "vpnclient_cert" {
  cert_request_pem = tls_cert_request.vpnclient_csr.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca_cert.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8766*1  # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "ibm_sm_imported_certificate" "vpn_ca_cert" {
  instance_id   = ibm_resource_instance.secrets_mgr.guid
  region        = var.region
  name             = "${var.region}-imported-ca-cert"
  description = "${local.full_ca_cert_common_name}"
  secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
  certificate  = tls_self_signed_cert.ca_cert.cert_pem
  private_key  = tls_self_signed_cert.ca_cert.private_key_pem
  intermediate = null
}

resource "ibm_sm_imported_certificate" "vpnserver_cert" {
  instance_id   = ibm_resource_instance.secrets_mgr.guid
  region        = var.region
  secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
  name            = "${var.region}-imported-vpnserver-cert"
  description     = "${local.full_vpnserver_cert_common_name}"
  certificate  = tls_locally_signed_cert.vpnserver_cert.cert_pem
  private_key  = tls_private_key.vpnserver_private_key.private_key_pem
  intermediate = tls_self_signed_cert.ca_cert.cert_pem
}


resource "ibm_sm_imported_certificate" "vpnclient_cert" {
  instance_id   = ibm_resource_instance.secrets_mgr.guid
  region        = var.region
  secret_group_id = ibm_sm_secret_group.sm_secret_group.secret_group_id
  name            = "${var.region}-imported-vpnclient-cert"
  description     = "${local.full_vpnclient_cert_common_name}"
  certificate  = tls_locally_signed_cert.vpnclient_cert.cert_pem
  private_key  = tls_private_key.vpnclient_private_key.private_key_pem
  intermediate = tls_self_signed_cert.ca_cert.cert_pem
}

# subnetwork
resource "ibm_is_subnet" "vpc_subnet" {
  name                     = var.subnetwork_name
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.full_zone
  total_ipv4_address_count = var.total_ipv4_address_count
}

# security group
resource "ibm_is_security_group" "vpnserver_security_group" {
  name = var.security_group_name
  vpc = ibm_is_vpc.vpc.id
}

# Configure Security Group Rule to open the VPN port
resource "ibm_is_security_group_rule" "vpnserver_security_group_rule_vpn" {
  group = ibm_is_security_group.vpnserver_security_group.id
  direction = "inbound"
  remote = "0.0.0.0/0"
  udp {
    port_min = var.vpn_port
    port_max = var.vpn_port
  }
}

resource "ibm_is_vpn_server" "vpn_server" {
  certificate_crn = ibm_sm_imported_certificate.vpnserver_cert.crn
  client_authentication {
    method    = "certificate"
    client_ca_crn = ibm_sm_imported_certificate.vpnclient_cert.crn
  }
  client_ip_pool         = var.vpnserver_client_ip_pool
  enable_split_tunneling = true
  name                   = var.vpnserver_name
  port                   = var.vpn_port
  protocol               = local.vpn_protocol
  subnets                = [ibm_is_subnet.vpc_subnet.id]
  security_groups        = [ibm_is_security_group.vpnserver_security_group.id]
}


resource "ibm_is_vpn_server_route" "server_routes" {
  for_each = local.vpc_address_prefixes_map
  vpn_server = ibm_is_vpn_server.vpn_server.id
  destination = each.value.cidr
  action = "translate"
}

output "vpn_protocol" {
  value = local.vpn_protocol
}

output "vpn_hostname" {
  value = ibm_is_vpn_server.vpn_server.hostname
}

output "vpn_ca_cert_content" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "vpn_client_cert_content" {
  value = tls_locally_signed_cert.vpnclient_cert.cert_pem
}

output "vpn_client_key_content" {
  value = tls_private_key.vpnclient_private_key.private_key_pem
}