output "ipv4_address_public" {
  description = "The public IPv4 address"
  value       = digitalocean_droplet.default[*].ipv4_address
}
