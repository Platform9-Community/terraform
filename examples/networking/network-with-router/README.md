# Network with Router

Create a tenant network, subnet, and virtual router with an external gateway
on Private Cloud Director. Equivalent to creating a vSphere distributed port
group with an NSX edge for north-south routing.

## What This Example Does

1. Looks up an existing provider network by name
2. Creates a tenant network and subnet with a specified CIDR
3. Creates a virtual router with the provider network as its external gateway
4. Attaches the subnet to the router

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment with SDN enabled
- An existing provider network (default: `vmnet`)
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates the network, subnet, router, and router interface |
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
| `network_name` | `demo-network` | Name for the new tenant network |
| `subnet_name` | `demo-subnet` | Name for the subnet |
| `subnet_cidr` | `192.168.100.0/24` | CIDR block for the subnet |
| `dns_nameservers` | `["8.8.8.8", "8.8.4.4"]` | DNS nameservers for the subnet |
| `router_name` | `demo-router` | Name for the virtual router |
| `external_network_name` | `vmnet` | Existing provider network for the router's external gateway |

## Notes

- This example is a prerequisite for the floating-ip example, which requires a tenant network with a router to allocate floating IPs.
- SDN must be enabled in your PCD environment to create tenant networks and routers.
