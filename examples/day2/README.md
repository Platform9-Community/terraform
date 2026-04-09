# Day-2 Operations Examples

Terraform examples for common day-2 operations on Private Cloud Director --
changes made to running infrastructure after initial deployment.

## Examples

| Directory | Description |
|---|---|
| [resize-vm](resize-vm/) | Change a VM's flavor (vCPU/RAM) via an in-place Terraform update |
| [security-group-update](security-group-update/) | Add, remove, or toggle security group rules on a running VM |

## Notes

These examples demonstrate how Terraform handles in-place updates vs.
destroy-and-recreate behavior:

- **Flavor changes** (`resize-vm`): Terraform performs a stop, resize, and
  start in place. The VM's volumes, IP address, and security groups are preserved.
- **Security group rule changes** (`security-group-update`): Terraform adds or
  removes only the affected rules without modifying others. Changes take effect
  immediately on attached VMs with no restart required.
