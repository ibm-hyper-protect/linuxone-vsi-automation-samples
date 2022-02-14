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
  zone                     = local.full_zone
  total_ipv4_address_count = var.total_ipv4_address_count
}

# Images
data "ibm_is_images" "vpc_images" {
}
locals {
  image = [for image in data.ibm_is_images.vpc_images.images : image if length(regexall(local.image_name, image.name)) > 0][0]
}

# vsi
resource "ibm_is_instance" "testacc_vsi" {
  name    = var.vsi_name
  image   = local.image.id
  profile = local.profile

  primary_network_interface {
    subnet = ibm_is_subnet.testacc_subnet.id
  }

  vpc  = ibm_is_vpc.testacc_vpc.id
  zone = "${var.region}-${var.zone}"
  keys = [ibm_is_ssh_key.testacc_sshkey.id]
}

# Floating IP
resource "ibm_is_floating_ip" "testacc_floatingip" {
  name   = "testfip1"
  target = ibm_is_instance.testacc_vsi.primary_network_interface[0].id
}

# security group
resource "ibm_is_security_group" "testacc_security_group" {
    name = "test"
    vpc = ibm_is_vpc.testacc_vpc.id
}

# Configure Security Group Rule to open SSH
resource "ibm_is_security_group_rule" "testacc_security_group_rule_ssh" {
    group = ibm_is_security_group.testacc_security_group.id
    direction = "inbound"
    remote = "0.0.0.0"
    depends_on = [ibm_is_security_group.testacc_security_group]
    # tcp {
    #   port_min = 22
    #   port_max = 22
    # }
 }