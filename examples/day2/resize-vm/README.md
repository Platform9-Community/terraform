# Resize VM

Change a VM's flavor (vCPU and RAM allocation) on Private Cloud Director
using an in-place Terraform update. The VM is stopped, resized, and restarted
without destroying or recreating it.

## What This Example Does

1. Deploys a volume-backed VM with an initial flavor
2. Demonstrates how changing `flavor_name` and running `terraform apply`
   performs an in-place resize -- the VM's volume, IP, and security group
   are preserved

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- An image named `Ubuntu 22.04` in the PCD image library
- The `m1.small.vol` flavor available in your environment
- A physical network named `vmnet`
- Block storage configured in your PCD environment
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Deploys the VM -- change `flavor_name` and re-apply to resize |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

Initial deployment:

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

To resize, update `flavor_name` in `terraform.tfvars` and apply again:

```shell
terraform apply
```

Tear down:

```shell
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `vm_name` | `tf-resize-demo` | Name for the VM and associated resources |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.small.vol` | Current or target flavor -- change this to resize |
| `network_name` | `vmnet` | Network to attach the VM to |
| `volume_size` | `20` | Root volume size in GB |

## Notes

- Terraform performs the resize in place: the VM is stopped, the flavor is
  changed, and the VM is restarted. Root volume data is preserved.
- The `current_flavor` output shows the active flavor after each apply.
- Resizing to a smaller flavor is possible but may cause instability if the
  VM's workload exceeds the new resource allocation.
