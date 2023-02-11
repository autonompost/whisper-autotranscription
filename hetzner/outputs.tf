output "ipv4_address_public" {
  description = "The public IPv4 address"
  value       = hcloud_server.default[*].ipv4_address
}