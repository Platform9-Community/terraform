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

variable "vm_name" {
  default = "tf-floating-ip-demo"
}

variable "image_name" {
  default = "Ubuntu 22.04"
}

variable "flavor_name" {
  default = "m1.medium.vol"
}

variable "network_name" {
  description = "Tenant network to attach the VM to"
  default     = "demo-network"
}

variable "external_network_name" {
  description = "Provider network to allocate the floating IP from"
  default     = "vmnet"
}

variable "volume_size" {
  description = "Root volume size in GB"
  default     = 20
}

# --- Look up existing resources ---

data "openstack_images_image_v2" "image" {
  name        = var.image_name
  most_recent = true
}

data "openstack_networking_network_v2" "tenant_net" {
  name = var.network_name
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# --- Security group ---

resource "openstack_networking_secgroup_v2" "sg" {
  name        = "${var.vm_name}-sg"
  description = "Allow SSH and ICMP"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Bootable volume ---

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "${var.vm_name}-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

# --- Network port ---
# In provider v3, floating IP association requires a port ID, not an instance ID.
# Creating an explicit port lets us attach the security group at the Neutron level
# and gives us the port ID needed for openstack_networking_floatingip_associate_v2.

resource "openstack_networking_port_v2" "port" {
  name               = "${var.vm_name}-port"
  network_id         = data.openstack_networking_network_v2.tenant_net.id
  security_group_ids = [openstack_networking_secgroup_v2.sg.id]
}

# --- VM instance ---

resource "openstack_compute_instance_v2" "vm" {
  name        = var.vm_name
  flavor_name = var.flavor_name

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_vol.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.port.id
  }
}

# --- Floating IP ---
# Allocates a floating IP from the external network and associates it
# with the VM's port on the tenant network. Equivalent to a NAT rule
# on an NSX edge or a vSphere VM with a static one-to-one NAT.
# Provider v3 uses openstack_networking_floatingip_associate_v2 (Neutron),
# not the deprecated openstack_compute_floatingip_associate_v2 (Nova).

resource "openstack_networking_floatingip_v2" "fip" {
  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_networking_port_v2.port.id
}

# --- Outputs ---

output "vm_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "private_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
