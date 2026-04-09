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

variable "security_group_name" {
  description = "Name of the security group to manage"
  default     = "tf-managed-sg"
}

variable "allow_ssh" {
  description = "Allow SSH (port 22) ingress"
  type        = bool
  default     = true
}

variable "allow_icmp" {
  description = "Allow ICMP (ping) ingress"
  type        = bool
  default     = true
}

variable "allow_http" {
  description = "Allow HTTP (port 80) ingress"
  type        = bool
  default     = false
}

variable "allow_https" {
  description = "Allow HTTPS (port 443) ingress"
  type        = bool
  default     = false
}

variable "custom_tcp_ports" {
  description = "Additional TCP ports to open (list of port numbers)"
  type        = list(number)
  default     = []
}

variable "ssh_cidr" {
  description = "CIDR to restrict SSH access to. Use 0.0.0.0/0 to allow all."
  default     = "0.0.0.0/0"
}

# --- Security group ---

resource "openstack_networking_secgroup_v2" "sg" {
  name        = var.security_group_name
  description = "Managed by Terraform"
}

# --- Conditional rules ---
# Toggle rules on and off by changing the boolean variables and running
# terraform apply. Terraform will add or remove only the affected rules
# without touching others -- demonstrating partial in-place updates.

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count             = var.allow_ssh ? 1 : 0
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_cidr
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  count             = var.allow_icmp ? 1 : 0
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  count             = var.allow_http ? 1 : 0
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  count             = var.allow_https ? 1 : 0
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "custom_tcp" {
  count             = length(var.custom_tcp_ports)
  security_group_id = openstack_networking_secgroup_v2.sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.custom_tcp_ports[count.index]
  port_range_max    = var.custom_tcp_ports[count.index]
  remote_ip_prefix  = "0.0.0.0/0"
}

# --- Outputs ---

output "security_group_id" {
  value = openstack_networking_secgroup_v2.sg.id
}

output "security_group_name" {
  value = openstack_networking_secgroup_v2.sg.name
}
