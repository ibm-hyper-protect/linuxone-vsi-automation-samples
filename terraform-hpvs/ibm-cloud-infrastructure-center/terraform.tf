terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.1.0"
    }
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.4"
    }
  }
}

# Initialise openstack
provider "openstack" {
  user_name   = var.icic_username
  password    = var.icic_password
  tenant_name = var.icic_tenant_name
  auth_url    = var.icic_auth_url
  domain_name = var.icic_domain_name
  insecure    = true
}

# Create image
resource "openstack_images_image_v2" "icic_rhel_image" {
  name             = "${var.prefix}-image"
  local_file_path  = var.hpvs_image_path
  container_format = "bare"
  disk_format      = "qcow2"
  properties = {
    os_name          = "Linux"
    os_distro        = "Rhel9"
    architecture     = "s390x"
    disk_type        = "SCSI"
    secure_execution = "True"
    hypervisor_type  = "kvm"
  }
}

# Creates flavour to define resource requirements for HPCR
resource "openstack_compute_flavor_v2" "icic_hpvs_flavor" {
  name  = "${var.prefix}-flavor"
  ram   = "4096"
  vcpus = "2"
  disk  = "10"
}

# Create security group
resource "openstack_networking_secgroup_v2" "icic_hpvs_sg" {
  name        = "${var.prefix}-sg"
  description = "HPVS ICIC security group"
}

# Allow inbound HTTP (port 80)
resource "openstack_networking_secgroup_rule_v2" "icic_hpvs_sg_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.icic_hpvs_sg.id
}

# Allow all outbound traffic
resource "openstack_networking_secgroup_rule_v2" "icic_hpvs_rule_all_outbound" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.icic_hpvs_sg.id
}

# Generates base64 of archive of pods.yaml
resource "hpcr_tgz" "contract" {
  folder = "pods"
}

locals {
  # contract in clear text
  contract = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logDNA" : {
          "ingestionKey" : var.logdna_ingestion_key,
          "hostname" : var.logdna_ingestion_hostname,
        }
      }
    },
    "workload" : {
      "type" : "workload",
      "play" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    }
  })
}

# Generates encrypted contract
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
  cert = file(var.hpcr_image_cert_path)
}

# Provision HPVS instance
resource "openstack_compute_instance_v2" "icic_hpvs_instance" {
  name      = "${var.prefix}-instance"
  image_id  = openstack_images_image_v2.icic_rhel_image.id
  flavor_id = openstack_compute_flavor_v2.icic_hpvs_flavor.id
  
  network {
    name = var.icic_network_name
  }

  scheduler_hints {
    query = ["==", "hypervisor_hostname", var.icic_target_compute_node]
  }

  security_groups = [ openstack_networking_secgroup_v2.icic_hpvs_sg.name ]
  user_data = hpcr_contract_encrypted.contract.rendered
}
