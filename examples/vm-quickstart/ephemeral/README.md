# VM Quickstart: Ephemeral

Deploy a VM on Private Cloud Director with an ephemeral root disk using the
HashiCorp OpenStack Terraform provider. The root disk lives on hypervisor
local storage and is deleted when the VM is deleted.

From the blog post:
[Automating Private Cloud Director: Terraform Quickstart](https://platform9.com/blog/automating-private-cloud-director-terraform-quickstart/)

## What This Example Does

1. Looks up an existing network by name
2. Creates a security group with SSH and ICMP ingress rules
3. Deploys a VM with an ephemeral root disk sized by the flavor
4. Outputs the VM ID, IP address, and security group ID

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment (Community Edition works)
- An image named `Ubuntu 22.04` in the PCD image library
- The `m1.medium` flavor available in your environment
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
| `main.tf` | Creates the security group and VM with ephemeral root disk |
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
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium` | Flavor to use -- disk size is determined by the flavor |
| `network_name` | `vmnet` | Existing network to attach the VM to |
| `vm_name` | `tf-demo-vm` | Name for the VM and associated resources |

## Notes

- Ephemeral root disks are deleted when the VM is deleted. Do not use this pattern for workloads that require data persistence.
- If the hypervisor fails and the ephemeral storage path is not on shared storage, the VM cannot be recovered on another host. For production workloads, use the boot-volume variant instead.
- Block storage does not need to be configured in your PCD environment for this variant.
