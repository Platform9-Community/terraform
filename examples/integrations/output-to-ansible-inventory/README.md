# Output to Ansible Inventory

Deploy a fleet of VMs on Private Cloud Director and generate a static Ansible
inventory file from Terraform outputs. Implements the Terraform-then-Ansible
handoff pattern: Terraform provisions infrastructure, Ansible configures it.

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a security group allowing SSH ingress
3. Deploys N volume-backed VMs named sequentially from a prefix
4. Writes a static INI-format Ansible inventory file to disk after apply

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
| `main.tf` | Deploys the VM fleet and writes the Ansible inventory file |
| `inventory.ini.tpl` | Template used to render the inventory file |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

After apply, run Ansible against the generated inventory:

```shell
ansible-playbook -i inventory.ini your-playbook.yml
```

Tear down:

```shell
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `vm_count` | `2` | Number of VMs to deploy |
| `vm_name_prefix` | `tf-ansible-target` | Name prefix for VMs |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium.vol` | Flavor to use for all VMs |
| `network_name` | `vmnet` | Network to attach all VMs to |
| `volume_size` | `20` | Root volume size in GB per VM |
| `ansible_user` | `ubuntu` | SSH user Ansible will connect as |
| `ansible_ssh_private_key_file` | `~/.ssh/id_rsa` | Path to the SSH private key Ansible will use |
| `inventory_output_path` | `./inventory.ini` | Local path to write the generated inventory file |

## Notes

- This example requires the `hashicorp/local` provider (`~> 2.0`) in addition to the OpenStack provider. Terraform installs it automatically on `terraform init`.
- The generated `inventory.ini` file is written locally and excluded from version control via `.gitignore`.
- For dynamic inventory (discovering VMs at Ansible runtime rather than at Terraform apply time), see the openstack.cloud inventory plugin.
