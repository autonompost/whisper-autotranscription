output "ipv4_address_public" {
  description = "The public IPv4 address of the spot instance"
  value = "${aws_spot_instance_request.default.public_ip}"
}
