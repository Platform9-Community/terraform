terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
  }
}

provider "openstack" {}

# --- Variables ---

variable "network_name" {
  description = "Name for the new tenant network"
  default     = "demo-network"
}

variable "subnet_name" {
  description = "Name for the subnet"
  default     = "demo-subnet"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "192.168.100.0/24"
}

variable "dns_nameservers" {
  description = "DNS nameservers for the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "router_name" {
  description = "Name for the virtual router"
  default     = "demo-router"
}

variable "external_network_name" {
  description = "Name of the existing provider network to use as the router's external gateway"
  default     = "vmnet"
}

# --- Look up existing external/provider network ---

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# --- Tenant network and subnet ---

resource "openstack_networking_network_v2" "demo_network" {
  name           = var.network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "demo_subnet" {
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.demo_network.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

# --- Virtual router with external gateway ---

resource "openstack_networking_router_v2" "demo_router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

# --- Attach subnet to router ---

resource "openstack_networking_router_interface_v2" "demo_router_iface" {
  router_id = openstack_networking_router_v2.demo_router.id
  subnet_id = openstack_networking_subnet_v2.demo_subnet.id
}

# --- Outputs ---

output "network_id" {
  value = openstack_networking_network_v2.demo_network.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.demo_subnet.id
}

output "router_id" {
  value = openstack_networking_router_v2.demo_router.id
}
