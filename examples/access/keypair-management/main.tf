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

variable "keypairs" {
  description = "Map of key pair names to SSH public key strings"
  type        = map(string)
  default = {
    "ops-key" = ""
    "dev-key" = ""
  }
}

# --- Key pairs ---
# Creates multiple named key pairs in PCD from public key strings.
# Managing key pairs as Terraform resources ensures they are tracked in
# state and can be audited, rotated, or removed consistently -- rather
# than being created ad-hoc through the UI or CLI and forgotten.
#
# Populate the keypairs variable in terraform.tfvars with the contents
# of each public key file (e.g. the output of: cat ~/.ssh/id_rsa.pub)

resource "openstack_compute_keypair_v2" "keypairs" {
  for_each   = var.keypairs
  name       = each.key
  public_key = each.value
}

# --- Outputs ---

output "keypair_names" {
  value = keys(openstack_compute_keypair_v2.keypairs)
}
