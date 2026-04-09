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

variable "force" {
  description = "Force snapshot creation even if the volume is attached to a running VM. Use with caution."
  type        = bool
  default     = false
}

# --- Look up existing volume ---

data "openstack_blockstorage_volume_v3" "target" {
  name = var.volume_name
}

# --- Snapshot ---
# Creates a point-in-time snapshot of the volume. For consistent snapshots
# of volumes attached to running VMs, quiesce the guest OS before applying,
# or set force = true. Snapshots can be used to create new volumes or to
# restore data.

resource "openstack_blockstorage_snapshot_v3" "snap" {
  volume_id   = data.openstack_blockstorage_volume_v3.target.id
  name        = var.snapshot_name
  description = var.snapshot_description
  force       = var.force
}

# --- Outputs ---

output "snapshot_id" {
  value = openstack_blockstorage_snapshot_v3.snap.id
}

output "snapshot_size_gb" {
  value = openstack_blockstorage_snapshot_v3.snap.size
}
