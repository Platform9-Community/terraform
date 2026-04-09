# Images Examples

Terraform examples for working with images in the Private Cloud Director
image library.

## Examples

| Directory | Description |
|---|---|
| [image-lookup](image-lookup/) | Query images by name, visibility, and owner -- demonstrates how to reference image IDs in other resources |

## Notes

- Images are added to the PCD image library via the PCD UI or the OpenStack CLI:
  `openstack image create --file image.qcow2 --disk-format qcow2 --container-format bare --public my-image`
- Standard Linux cloud images should have `hw_disk_bus = virtio` and
  `hw_vif_model = virtio` set as image properties for best performance on
  KVM/QEMU. Use `openstack image show <image-name>` to inspect properties
  on existing images.
- When multiple images share the same name, always use `most_recent = true`
  in data source lookups to avoid ambiguity errors.
