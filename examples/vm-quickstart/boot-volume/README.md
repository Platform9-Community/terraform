# VM Quickstart: Boot Volume

Deploy a volume-backed VM on Private Cloud Director with a persistent root
volume and security group using the HashiCorp OpenStack Terraform provider.

From the blog post:
[Automating Private Cloud Director: Terraform Quickstart](https://platform9.com/blog/automating-private-cloud-director-terraform-quickstart/)

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a security group with SSH and ICMP ingress rules
3. Creates a bootable root volume from the image
4. Deploys a VM attached to the volume and network
5. Outputs the VM ID, IP address, security group ID, and volume ID

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- An image named `Ubuntu 22.04` in the PCD image library
- The `m1.medium.vol` flavor available in your environment
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
| `main.tf` | Creates the security group, volume, and VM |
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
| `flavor_name` | `m1.medium.vol` | Flavor to use for the VM |
| `network_name` | `vmnet` | Existing network to attach the VM to |
| `volume_size` | `20` | Root volume size in GB |
| `vm_name` | `tf-demo-vm` | Name for the VM and associated resources |

## Notes

- The root volume is set to `delete_on_termination = true` for demo purposes.
  Set this to `false` in production to preserve the volume if the VM is deleted.
- `terraform destroy` removes resources in reverse dependency order: VM first,
  then volume, then security group rules and group.
- For ephemeral (non-volume-backed) VMs, see the [ephemeral](../ephemeral/) variant.
