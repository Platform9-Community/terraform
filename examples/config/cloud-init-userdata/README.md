# Cloud-Init User Data

Deploy a VM on Private Cloud Director and configure the guest OS at first boot
using cloud-init user data. Replaces vSphere guest customization specs and
VMware Tools-based post-deploy configuration.

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a security group with SSH and HTTP ingress rules
3. Renders a cloud-init YAML template with hostname, packages, and SSH key
4. Deploys a volume-backed VM with the rendered cloud-init payload as user data
5. At first boot, cloud-init sets the hostname, installs packages, and starts Nginx

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
| `main.tf` | Deploys the VM with rendered cloud-init user data |
| `cloud-init.yaml.tpl` | cloud-init template rendered by Terraform's `templatefile()` function |
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
| `vm_name` | `tf-cloudinit-demo` | Name for the VM and associated resources |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium.vol` | Flavor to use for the VM |
| `network_name` | `vmnet` | Network to attach the VM to |
| `volume_size` | `20` | Root volume size in GB |
| `vm_hostname` | `tf-cloudinit-demo` | Hostname to set inside the guest OS |
| `packages` | `["nginx", "curl", "htop"]` | Packages to install at first boot |
| `ssh_authorized_key` | `""` | SSH public key to inject into the default user's `authorized_keys` |

## Notes

- cloud-init runs before any user logs in. SSH access may not be available
  immediately after the VM reaches running state -- wait for cloud-init to
  finish before connecting.
- The `ssh_authorized_key` variable is optional. If left empty, no additional
  SSH key is injected. Ensure your image already has a key or password
  configured if you leave this empty.
- For more complex post-boot configuration, combine this example with Ansible
  using the [output-to-ansible-inventory](../../integrations/output-to-ansible-inventory/)
  example.
