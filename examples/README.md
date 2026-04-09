# Examples

Standalone Terraform examples for Private Cloud Director. Each subdirectory
corresponds to a blog post or community-contributed scenario and includes
everything needed to run it independently.

## Categories

| Directory | Description |
|---|---|
| [vm-quickstart](vm-quickstart/) | Deploy a VM -- boot-volume (persistent) and ephemeral variants |
| [networking](networking/) | Tenant networks, routers, and floating IPs |
| [multi-vm](multi-vm/) | Multi-VM fleets and multi-tier architectures |
| [storage](storage/) | Additional volumes and snapshots |
| [images](images/) | Image upload and management |
| [access](access/) | SSH key pair management |
| [day2](day2/) | VM resize, security group updates, and other day-2 operations |

## Getting Started

All examples follow the same pattern:

```shell
cd <example-directory>
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars for your environment
terraform init
terraform plan
terraform apply
```

Tear down any example with:

```shell
terraform destroy
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.0+
- A running Private Cloud Director environment
- Your PCD credentials sourced from the RC file at **Settings > API Access**

```shell
source ~/pcdctlrc
```

## Contributing

Contributions are welcome. Please include a `README.md` in your example
directory that explains what the example does, what prerequisites it requires,
and how to run it. Include a `terraform.tfvars.example` with commented
placeholder values for all variables.

Never commit credentials, RC files, `clouds.yaml`, `.tfstate` files, or
`terraform.tfvars` files. The `.gitignore` at the repo root covers the most
common cases, but always double-check before opening a pull request.
