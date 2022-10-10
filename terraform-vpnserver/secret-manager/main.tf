

resource "ibm_resource_instance" "secrets_mgr" {
  name     = var.cert_service_name
  location = var.region
  plan     = "trial"
  service  = "secrets-manager"
}

output "secrets_manager_guid" {
  value = ibm_resource_instance.secrets_mgr.guid
}
