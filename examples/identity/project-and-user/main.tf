terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
  }
}

provider "openstack" {}

# --- Variables ---

variable "project_name" {
  description = "Name for the new project (tenant)"
  default     = "tf-demo-project"
}

variable "project_description" {
  description = "Description for the project"
  default     = "Created by Terraform"
}

variable "username" {
  description = "Username for the new user"
  default     = "tf-demo-user"
}

variable "user_password" {
  description = "Password for the new user"
  sensitive   = true
}

variable "role_name" {
  description = "Role to assign the user in the project. Available roles: member, manager, admin"
  default     = "member"
}

# --- Look up role ---

data "openstack_identity_role_v3" "role" {
  name = var.role_name
}

# --- Project ---
# A project in PCD is the unit of tenancy -- equivalent to a vSphere
# organization or folder boundary. Resources (VMs, volumes, networks)
# are created within a project and isolated from other projects.

resource "openstack_identity_project_v3" "project" {
  name        = var.project_name
  description = var.project_description
  enabled     = true
}

# --- User ---

resource "openstack_identity_user_v3" "user" {
  name               = var.username
  password           = var.user_password
  default_project_id = openstack_identity_project_v3.project.id
  enabled            = true
}

# --- Role assignment ---
# Grants the user the specified role in the project. Without a role
# assignment, the user can authenticate but cannot access project resources.

resource "openstack_identity_role_assignment_v3" "assignment" {
  user_id    = openstack_identity_user_v3.user.id
  project_id = openstack_identity_project_v3.project.id
  role_id    = data.openstack_identity_role_v3.role.id
}

# --- Outputs ---

output "project_id" {
  value = openstack_identity_project_v3.project.id
}

output "user_id" {
  value = openstack_identity_user_v3.user.id
}

output "role_assignment" {
  value = "User '${var.username}' assigned role '${var.role_name}' in project '${var.project_name}'"
}
