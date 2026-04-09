terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "openstack" {}

# --- Variables ---

variable "vm_count" {
  description = "Number of VMs to deploy"
  default     = 2
}

variable "vm_name_prefix" {
  description = "Name prefix for VMs"
  default     = "tf-ansible-target"
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
  description = "Root volume size in GB"
  default     = 20
}

variable "ansible_user" {
  description = "SSH user Ansible will connect as"
  default     = "ubuntu"
}

variable "ansible_ssh_private_key_file" {
  description = "Path to the SSH private key Ansible will use"
  default     = "~/.ssh/id_rsa"
}

variable "inventory_output_path" {
  description = "Local path to write the generated Ansible inventory file"
  default     = "./inventory.ini"
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
  description = "Allow SSH"
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

# --- Root volumes ---

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

# --- Ansible inventory file ---
# Generates a static INI-format Ansible inventory from Terraform outputs.
# This file is written to inventory_output_path after terraform apply and
# can be passed directly to ansible-playbook with -i inventory.ini.
#
# This implements the Terraform-then-Ansible handoff pattern: Terraform
# provisions the infrastructure, writes the inventory, and Ansible runs
# against it for guest OS configuration.

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.ini.tpl", {
    vms                        = openstack_compute_instance_v2.vm
    ansible_user               = var.ansible_user
    ansible_ssh_private_key_file = var.ansible_ssh_private_key_file
  })
  filename        = var.inventory_output_path
  file_permission = "0644"
}

# --- Outputs ---

output "vm_ips" {
  value = openstack_compute_instance_v2.vm[*].access_ip_v4
}

output "inventory_path" {
  value = var.inventory_output_path
}
