
data "ibm_iam_auth_token" "tokendata" {}

provider "restapi" {
  uri                  = local.rest_endpoint
  debug                = true
  write_returns_object = true
  headers = {
    Authorization = data.ibm_iam_auth_token.tokendata.iam_access_token
  }
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

resource "restapi_object" "my_secret_group" {
  path = "/api/v1/secret_groups"
  data = jsonencode({
    metadata = {
      collection_type  = "application/vnd.ibm.secrets-manager.secret.group+json"
      collection_total = 1
    }
    resources = [{
    name        = "${var.cert_service_name}-secret-group"
    description = "Secrets group for ${var.cert_service_name}"
  }]
  })
  id_attribute = "resources/0/id"
  debug        = true
}

resource "restapi_object" "vpn_ca_cert" {
  path = "/api/v1/secrets/imported_cert"
  data = jsonencode({
    metadata = {
      collection_type  = "application/vnd.ibm.secrets-manager.secret+json"
      collection_total = 1
    }
    resources = [{
    name            = "${var.region}-imported-ca-cert"
    description     = "${local.full_ca_cert_common_name}"
    secret_group_id = restapi_object.my_secret_group.id
    certificate  = tls_self_signed_cert.ca_cert.cert_pem
    private_key  = tls_self_signed_cert.ca_cert.private_key_pem
    intermediate = null
  }]
  })
  id_attribute = "resources/0/id"
  debug        = true
}

resource "restapi_object" "vpnserver_cert" {
  path = "/api/v1/secrets/imported_cert"
  data = jsonencode({
    metadata = {
      collection_type  = "application/vnd.ibm.secrets-manager.secret+json"
      collection_total = 1
    }
    resources = [{
    name            = "${var.region}-imported-vpnserver-cert"
    description     = "${local.full_vpnserver_cert_common_name}"
    secret_group_id = restapi_object.my_secret_group.id
    certificate  = tls_locally_signed_cert.vpnserver_cert.cert_pem
    private_key  = tls_private_key.vpnserver_private_key.private_key_pem
    intermediate = tls_self_signed_cert.ca_cert.cert_pem
  }]
  })
  id_attribute = "resources/0/id"
  debug        = true
}

resource "restapi_object" "vpnclient_cert" {
  path = "/api/v1/secrets/imported_cert"
  data = jsonencode({
    metadata = {
      collection_type  = "application/vnd.ibm.secrets-manager.secret+json"
      collection_total = 1
    }
    resources = [{
    name            = "${var.region}-imported-vpnclient-cert"
    description     = "${local.full_vpnclient_cert_common_name}"
    secret_group_id = restapi_object.my_secret_group.id
    certificate  = tls_locally_signed_cert.vpnclient_cert.cert_pem
    private_key  = tls_private_key.vpnclient_private_key.private_key_pem
    intermediate = tls_self_signed_cert.ca_cert.cert_pem
  }]
  })
  id_attribute = "resources/0/id"
  debug        = true
}



# subnetwork
resource "ibm_is_subnet" "testacc_subnet" {
  name                     = var.subnetwork_name
  vpc                      = var.vpc_guid
  zone                     = local.full_zone
  total_ipv4_address_count = var.total_ipv4_address_count
}

# security group
resource "ibm_is_security_group" "testacc_security_group" {
  name = var.security_group_name
  vpc = var.vpc_guid
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
  secret_id = restapi_object.vpnserver_cert.id
}

data "ibm_secrets_manager_secret" "vpnclient_ca_secret" {
  instance_id = var.secrets_manager_guid
  secret_type = "imported_cert"
  secret_id = restapi_object.vpnclient_cert.id
}


resource "ibm_is_vpn_server" "vpn_server" {
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


resource "ibm_is_vpn_server_route" "server_routes" {
  for_each = var.vpc_address_prefixes_map
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