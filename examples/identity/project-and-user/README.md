# Project and User

Create a project (tenant), a user, and assign a role in Private Cloud Director
using Terraform. Equivalent to creating a vSphere organization or folder
boundary with RBAC.

## What This Example Does

1. Creates a new project (tenant) in PCD
2. Creates a new user assigned to that project
3. Looks up a role by name and assigns it to the user in the project

## Prerequisites

- Terraform 1.0+
- A running Private Cloud Director environment
- Admin credentials sourced into your shell environment

## Authentication

Source your RC file from **Settings > API Access** before running. Admin
credentials are required for identity operations:

```shell
source ~/pcdctlrc
```

## Files

| File | Description |
|---|---|
| `main.tf` | Creates the project, user, and role assignment |
| `terraform.tfvars.example` | Example variable values -- copy to `terraform.tfvars` and edit |

## Usage

Copy the example vars file and edit it:

```shell
cp terraform.tfvars.example terraform.tfvars
```

Then:

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

| Variable | Default | Description |
|---|---|---|
| `project_name` | `tf-demo-project` | Name for the new project |
| `project_description` | `Created by Terraform` | Description for the project |
| `username` | `tf-demo-user` | Username for the new user |
| `user_password` | _(required)_ | Password for the new user |
| `role_name` | `member` | Role to assign -- available roles: `member`, `manager`, `admin` |

## Notes

- `user_password` has no default and must be set in `terraform.tfvars`. It is
  marked `sensitive = true` and will not appear in plan or apply output, but
  it is stored in `terraform.tfstate`. Do not commit state files or
  `terraform.tfvars` to version control.
- Resources are created in the Default identity domain. If your environment
  uses a different domain, set `domain_id` directly on the project and user
  resources in `main.tf`.
