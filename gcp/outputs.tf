output "ipv4_address_public" {
  description = "The public IPv4 address"
  value       = linode_instance.default[*].ip_address
}
