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

variable "vm_count" {
  description = "Number of VMs to deploy"
  default     = 3
}

variable "vm_name_prefix" {
  description = "Name prefix for VMs. VMs will be named <prefix>-01, <prefix>-02, etc."
  default     = "tf-fleet"
}

variable "image_name" {
  default = "Ubuntu 22.04"
}

variable "flavor_name" {
  default = "m1.medium.vol"
}

variable "network_name" {
  default = "vmnet"
}

variable "volume_size" {
  description = "Root volume size in GB per VM"
  default     = 20
}

# --- Look up existing resources ---

data "openstack_images_image_v2" "image" {
  name        = var.image_name
  most_recent = true
}

data "openstack_networking_network_v2" "network" {
  name = var.network_name
}

# --- Security group ---

resource "openstack_networking_secgroup_v2" "sg" {
  name        = "${var.vm_name_prefix}-sg"
  description = "Allow SSH and ICMP for fleet"
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

# --- Bootable volumes (one per VM) ---

resource "openstack_blockstorage_volume_v3" "root_vol" {
  count    = var.vm_count
  name     = format("%s-%02d-root", var.vm_name_prefix, count.index + 1)
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

# --- VM instances ---

resource "openstack_compute_instance_v2" "vm" {
  count           = var.vm_count
  name            = format("%s-%02d", var.vm_name_prefix, count.index + 1)
  flavor_name     = var.flavor_name
  security_groups = [openstack_networking_secgroup_v2.sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_vol[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    name = data.openstack_networking_network_v2.network.name
  }
}

# --- Outputs ---

output "vm_names" {
  value = openstack_compute_instance_v2.vm[*].name
}

output "vm_ips" {
  value = openstack_compute_instance_v2.vm[*].access_ip_v4
}
