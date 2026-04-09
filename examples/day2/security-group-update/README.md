# Security Group Update

Manage a security group with toggleable rules on Private Cloud Director.
Demonstrates how Terraform adds or removes only the affected rules on
`terraform apply` without modifying others -- no restart required.

## What This Example Does

1. Creates a security group managed entirely by Terraform
2. Uses boolean variables and `count` to conditionally create or destroy
   individual rules
3. Supports SSH, ICMP, HTTP, HTTPS, and custom TCP port rules

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- Your PCD credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates the security group with conditionally enabled rules |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

Initial deployment:

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

To add or remove rules, toggle the boolean variables in `terraform.tfvars` and apply again:

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
| `security_group_name` | `tf-managed-sg` | Name of the security group |
| `allow_ssh` | `true` | Allow SSH (port 22) ingress |
| `allow_icmp` | `true` | Allow ICMP (ping) ingress |
| `allow_http` | `false` | Allow HTTP (port 80) ingress |
| `allow_https` | `false` | Allow HTTPS (port 443) ingress |
| `ssh_cidr` | `0.0.0.0/0` | CIDR to restrict SSH access to |
| `custom_tcp_ports` | `[]` | Additional TCP ports to open |

## Notes

- Rule changes take effect immediately on VMs that reference this security group -- no VM restart required.
- Setting `allow_ssh = false` will lock you out of any VMs using this group if SSH is your only access method. Ensure you have console access before disabling SSH.
- The `ssh_cidr` variable lets you restrict SSH to a specific IP range (e.g. your office CIDR) rather than allowing it from anywhere.
