terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = format("qemu+ssh://%s@%s/system?keyfile=%s&sshauth=privkey", var.libvirt_user, var.libvirt_host, urlencode(pathexpand(var.ssh_private_key_path)))
}

module "user_data" {
  source = "../user_data"
  icl_hostname        = var.icl_hostname
  icl_iam_apikey   = var.icl_iam_apikey
}

# output the contract as a plain text (debugging purpose)
resource "local_file" "user_data_plain" {
  content  = module.user_data.user_data_plan
  filename = "../build/cloud-init/user-data-plain"
}

resource "local_file" "meta_data" {
  content  = yamlencode({
    "local-hostname": var.hostname
  })
  filename = "../build/cloud-init/meta-data"
}

resource "local_file" "vendor_data" {
  content  =  <<EOF
#cloud-config
users:
  - default
  EOF
  filename = "../build/cloud-init/vendor-data"
}

# output the contract (encrypted)
resource "local_file" "user_data" {
  content  = module.user_data.user_data
  filename = "../build/cloud-init/user-data"
}

locals {
  is_unix = substr(abspath(path.cwd), 0, 1) == "/"
}

resource "null_resource" "cloudinit_windows" {
  count = local.is_unix ? 0 : 1
  
  provisioner "local-exec" {
    command     = "mkisofs.exe -output cloudinit.iso -volid cidata -joliet -rock user-data meta-data vendor-data"
    working_dir = "../build/cloud-init"
  }

  depends_on = [
    local_file.meta_data,
    local_file.vendor_data,
    local_file.user_data
  ]
}

resource "null_resource" "cloudinit_unix" {
  count = local.is_unix ? 1 : 0
  
  provisioner "local-exec" {
    command     = <<EOF
if [[ `uname` == Darwin ]]; then 
  mkisofs -output cloudinit.iso -volid cidata -joliet -rock user-data meta-data vendor-data
else
  genisoimage -output cloudinit.iso -volid cidata -joliet -rock user-data meta-data vendor-data
fi
EOF
    working_dir = "../build/cloud-init"
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    local_file.meta_data,
    local_file.vendor_data,
    local_file.user_data
  ]
}

resource "libvirt_volume" "hello_world_vda" {
  name = format("%s-vda", var.prefix)
  pool = "images"
  source = var.vsi_image
  format = "qcow2"
}

resource "libvirt_volume" "hello_world_vdb" {
  name = format("%s-vdb", var.prefix)
  pool = "images"
  size = 131072
  format = "raw"

  xml {
    xslt = file("volume_update.xsl")
  }
}

resource "libvirt_volume" "hello_world_vdc" {
  name = format("%s-vdc", var.prefix)
  pool = "images"
  source = "../build/cloud-init/cloudinit.iso"
  format = "iso"

  depends_on = [
    null_resource.cloudinit_windows,
    null_resource.cloudinit_unix
  ]
}

resource "libvirt_domain" "hello_world_domain" {
  name = format("%s-domain", var.prefix)
  memory = 8192
  vcpu = 2

  machine = "s390-ccw-virtio"
  xml {
    xslt = file("domain_update.xsl")
  }

  disk {
    volume_id = libvirt_volume.hello_world_vda.id
  }

  disk {
    volume_id = libvirt_volume.hello_world_vdb.id
  }

  disk {
    volume_id = libvirt_volume.hello_world_vdc.id
  }

  network_interface {
    network_name = "default"
    addresses = ["192.168.122.170"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "sclp"
  }
}
