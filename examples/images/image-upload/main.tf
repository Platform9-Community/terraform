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
  description = "Name for the image in the PCD image library"
  default     = "my-custom-image"
}

variable "image_local_path" {
  description = "Local path to the QCOW2 image file to upload"
  default     = "./image.qcow2"
}

variable "disk_format" {
  description = "Disk format of the image file (qcow2, raw, vmdk, etc.)"
  default     = "qcow2"
}

variable "container_format" {
  description = "Container format -- bare for most cases"
  default     = "bare"
}

variable "visibility" {
  description = "Image visibility: public (all projects) or private (current project only)"
  default     = "public"
}

variable "min_disk_gb" {
  description = "Minimum disk size in GB required to boot this image"
  default     = 10
}

variable "min_ram_mb" {
  description = "Minimum RAM in MB required to boot this image"
  default     = 512
}

# --- Image upload ---
# Uploads a local image file to the PCD image library.
# Equivalent to registering a custom VM template in vSphere.
# For VMDK images exported from vSphere, set disk_format = "vmdk".
# Large images may take several minutes to upload.

resource "openstack_images_image_v2" "custom_image" {
  name             = var.image_name
  local_file_path  = var.image_local_path
  disk_format      = var.disk_format
  container_format = var.container_format
  visibility       = var.visibility
  min_disk_gb      = var.min_disk_gb
  min_ram_mb       = var.min_ram_mb

  properties = {
    hw_disk_bus  = "virtio"
    hw_vif_model = "virtio"
  }
}

# --- Outputs ---

output "image_id" {
  value = openstack_images_image_v2.custom_image.id
}

output "image_name" {
  value = openstack_images_image_v2.custom_image.name
}

output "image_size_bytes" {
  value = openstack_images_image_v2.custom_image.size_bytes
}
