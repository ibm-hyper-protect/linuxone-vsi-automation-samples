

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

output "vpc_address_prefixes_map" {
  value = tomap({ for addrs in data.ibm_is_vpc_address_prefixes.vpc_addresses.address_prefixes: addrs.id => addrs })
}