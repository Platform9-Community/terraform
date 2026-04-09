# VM Quickstart

Deploy a VM on Private Cloud Director using the HashiCorp OpenStack Terraform
provider. Two variants are available depending on your storage requirements.

From the blog post:
[Automating Private Cloud Director: Terraform Quickstart](https://platform9.com/blog/automating-private-cloud-director-terraform-quickstart/)

## Which Variant Should I Use?

| | [boot-volume/](boot-volume/) | [ephemeral/](ephemeral/) |
|---|---|---|
| Root disk location | Persistent block storage (Block Storage Service) | Hypervisor local storage |
| Disk persists after VM deletion | Yes (configurable) | No |
| VM HA recovery across hypervisor failure | Yes | Only if local storage is on shared storage |
| Requires block storage configured | Yes | No |
| Good for | Production workloads, anything stateful | Dev/test, stateless workloads, CE environments |

**When in doubt, use `boot-volume/`.** It is the production pattern and matches
the primary example in the blog post.

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment (Community Edition works for ephemeral)
- An image named `Ubuntu 22.04` in the PCD image library
- A physical network named `vmnet`
- Your PCD credentials sourced into your shell environment

For `boot-volume/` only:
- Block storage configured in your PCD environment
- The `m1.medium.vol` flavor available

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Usage

Choose a variant, copy the example vars file, and run:

```shell
cd boot-volume   # or: cd ephemeral
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Tear down:

```shell
terraform destroy
```
