
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

output "vpnclient_cert_id" {
  value = restapi_object.vpnclient_cert.id
}

output "vpnserver_cert_id" {
  value = restapi_object.vpnserver_cert.id
}

output "vpn_ca_cert_id" {
  value = restapi_object.vpn_ca_cert.id
}