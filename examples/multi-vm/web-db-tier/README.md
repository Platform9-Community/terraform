# Two-Tier Web and Database

Deploy a two-tier architecture with a web VM and a database VM on Private
Cloud Director. Security groups enforce tier isolation: MySQL port 3306 is
only accessible from the web tier security group, not from the internet.

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a web tier security group allowing SSH, HTTP, and HTTPS from anywhere
3. Creates a DB tier security group allowing SSH from anywhere and MySQL only from the web tier
4. Deploys a web VM and a DB VM, each with their own root volume
5. Outputs the IP addresses and security group IDs for both tiers

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- An image named `Ubuntu 22.04` in the PCD image library
- The `m1.medium.vol` flavor available in your environment (web tier)
- The `m1.large.vol` flavor available in your environment (DB tier)
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
| `main.tf` | Creates both tiers with security group isolation between them |
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
| `web_flavor` | `m1.medium.vol` | Flavor for the web tier VM |
| `db_flavor` | `m1.large.vol` | Flavor for the database tier VM |
| `network_name` | `vmnet` | Network to attach both VMs to |
| `volume_size` | `20` | Root volume size in GB (applies to both VMs) |

## Notes

- If `m1.large.vol` is not available in your environment, update `db_flavor`
  in `terraform.tfvars` to a flavor that exists.
- The DB security group uses `remote_group_id` to restrict MySQL access to
  VMs in the web security group only -- not a CIDR range. This means the rule
  automatically applies to any VM added to the web security group later.
- Both VMs are on the same network in this example. In a production setup you
  would typically place them on separate tenant networks with routing controlled
  at the router level.
