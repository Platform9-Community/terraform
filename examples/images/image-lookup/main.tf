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
  description = "Name of the image to look up in the PCD image library"
  default     = "Ubuntu 22.04"
}

variable "visibility" {
  description = "Filter by image visibility: public, private, shared, or community"
  default     = "public"
}

variable "owner" {
  description = "Filter by image owner project ID. Leave empty to return images from all projects."
  default     = ""
}

# --- Image lookups ---
# Demonstrates three common patterns for finding images in the PCD image library.
# These data sources are used as references in other Terraform configurations --
# the image ID returned here is what you pass to openstack_blockstorage_volume_v3
# or openstack_compute_instance_v2 when deploying VMs.
#
# Equivalent to browsing the Content Library or VM templates in vSphere.

# Pattern 1: Look up the most recent image matching a name.
# Use this when you maintain versioned images and always want the latest.

data "openstack_images_image_v2" "by_name" {
  name        = var.image_name
  most_recent = true
}

# Pattern 2: Look up images by visibility.
# Useful for auditing what public images are available in your environment.

data "openstack_images_image_v2" "by_visibility" {
  most_recent = true
  visibility  = var.visibility
}

# Pattern 3: Look up an image by name and filter by owner project.
# Useful in multi-tenant environments where multiple projects may have
# images with the same name.

data "openstack_images_image_v2" "by_name_and_owner" {
  name        = var.image_name
  most_recent = true
  owner       = var.owner != "" ? var.owner : null
}

# --- Outputs ---
# These outputs demonstrate the image attributes available for use in
# other resources. The most commonly referenced attribute is image_id,
# which is used as the image_id argument in volume and instance resources.

output "image_id" {
  description = "ID of the image -- use this in volume and instance resources"
  value       = data.openstack_images_image_v2.by_name.id
}

output "image_name" {
  value = data.openstack_images_image_v2.by_name.name
}

output "image_size_bytes" {
  value = data.openstack_images_image_v2.by_name.size_bytes
}

output "image_disk_format" {
  value = data.openstack_images_image_v2.by_name.disk_format
}

output "image_updated_at" {
  description = "When the image was last updated -- useful for confirming you have the right version"
  value       = data.openstack_images_image_v2.by_name.updated_at
}

output "image_properties" {
  description = "Hardware properties set on the image (hw_disk_bus, hw_vif_model, etc.)"
  value       = data.openstack_images_image_v2.by_name.properties
}
