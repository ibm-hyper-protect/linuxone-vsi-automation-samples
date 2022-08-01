locals {
  full_zone = "${var.region}-${var.zone}"
  profile    = var.profile    != null ? var.profile    : (var.os_type=="zos" ? "mz2-2x16"      : "bz2-2x8")
  image_name = var.image_name != null ? var.image_name : (var.os_type=="zos" ? ".*zos.*" : ".*ubuntu.*s390x.*")
}