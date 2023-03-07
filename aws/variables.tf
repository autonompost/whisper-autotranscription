variable "number_vms" {
  description = "number virtual machines to deploy"
  type = number
  default = 1
}
variable "access_key" {
  description = "access key"
  type = string
}
variable "secret_key" {
  description = "secret key"
  type = string
}

variable "region" {
  description = "region"
  type = string
}
variable "zone" {
  description = "zone of the instance"
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
