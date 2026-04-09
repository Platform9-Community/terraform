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
  default = "tf-multivol-demo"
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

variable "root_volume_size" {
  description = "Root volume size in GB"
  default     = 20
}

variable "data_volume_size" {
  description = "Data volume size in GB"
  default     = 50
}

variable "log_volume_size" {
  description = "Log volume size in GB"
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

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Volumes ---
# Root volume: boots the OS. Data and log volumes are additional block
# devices attached separately -- equivalent to adding VMDKs in vSphere.
# These volumes persist independently of the VM lifecycle unless
# delete_on_termination is set to true.

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "${var.vm_name}-root"
  size     = var.root_volume_size
  image_id = data.openstack_images_image_v2.image.id
}

resource "openstack_blockstorage_volume_v3" "data_vol" {
  name = "${var.vm_name}-data"
  size = var.data_volume_size
}

resource "openstack_blockstorage_volume_v3" "log_vol" {
  name = "${var.vm_name}-log"
  size = var.log_volume_size
}

# --- VM instance ---

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

# --- Volume attachments ---

resource "openstack_compute_volume_attach_v2" "data_attach" {
  instance_id = openstack_compute_instance_v2.vm.id
  volume_id   = openstack_blockstorage_volume_v3.data_vol.id
}

resource "openstack_compute_volume_attach_v2" "log_attach" {
  instance_id = openstack_compute_instance_v2.vm.id
  volume_id   = openstack_blockstorage_volume_v3.log_vol.id
}

# --- Outputs ---

output "vm_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "vm_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "data_volume_id" {
  value = openstack_blockstorage_volume_v3.data_vol.id
}

output "log_volume_id" {
  value = openstack_blockstorage_volume_v3.log_vol.id
}
