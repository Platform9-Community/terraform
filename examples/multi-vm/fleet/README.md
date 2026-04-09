# Multi-VM Fleet

Deploy a fleet of N identical VMs on Private Cloud Director using Terraform's
`count` meta-argument. All VMs share a security group and are named
sequentially from a common prefix.

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a shared security group with SSH and ICMP ingress rules
3. Creates one bootable root volume per VM
4. Deploys N VMs, named `<prefix>-01`, `<prefix>-02`, etc.
5. Outputs the names and IP addresses of all VMs

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- An image named `Ubuntu 22.04` in the PCD image library
- The `m1.medium.vol` flavor available in your environment
- A physical network named `vmnet`
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates the security group, volumes, and VM fleet using `count` |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Tear down:

```shell
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `vm_count` | `3` | Number of VMs to deploy |
| `vm_name_prefix` | `tf-fleet` | Name prefix -- VMs will be named `<prefix>-01`, `<prefix>-02`, etc. |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium.vol` | Flavor to use for all VMs |
| `network_name` | `vmnet` | Network to attach all VMs to |
| `volume_size` | `20` | Root volume size in GB per VM |

## Notes

- Changing `vm_count` after initial deployment and running `terraform apply` will add or remove VMs at the end of the list. Removing from the middle requires careful state management.
- Each VM gets its own root volume, named `<prefix>-01-root`, `<prefix>-02-root`, etc.
