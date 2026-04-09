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
  default = "tf-cloudinit-demo"
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

variable "vm_hostname" {
  description = "Hostname to set inside the guest OS via cloud-init"
  default     = "tf-cloudinit-demo"
}

variable "packages" {
  description = "List of packages to install at first boot"
  type        = list(string)
  default     = ["nginx", "curl", "htop"]
}

variable "ssh_authorized_key" {
  description = "SSH public key to inject into the default user's authorized_keys"
  default     = ""
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
  description = "Allow SSH and HTTP"
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

resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Root volume ---

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "${var.vm_name}-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

# --- cloud-init user data ---
# cloud-init runs at first boot and configures the guest OS before any
# user logs in. This replaces vSphere guest customization specs and
# VMware Tools-based post-deploy configuration.
#
# The templatefile() function renders the cloud-init YAML, substituting
# variables at plan time. The rendered string is passed to user_data on
# the instance resource.

locals {
  user_data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    hostname           = var.vm_hostname
    packages           = var.packages
    ssh_authorized_key = var.ssh_authorized_key
  })
}

# --- VM instance ---

resource "openstack_compute_instance_v2" "vm" {
  name            = var.vm_name
  flavor_name     = var.flavor_name
  security_groups = [openstack_networking_secgroup_v2.sg.name]
  user_data       = local.user_data

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
