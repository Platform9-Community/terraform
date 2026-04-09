variable "image_uuid" {
  default = "Ubuntu 18.04"
}

variable "flavor" {
  default = "m1.small"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "pool" {
  default = "public"
}

variable "instance_count" {
  default = 3
}

variable "volume_type" {
  type = string
}

variable "network_name" {
  default = "my-network"
}

variable "instance_prefix" {
  default = "multi"
}

variable "tenant_name" {
  type = string
}

variable "os_auth_url" {
  type = string
}

variable "region" {
  type = string
}

variable "os_login" {
  type = string
}

variable "os_password" {
  type      = string
  sensitive = true
}
