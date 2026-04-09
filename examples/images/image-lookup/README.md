# Image Lookup

Query images in the Private Cloud Director image library using Terraform data
sources. Demonstrates three common lookup patterns and shows which image
attributes are available for use in other resources.

## What This Example Does

1. Looks up the most recent image matching a name
2. Looks up the most recent image matching a visibility filter
3. Looks up an image by name with an optional owner project filter
4. Outputs the image ID, name, size, disk format, last updated timestamp,
   and hardware properties

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment with at least one image
  in the image library
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Three image lookup patterns using `openstack_images_image_v2` data sources |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

This example uses only data sources -- `terraform plan` is sufficient to
see the outputs. No resources are created and `terraform apply` is not
required.

## Variables

| Variable | Default | Description |
|---|---|---|
| `image_name` | `Ubuntu 22.04` | Name of the image to look up |
| `visibility` | `public` | Filter by visibility: `public`, `private`, `shared`, or `community` |
| `owner` | `""` | Filter by owner project ID -- leave empty to search all projects |

## How to Use Image IDs in Other Resources

The `image_id` output is what you pass to other resources when deploying VMs.
Reference it using a data source in your own configurations:

```hcl
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04"
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "root_vol" {
  name     = "my-vm-root"
  size     = 20
  image_id = data.openstack_images_image_v2.ubuntu.id
}
```

## Notes

- `most_recent = true` is important when multiple images share the same name.
  Without it, Terraform will error if the query returns more than one result.
- The `properties` output shows hardware attributes like `hw_disk_bus` and
  `hw_vif_model` that affect how the image boots on KVM/QEMU. These are set
  when an image is registered in PCD and should be `virtio` for standard
  Linux cloud images.
- To add images to the PCD image library, use the PCD UI or the OpenStack CLI:
  `openstack image create --file image.qcow2 --disk-format qcow2 --container-format bare --public my-image`
