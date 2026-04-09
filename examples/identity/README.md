# Identity Examples

Terraform examples for managing identity resources on Private Cloud Director.

## Examples

| Directory | Description |
|---|---|
| [project-and-user](project-and-user/) | Create a project (tenant), a user, and assign a role -- the Terraform equivalent of vSphere org/folder RBAC |

## Notes

- Identity operations require admin credentials. Ensure your RC file is sourced
  from an admin account before running these examples.
- A project in PCD is the unit of tenancy. Resources (VMs, volumes, networks)
  are created within a project and isolated from other projects.
- Available roles in PCD are `member`, `manager`, and `admin`.
- The `user_password` variable is marked `sensitive = true` and will not appear
  in Terraform plan or apply output, but it is stored in `terraform.tfstate`.
  Do not commit state files to version control.
- Resources are created in the Default identity domain. If your environment
  uses a different domain, set `domain_id` directly on the project and user
  resources in `main.tf`.
