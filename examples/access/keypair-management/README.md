# Keypair Management

Create and manage multiple named SSH key pairs in Private Cloud Director
as Terraform-tracked resources.

## What This Example Does

1. Creates one or more named key pairs in PCD from SSH public key strings
2. Outputs the names of all managed key pairs

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- Your PCD credentials sourced into your shell environment
- One or more SSH public keys (the contents of `~/.ssh/id_rsa.pub` or equivalent)

## Authentication

Source your RC file from **Settings > API Access** before running:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates named key pairs in PCD using `openstack_compute_keypair_v2` |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

Copy the example vars file and paste in your public key strings:

```shell
cp terraform.tfvars.example terraform.tfvars
```

Get your public key string:

```shell
cat ~/.ssh/id_rsa.pub
```

Paste the output as the value for each key pair entry in `terraform.tfvars`, then:

```shell
terraform init
terraform plan
terraform apply
```

Tear down:

```shell
terraform destroy
```

## Variables

| Variable | Type | Description |
|---|---|---|
| `keypairs` | `map(string)` | Map of key pair names to SSH public key strings |

## Notes

- Key pairs created by this example appear in the PCD UI and can be selected
  when launching VMs.
- To rotate a key, update the public key string in `terraform.tfvars` and run
  `terraform apply`. Terraform will delete the old key pair from PCD and create
  a new one.
- Public key strings are not sensitive and are safe to store in
  `terraform.tfvars`, but keep that file out of version control regardless as
  it may contain other values you don't want committed.
