output "ipv4_address_public" {
  description = "The public IPv4 address"
  value = google_compute_instance.default[*].network_interface.0.access_config.0.nat_ip
}
