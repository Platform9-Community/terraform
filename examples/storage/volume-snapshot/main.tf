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

variable "volume_name" {
  description = "Name of an existing volume to snapshot"
  default     = "my-volume"
}

variable "snapshot_name" {
  description = "Name for the snapshot"
  default     = "tf-snapshot"
}

variable "snapshot_description" {
  description = "Description for the snapshot"
  default     = "Snapshot created by Terraform"
}

# --- Look up existing volume ---

data "openstack_blockstorage_volume_v3" "target" {
  name = var.volume_name
}

# --- Snapshot ---
# terraform-provider-openstack v3 does not expose openstack_blockstorage_snapshot_v3
# as a managed resource (only as a data source for lookups). Volume snapshots must
# be created via the OpenStack CLI or API outside of Terraform, or through a
# terraform_data local-exec as shown below.
#
# --force is always passed so the snapshot works whether the volume is attached
# to a running VM (in-use) or detached (available). For crash-consistent
# snapshots of running VMs, quiesce the guest OS before applying.
#
# Requires the openstack CLI to be installed and OS_* env vars to be set.

resource "terraform_data" "snap" {
  triggers_replace = {
    volume_id   = data.openstack_blockstorage_volume_v3.target.id
    name        = var.snapshot_name
    description = var.snapshot_description
  }

  provisioner "local-exec" {
    command = <<-EOT
      openstack volume snapshot create \
        --volume ${data.openstack_blockstorage_volume_v3.target.id} \
        --description "${var.snapshot_description}" \
        --force \
        ${var.snapshot_name}
    EOT
  }
}

# --- Outputs ---

output "volume_id_snapshotted" {
  value = data.openstack_blockstorage_volume_v3.target.id
}

output "snapshot_name" {
  value = var.snapshot_name
}
