# Create a VPC
resource "ibm_is_vpc" "testacc_vpc" {
  name = var.vpc
}

# ssh key
resource "ibm_is_ssh_key" "testacc_sshkey" {
  name      = var.ssh_public_key_name
  public_key = file(var.ssh_public_key)
}

# subnetwork
resource "ibm_is_subnet" "testacc_subnet" {
  name                     = var.subnetwork_name
  vpc                      = ibm_is_vpc.testacc_vpc.id
  zone                     = var.zone1
  total_ipv4_address_count = var.total_ipv4_address_count
}

# vsi
resource "ibm_is_instance" "testacc_instance" {
  name    = var.vsi_name
  image   = var.image
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.testacc_subnet.id
  }

  vpc  = ibm_is_vpc.testacc_vpc.id
  zone = var.zone1
  keys = [ibm_is_ssh_key.testacc_sshkey.id]
}

# security group
resource "ibm_is_security_group" "testacc_security_group" {
    name = "test"
    vpc = ibm_is_vpc.testacc_vpc.id
}

# Configure Security Group Rule to open SSH and web server on the VSI
resource "ibm_is_security_group_rule" "testacc_security_group_rule_all" {
    group = ibm_is_security_group.testacc_security_group.id
    direction = "inbound"
    remote = "0.0.0.0"
    depends_on = [ibm_is_security_group.testacc_security_group]
 }