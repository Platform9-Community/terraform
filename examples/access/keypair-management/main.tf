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
  description = "Map of key pair names to local public key file paths"
  type        = map(string)
  default = {
    "ops-key"  = "~/.ssh/id_rsa.pub"
    "dev-key"  = "~/.ssh/id_rsa.pub"
  }
}

# --- Key pairs ---
# Creates multiple named key pairs in PCD from local public key files.
# Managing key pairs as Terraform resources ensures they are tracked in
# state and can be audited, rotated, or removed consistently -- rather
# than being created ad-hoc through the UI or CLI and forgotten.

resource "openstack_compute_keypair_v2" "keypairs" {
  for_each        = var.keypairs
  name            = each.key
  public_key_file = each.value
}

# --- Outputs ---

output "keypair_names" {
  value = keys(openstack_compute_keypair_v2.keypairs)
}
