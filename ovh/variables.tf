variable "endpoint" {
  description = "endpoint of the ovh api"
  type = string
  default = "ovh-eu"
}
variable "number_vms" {
  description = "number virtual machines to deploy"
  type = number
}
variable "region" {
  description = "region"
  type = string
}
variable "instance_name" {
  description = "instance name"
  type = string
}
variable "instance_type" {
  description = "instance type"
  type = string
}
variable "os_image" {
  description = "os image"
  type = string
}
variable "ssh_public_key_name" {
  description = "ssh public key name"
  type = string
}
