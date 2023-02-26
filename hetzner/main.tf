provider "hcloud" {
  # via cli -var="hcloud_token=${HCLOUD_TOKEN}" from .env file
  token = var.hcloud_token
}
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">= 1.30.0"
    }
  }
}
resource "hcloud_server" "default" {
  count = var.number_vms
  name        = "${var.instance_name}-${count.index}"
  image       = var.os_image
  server_type = var.instance_type
  location = var.region
  ssh_keys = [hcloud_ssh_key.default.name]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
resource "hcloud_ssh_key" "default" {
  name       = var.ssh_public_key_name
  public_key = file("../id_rsa.pub")
}
resource "local_file" "hosts_cfg" {
  content = templatefile("../templates/hosts.tpl",
    {
      vms = hcloud_server.default[*].ipv4_address
    }
  )
  filename = "../ansible/hosts.cfg"
}
