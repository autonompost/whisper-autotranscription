variable "number_vms" {
  description = "number virtual machines to deploy"
  type = number
}
variable "region" {
  description = "region"
  type = string
}
variable "zone" {
  description = "zone of the instance"
  type = string
}
variable "gpu_type" {
  description = "type of the gpu to use"
  type = string
}
variable "number_gpus" {
  description = "number of gpu's to use for the instance"
  type = integer
}
variable "project_id" {
  description = "gcp project for deployment"
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
