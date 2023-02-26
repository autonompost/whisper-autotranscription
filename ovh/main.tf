terraform {
  required_version    = ">= 0.14.0" # Takes into account Terraform versions from 0.14.0
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.40.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = ">= 0.20.0"
    }
  }
}
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" # Authentication URL
  domain_name = "default" # Domain name - Always at 'default' for OVHcloud
  alias       = "ovh" # An alias
}
provider "ovh" {
  alias    = "ovh"
  endpoint = var.endpoint
}
resource "openstack_compute_keypair_v2" "default" {
  provider   = openstack.ovh # Provider name declared in provider.tf
  name       = var.ssh_public_key_name
  public_key = file("../id_rsa.pub") # Path to your previously generated SSH key
}
resource "openstack_compute_instance_v2" "default" {
  count = var.number_vms
  name        = "${var.instance_name}-${count.index}"
  provider    = openstack.ovh  # Provider name
  image_name  = var.os_image
  flavor_name = var.instance_type
  # Name of openstack_compute_keypair_v2 resource named keypair_test
  key_pair    = openstack_compute_keypair_v2.default.name
  network {
    name      = "Ext-Net" # Adds the network component to reach your instance
  }
}
resource "local_file" "hosts_cfg" {
  content = templatefile("../templates/hosts.tpl_debian",
    {
      vms = openstack_compute_instance_v2.default[*].access_ip_v4
    }
  )
  filename = "../ansible/hosts.cfg"
}
