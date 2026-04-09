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

variable "web_flavor" {
  default = "m1.medium.vol"
}

variable "db_flavor" {
  default = "m1.large.vol"
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

# --- Web tier security group ---
# Allows SSH and HTTP/HTTPS from anywhere.

resource "openstack_networking_secgroup_v2" "web_sg" {
  name        = "tf-web-sg"
  description = "Web tier: allow SSH, HTTP, HTTPS"
}

resource "openstack_networking_secgroup_rule_v2" "web_ssh" {
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "web_http" {
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "web_https" {
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- DB tier security group ---
# Allows SSH from anywhere, but MySQL only from the web security group.
# This is the key pattern: the DB tier is not directly reachable from
# the internet on port 3306 -- only from VMs in the web security group.

resource "openstack_networking_secgroup_v2" "db_sg" {
  name        = "tf-db-sg"
  description = "DB tier: allow SSH, MySQL from web tier only"
}

resource "openstack_networking_secgroup_rule_v2" "db_ssh" {
  security_group_id = openstack_networking_secgroup_v2.db_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "db_mysql_from_web" {
  security_group_id        = openstack_networking_secgroup_v2.db_sg.id
  direction                = "ingress"
  ethertype                = "IPv4"
  protocol                 = "tcp"
  port_range_min           = 3306
  port_range_max           = 3306
  remote_group_id          = openstack_networking_secgroup_v2.web_sg.id
}

# --- Web tier root volume and VM ---

resource "openstack_blockstorage_volume_v3" "web_vol" {
  name     = "tf-web-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

resource "openstack_compute_instance_v2" "web" {
  name            = "tf-web"
  flavor_name     = var.web_flavor
  security_groups = [openstack_networking_secgroup_v2.web_sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.web_vol.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    name = data.openstack_networking_network_v2.network.name
  }
}

# --- DB tier root volume and VM ---

resource "openstack_blockstorage_volume_v3" "db_vol" {
  name     = "tf-db-root"
  size     = var.volume_size
  image_id = data.openstack_images_image_v2.image.id
}

resource "openstack_compute_instance_v2" "db" {
  name            = "tf-db"
  flavor_name     = var.db_flavor
  security_groups = [openstack_networking_secgroup_v2.db_sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.db_vol.id
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

output "web_ip" {
  value = openstack_compute_instance_v2.web.access_ip_v4
}

output "db_ip" {
  value = openstack_compute_instance_v2.db.access_ip_v4
}

output "web_security_group_id" {
  value = openstack_networking_secgroup_v2.web_sg.id
}

output "db_security_group_id" {
  value = openstack_networking_secgroup_v2.db_sg.id
}
