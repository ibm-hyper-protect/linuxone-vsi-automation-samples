terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    hpcr = {
      source  = "ibm-hyper-protect/hpcr"
      version = ">= 0.1.4"
    }
  }
}

provider "libvirt" {
  uri = format("qemu+ssh://%s@%s:%s/system?keyfile=%s&sshauth=privkey", var.libvirt_user, var.libvirt_host, var.libvirt_port, urlencode(pathexpand(var.ssh_private_key_path)))
}

# archive of the folder containing docker-compose file. This folder could create additional resources such as files 
# to be mounted into containers, environment files etc. This is why all of these files get bundled in a tgz file (base64 encoded)
resource "hpcr_tgz" "contract" {
  folder = "compose"
}

locals {
  # contract in clear text
  contract = yamlencode({
    "env" : {
      "type" : "env",
      "logging" : {
        "logRouter" : {
          "hostname" : var.icl_hostname,
          "iamApiKey" : var.icl_iam_apikey
        }
      },
      "crypto-pt": {
        "index-1": {
          "type": "secret",
          "domain-id": var.crypto_domain_id,
          "secret": base64encode(var.crypto_secret),
          "mkvp": var.crypto_mkvp
        }
      },
      "host-hkd": {
        "name": basename(var.hkd_path),
        "host-key-doc": base64encode(var.hkd_path)
      }
    },
    "workload" : {
      "type" : "workload",
      "compose" : {
        "archive" : hpcr_tgz.contract.rendered
      }
    }
  })
}

# In this step we encrypt the fields of the contract and sign the env and workload field. The certificate to execute the 
# encryption it built into the provider and matches the latest HPCR image. If required it can be overridden. 
# We use a temporary, random keypair to execute the signature. This could also be overriden. 
resource "hpcr_contract_encrypted" "contract" {
  contract = local.contract
  cert     = file(var.hpcr_image_cert_path)
}

# output the contract as a plain text (debugging purpose)
resource "local_file" "user_data_plain" {
  content  = local.contract
  filename = "build/cloud-init/user-data-plain"
}

resource "local_file" "meta_data" {
  content = yamlencode({
    "local-hostname" : var.hostname
  })
  filename = "build/cloud-init/meta-data"
}

resource "local_file" "vendor_data" {
  content  = <<EOF
#cloud-config
users:
  - default
  EOF
  filename = "build/cloud-init/vendor-data"
}

# output the contract (encrypted)
resource "local_file" "user_data" {
  content  = resource.hpcr_contract_encrypted.contract.rendered
  filename = "build/cloud-init/user-data"
}

locals {
  is_unix = substr(abspath(path.cwd), 0, 1) == "/"
}

resource "null_resource" "cloudinit_windows" {
  count = local.is_unix ? 0 : 1

  provisioner "local-exec" {
    command     = "mkisofs.exe -output cloudinit.iso -volid cidata -joliet -rock user-data meta-data vendor-data"
    working_dir = "build/cloud-init"
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
    working_dir = "build/cloud-init"
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    local_file.meta_data,
    local_file.vendor_data,
    local_file.user_data
  ]
}

resource "libvirt_pool" "cryptopassthrough_pool" {
  name = "cryptopassthrough_pool"
  type = "dir"
  path = var.storage_pool_path

}

resource "libvirt_volume" "cryptopassthrough_vda" {
  name   = format("%s-vda", var.prefix)
  pool   = resource.libvirt_pool.cryptopassthrough_pool.name
  source = var.vsi_image_path
  format = "qcow2"
}

resource "libvirt_volume" "cryptopassthrough_vdc" {
  name   = format("%s-vdc", var.prefix)
  pool   = resource.libvirt_pool.cryptopassthrough_pool.name
  source = "build/cloud-init/cloudinit.iso"
  format = "iso"

  depends_on = [
    null_resource.cloudinit_windows,
    null_resource.cloudinit_unix
  ]
}

data "template_file" "xslt_with_uuid" {
  template = file("domain_update.xsl")

  vars = {
    crypto_card_uuid = var.crypto_card_uuid
  }
}

resource "libvirt_domain" "cryptopassthrough_domain" {
  name   = format("%s-domain", var.prefix)
  memory = 8192
  vcpu   = 2

  machine = "s390-ccw-virtio"

  xml {
    xslt = data.template_file.xslt_with_uuid.rendered
  }

  disk {
    volume_id = libvirt_volume.cryptopassthrough_vda.id
  }

  disk {
    volume_id = libvirt_volume.cryptopassthrough_vdc.id
  }

  network_interface {
    network_name = "default"
    addresses    = ["192.168.122.69"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "sclp"
  }

  depends_on = [
    libvirt_volume.cryptopassthrough_vda,
    libvirt_volume.cryptopassthrough_vdc
  ]
}

# CURL
resource "null_resource" "cryptopassthrough_curl" {

  triggers = {
    always_run = "${timestamp()}"
  }

  # Wait 60s for Docker container to come up
  provisioner "local-exec" {
    command = "sleep 60"
  }

  provisioner "local-exec" {
    command = format("ssh %s@%s 'bash -s' < curl.sh %s > output/result.json", var.libvirt_user, var.libvirt_host, var.hostname)
  }

  provisioner "local-exec" {
    command = "cat output/result.json"
  }

  depends_on = [libvirt_domain.cryptopassthrough_domain]
}
