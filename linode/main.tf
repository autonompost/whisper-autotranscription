terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = ">= 1.30.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_instance" "default" {
    count = var.number_vms
    label = "${var.instance_name}-${count.index}"
    image = var.os_image
    region = var.region
    type = var.instance_type
    authorized_keys = [linode_sshkey.default.ssh_key]
    private_ip = false
}

resource "linode_sshkey" "default" {
  label = var.ssh_public_key_name
  ssh_key = chomp(file("../id_rsa.pub"))
}
resource "local_file" "hosts_cfg" {
  content = templatefile("../templates/hosts.tpl",
    {
      vms = linode_instance.default[*].ip_address
    }
  )
  filename = "../ansible/hosts.cfg"
}
