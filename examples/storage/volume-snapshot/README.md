# Volume Snapshot

Create a point-in-time snapshot of an existing volume on Private Cloud
Director. Snapshots can be used as pre-change backups or as the basis for
new volumes.

## What This Example Does

1. Looks up an existing volume by name
2. Creates a snapshot of that volume via the OpenStack CLI using a `local-exec` provisioner

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- An existing volume to snapshot
- The OpenStack CLI installed and accessible in your shell (`openstack` command)
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Looks up the volume and creates a snapshot via `local-exec` |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `volume_name` | `my-volume` | Name of the existing volume to snapshot |
| `snapshot_name` | `tf-snapshot` | Name for the snapshot |
| `snapshot_description` | `Snapshot created by Terraform` | Description for the snapshot |

## Notes

- The OpenStack Terraform provider v3 does not expose volume snapshots as a
  managed resource. This example uses a `local-exec` provisioner to call the
  OpenStack CLI directly. The snapshot is created outside of Terraform state
  and will not be deleted by `terraform destroy`.
- `--force` is always passed so the snapshot works whether the volume is
  attached to a running VM (`in-use`) or detached (`available`). The resulting
  snapshot is crash-consistent. For application-consistent snapshots, quiesce
  writes inside the guest OS before applying.
- To delete a snapshot created by this example, use the OpenStack CLI:
  `openstack volume snapshot delete <snapshot-name>`
