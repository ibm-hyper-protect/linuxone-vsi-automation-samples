terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.37.1"
    }
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
# make sure to target the correct region and zone
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
locals {
  # some reusable tags that identify the resources created by his sample
  tags = ["zvsi", "sample", var.prefix]
}
# the VPC
resource "ibm_is_vpc" "postgres_vpc" {
  name = format("%s-vpc", var.prefix)
  tags = local.tags
}
# the security group
resource "ibm_is_security_group" "postgres_security_group" {
  name = format("%s-security-group", var.prefix)
  vpc  = ibm_is_vpc.postgres_vpc.id
  tags = local.tags
}
resource "ibm_is_security_group_rule" "postgres_outbound" {
  group     = ibm_is_security_group.postgres_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
# Rule that allows inbound traffic to the postgres server
# to connect to the logDNA instance as well as to docker to pull the image
resource "ibm_is_security_group_rule" "postgres_inbound" {
  group     = ibm_is_security_group.postgres_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 5432
    port_max = 5432
  }
}
resource "ibm_is_ssh_key" "postgres_sshkey" {
  name       = "key-terr"
  public_key = file(var.ssh_public_key)
  tags       = local.tags
}
# locate all public image
data "ibm_is_images" "hyper_protect_images" {
  visibility = "public"
  status     = "available"
}

# locate the latest hyper protect image
data "hpcr_image" "hyper_protect_image" {
  images = jsonencode(data.ibm_is_images.hyper_protect_images.images)
}

########## master node
# the subnet
resource "ibm_is_subnet" "postgres_subnet_master" {
  name                     = format("%s-master-subnet", var.prefix)
  vpc                      = ibm_is_vpc.postgres_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone_master}"
  tags                     = local.tags
}
resource "hpcr_tgz" "contract_master" {
  folder = "compose_master"
}
locals {
  # contract in clear text
  contract_master = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logDNA" : {
          "hostname" : var.logdna_ingestion_hostname,
          "ingestionKey" : var.logdna_ingestion_key,
          "port" : 6514,
        }
      },
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract_master.rendered
      }
    }
  })
}
resource "hpcr_contract_encrypted" "contract_master" {
  contract = local.contract_master
}
# construct the VSI
resource "ibm_is_instance" "postgres_vsi_master" {
  name      = format("%s-master-vsi", var.prefix)
  image     = data.hpcr_image.hyper_protect_image.image
  profile   = var.profile
  keys      = ["${ibm_is_ssh_key.postgres_sshkey.id}"]
  vpc       = ibm_is_vpc.postgres_vpc.id
  tags      = local.tags
  zone      = "${var.region}-${var.zone_master}"
  user_data = hpcr_contract_encrypted.contract_master.rendered
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.postgres_subnet_master.id
    security_groups = [ibm_is_security_group.postgres_security_group.id]
  }
}
resource "ibm_is_floating_ip" "postgres_fip_master" {
  name   = format("%s-master-vsi", var.prefix)
  target = ibm_is_instance.postgres_vsi_master.primary_network_interface[0].id
}
resource "local_file" "slave_docker_compose" {
  content  = <<-EOT
    services:
      postgresql:
        image: docker.io/library/postgres:12@sha256:d5433064852277f3187a591e02780d377c253f69bfbe3ca66c4cf3d58be83996
        ports:
          - "5432:5432"
        command:
          - /bin/bash
          - -c
          - |
            docker-entrypoint.sh postgres &
            sleep 2
            su - postgres -c "rm -r /var/lib/postgresql/data/*"
            su - postgres -c "pg_basebackup -h ${ibm_is_floating_ip.postgres_fip_master.address} -p 5432 -U replica -D /var/lib/postgresql/data/ -Fp -Xs -R"
            wait
            kill %1
            wait
            docker-entrypoint.sh postgres
        environment:
          - POSTGRES_HOST_AUTH_METHOD=trust
    EOT
  filename = "./compose_slave/docker-compose.yml"
}

########## slave node
resource "hpcr_tgz" "contract_slave" {
  folder     = "compose_slave"
  depends_on = [local_file.slave_docker_compose]
}
locals {
  # contract in clear text
  contract_slave = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logDNA" : {
          "hostname" : var.logdna_ingestion_hostname,
          "ingestionKey" : var.logdna_ingestion_key,
          "port" : 6514,
        }
      },
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract_slave.rendered
      }
    }
  })
}
resource "hpcr_contract_encrypted" "contract_slave" {
  contract = local.contract_slave
}

##### slave_1 node
# the subnet
resource "ibm_is_subnet" "postgres_subnet_slave_1" {
  name                     = format("%s-slave-subnet-%s", var.prefix, var.zone_slave_1)
  vpc                      = ibm_is_vpc.postgres_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone_slave_1}"
  tags                     = local.tags
}
# construct the VSI
resource "ibm_is_instance" "postgres_vsi_slave_1" {
  name      = format("%s-slave-vsi-%s", var.prefix, var.zone_slave_1)
  image     = data.hpcr_image.hyper_protect_image.image
  profile   = var.profile
  keys      = ["${ibm_is_ssh_key.postgres_sshkey.id}"]
  vpc       = ibm_is_vpc.postgres_vpc.id
  tags      = local.tags
  zone      = "${var.region}-${var.zone_slave_1}"
  user_data = hpcr_contract_encrypted.contract_slave.rendered
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.postgres_subnet_slave_1.id
    security_groups = [ibm_is_security_group.postgres_security_group.id]
  }
}
resource "ibm_is_floating_ip" "postgres_fip_slave_1" {
  name   = format("%s-slave-vsi-%s", var.prefix, var.zone_slave_1)
  target = ibm_is_instance.postgres_vsi_slave_1.primary_network_interface[0].id
}

##### slave_2 node
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [ibm_is_floating_ip.postgres_fip_slave_1]
  create_duration = "60s"
}
resource "ibm_is_subnet" "postgres_subnet_slave_2" {
  name                     = format("%s-slave-subnet-%s", var.prefix, var.zone_slave_2)
  vpc                      = ibm_is_vpc.postgres_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${var.zone_slave_2}"
  tags                     = local.tags
}
resource "ibm_is_instance" "postgres_vsi_slave_2" {
  name      = format("%s-slave-vsi-%s", var.prefix, var.zone_slave_2)
  image     = data.hpcr_image.hyper_protect_image.image
  profile   = var.profile
  keys      = ["${ibm_is_ssh_key.postgres_sshkey.id}"]
  vpc       = ibm_is_vpc.postgres_vpc.id
  tags      = local.tags
  zone      = "${var.region}-${var.zone_slave_2}"
  user_data = hpcr_contract_encrypted.contract_slave.rendered
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.postgres_subnet_slave_2.id
    security_groups = [ibm_is_security_group.postgres_security_group.id]
  }
  depends_on = [time_sleep.wait_60_seconds]
}
resource "ibm_is_floating_ip" "postgres_fip_slave_2" {
  name   = format("%s-slave-vsi-%s", var.prefix, var.zone_slave_2)
  target = ibm_is_instance.postgres_vsi_slave_2.primary_network_interface[0].id
}
output "sshcommand_master" {
  value       = resource.ibm_is_floating_ip.postgres_fip_master.address
  description = "The public IP address of master the VSI on zone1"
}
output "sshcommand_slave_1" {
  value       = resource.ibm_is_floating_ip.postgres_fip_slave_1.address
  description = "The public IP address of the slave VSI on zone2"
}
output "sshcommand_slave_2" {
  value       = resource.ibm_is_floating_ip.postgres_fip_slave_2.address
  description = "The public IP address of the slave VSI on zone3"
}