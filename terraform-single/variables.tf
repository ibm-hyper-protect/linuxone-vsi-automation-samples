variable "os_type" {
  default = "zlinux"
}
variable "region" {
  default = "jp-tok"
}

variable "zone" {
  default = "1"
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

variable "image_name" {
  # Regular expresions allowed
  default = null # Default depends on os_type - see locals.tf
}

variable "profile" {
  default = null # Default depends on os_type - see locals.tf
}

variable "security_group_name" {
  default = "terraform-test"
}