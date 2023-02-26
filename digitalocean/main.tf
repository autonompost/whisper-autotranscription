terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.20.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "default" {
  count  = var.number_vms
  name   = "${var.instance_name}-${count.index}"
  image  = var.os_image
  region = var.region
  size   = var.instance_type
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_ssh_key" "default" {
  name       = var.ssh_public_key_name
  public_key = file("../id_rsa.pub")
}
resource "local_file" "hosts_cfg" {
  content = templatefile("../templates/hosts.tpl",
    {
      vms = digitalocean_droplet.default[*].ipv4_address
    }
  )
  filename = "../ansible/hosts.cfg"
}
