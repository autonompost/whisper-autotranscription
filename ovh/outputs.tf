output "ipv4_address_public" {
  description = "The public IPv4 address"
  value       = openstack_compute_instance_v2.default[*].access_ip_v4
}
