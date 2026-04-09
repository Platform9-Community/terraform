# Additional Volumes

Deploy a VM on Private Cloud Director with a root volume plus separate data
and log volumes. Equivalent to adding extra VMDKs to a VM in vSphere.

## What This Example Does

1. Looks up an existing image and network by name
2. Creates a security group with SSH and ICMP ingress rules
3. Creates a root volume, a data volume, and a log volume
4. Deploys a VM booted from the root volume
5. Attaches the data and log volumes to the VM as additional block devices
6. Outputs the VM ID, IP address, and volume IDs

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
| `main.tf` | Creates the VM with root, data, and log volumes attached |
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
| `vm_name` | `tf-multivol-demo` | Name for the VM and associated resources |
| `image_name` | `Ubuntu 22.04` | Image name in the PCD image library |
| `flavor_name` | `m1.medium.vol` | Flavor to use for the VM |
| `network_name` | `vmnet` | Network to attach the VM to |
| `root_volume_size` | `20` | Root volume size in GB |
| `data_volume_size` | `50` | Data volume size in GB |
| `log_volume_size` | `20` | Log volume size in GB |

## Notes

- Data and log volumes are created without an image -- they are empty block
  devices that must be formatted and mounted inside the guest OS after boot.
- Volumes persist independently of the VM. `terraform destroy` will delete
  the volumes because they were created by this Terraform configuration. If
  you want to preserve them, remove the volume resources from state before
  destroying.
- Additional volumes appear as block devices inside the guest (e.g. `/dev/vdb`,
  `/dev/vdc`). Partition, format, and mount them manually or via cloud-init.
