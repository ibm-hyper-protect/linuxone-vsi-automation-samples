# Create a VPC
resource "ibm_is_vpc" "testacc_vpc" {
  name = var.vpc
}

# subnetwork
resource "ibm_is_subnet" "testacc_subnet" {
  name                     = var.subnetwork_name
  vpc                      = ibm_is_vpc.testacc_vpc.id
  zone                     = local.full_zone
  total_ipv4_address_count = var.total_ipv4_address_count
}

# security group
resource "ibm_is_security_group" "testacc_security_group" {
  name = var.security_group_name
  vpc = ibm_is_vpc.testacc_vpc.id
}

# Configure Security Group Rule to open the VPN port
resource "ibm_is_security_group_rule" "testacc_security_group_rule_vpn" {
  group = ibm_is_security_group.testacc_security_group.id
  direction = "inbound"
  remote = "0.0.0.0/0"
  udp {
    port_min = var.vpn_port
    port_max = var.vpn_port
  }
}

data "ibm_secrets_manager_secret" "vpnserver_secret" {
  instance_id = var.secrets_manager_guid
  secret_type = "imported_cert"
  secret_id = var.vpnserver_secret_id
}

data "ibm_secrets_manager_secret" "vpnclient_ca_secret" {
  instance_id = var.secrets_manager_guid
  secret_type = "imported_cert"
  secret_id = var.client_ca_secret_id
}


resource "ibm_is_vpn_server" "example" {
  certificate_crn = data.ibm_secrets_manager_secret.vpnserver_secret.crn
  client_authentication {
    method    = "certificate"
    client_ca_crn = data.ibm_secrets_manager_secret.vpnclient_ca_secret.crn
  }
  client_ip_pool         = var.vpnserver_client_ip_pool
  enable_split_tunneling = true
  name                   = var.vpnserver_name
  port                   = var.vpn_port
  protocol               = local.vpn_protocol
  subnets                = [ibm_is_subnet.testacc_subnet.id]
}

data "ibm_is_vpc_address_prefixes" "vpc_addresses" {
  vpc  = ibm_is_vpc.testacc_vpc.id
}

resource "ibm_is_vpn_server_route" "server_routes" {
  for_each = { for addrs in data.ibm_is_vpc_address_prefixes.vpc_addresses.address_prefixes: addrs.id => addrs }
  vpn_server = ibm_is_vpn_server.example.id
  destination = each.value.cidr
  action = "translate"
}
