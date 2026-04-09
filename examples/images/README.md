# Images Examples

Terraform examples for managing images in the Private Cloud Director image library.

## Examples

| Directory | Description |
|---|---|
| [image-upload](image-upload/) | Upload a local QCOW2 or VMDK image file to the PCD image library |

## Notes

- Image uploads can take several minutes depending on file size and network speed.
- For VMDK images exported from vSphere, set `disk_format = "vmdk"` in your
  `terraform.tfvars`.
- The `hw_disk_bus = "virtio"` and `hw_vif_model = "virtio"` properties set in
  `image-upload/main.tf` are recommended defaults for KVM/QEMU guests. If your
  image requires legacy IDE or e1000 drivers, adjust these accordingly.
