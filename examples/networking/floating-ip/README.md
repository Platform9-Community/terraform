# Floating IP

Deploy a VM on a tenant network and associate a floating IP for external
access. Equivalent to a static one-to-one NAT rule on an NSX edge or a
vSphere VM with a NAT mapping through an external firewall.

## What This Example Does

1. Looks up an existing image, tenant network, and provider network
2. Creates a security group with SSH and ICMP ingress rules
3. Creates a bootable root volume
4. Creates a network port on the tenant network
5. Deploys a VM attached to the port
6. Allocates a floating IP from the provider network and associates it with the VM's port

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment with SDN enabled
- An image named `Ubuntu 22.04` in the PCD image library
- A tenant network with a router that has an external gateway (see [network-with-router](../network-with-router/))
- An existing provider network to allocate floating IPs from (default: `vmnet`)
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates the security group, port, volume, VM, and floating IP association |
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
| `vm_name` | `tf-floating-ip-demo` | Name for the VM and associated resources |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium.vol` | Flavor to use for the VM |
| `network_name` | `demo-network` | Tenant network to attach the VM to |
| `external_network_name` | `vmnet` | Provider network to allocate the floating IP from |
| `volume_size` | `20` | Root volume size in GB |

## Notes

- The tenant network must have a router with an external gateway configured. The network-with-router example creates this.
- Provider v3 of the OpenStack Terraform provider requires floating IP association via `openstack_networking_floatingip_associate_v2` (Neutron port-based), not the deprecated Nova-based `openstack_compute_floatingip_associate_v2`. An explicit port resource is created to enable this.
