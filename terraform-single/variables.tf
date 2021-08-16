variable "region" {
  default = "jp-tok"
}

variable "zone1" {
  default = "jp-tok-1"
}

variable "vpc" {
  default = "terraform-test"
}

variable "ssh_public_key_name" {
  default = "terraform-test"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "subnetwork_name" {
  default = "terraform-test"
}

variable "total_ipv4_address_count" {
    default = 256
}

variable "vsi_name" {
  default = "terraform-test"
}

variable "image" {
  # Ubuntu 18.04 s390x
  default = "r022-b4aca32e-acd4-4f0e-99a8-d3cf7e9f4607"
}

variable "profile" {
  default = "bz2-2x8"
}

variable "security_group_name" {
  default = "terraform-test"
}