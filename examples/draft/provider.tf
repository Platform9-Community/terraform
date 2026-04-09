terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.os_login
  tenant_name = var.tenant_name
  password    = var.os_password
  auth_url    = var.os_auth_url
  region      = var.region
}
