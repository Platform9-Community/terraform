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
  description = "Root volume size in GB"
  default     = 20
}

variable "vm_name" {
  default = "tf-demo-vm"
}

# --- Look up existing resources ---

data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_name
  most_recent = true
}

data "openstack_networking_network_v2" "vmnet" {
  name = var.network_name
}

# --- Security group: allow SSH and ICMP ---

resource "openstack_networking_secgroup_v2" "tf_demo_sg" {
  name        = "tf-demo-sg"
  description = "Allow SSH and ICMP for Terraform demo"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.tf_demo_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  security_group_id = openstack_networking_secgroup_v2.tf_demo_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Bootable volume from image ---

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "${var.vm_name}-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.ubuntu.id
}

# --- VM instance ---

resource "openstack_compute_instance_v2" "demo_vm" {
  name            = var.vm_name
  flavor_name     = var.flavor_name
  security_groups = [openstack_networking_secgroup_v2.tf_demo_sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_vol.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    name = data.openstack_networking_network_v2.vmnet.name
  }
}

# --- Outputs ---

output "vm_id" {
  value = openstack_compute_instance_v2.demo_vm.id
}

output "vm_ip" {
  value = openstack_compute_instance_v2.demo_vm.access_ip_v4
}

output "security_group_id" {
  value = openstack_networking_secgroup_v2.tf_demo_sg.id
}

output "volume_id" {
  value = openstack_blockstorage_volume_v3.root_vol.id
}
