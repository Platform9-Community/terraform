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
  default = "tf-resize-demo"
}

variable "image_name" {
  default = "Ubuntu 22.04"
}

variable "flavor_name" {
  description = "Current or target flavor. Change this value and run terraform apply to resize the VM."
  default     = "m1.small.vol"
}

variable "network_name" {
  default = "vmnet"
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

data "openstack_networking_network_v2" "network" {
  name = var.network_name
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

# --- Root volume ---

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "${var.vm_name}-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

# --- VM instance ---
# To resize: change flavor_name in terraform.tfvars and run terraform apply.
# Terraform will perform an in-place resize (stop, resize, confirm, start)
# rather than destroying and recreating the VM. The root volume and its
# data are preserved.

resource "openstack_compute_instance_v2" "vm" {
  name            = var.vm_name
  flavor_name     = var.flavor_name
  security_groups = [openstack_networking_secgroup_v2.sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_vol.id
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

output "vm_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "vm_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "current_flavor" {
  value = openstack_compute_instance_v2.vm.flavor_name
}
