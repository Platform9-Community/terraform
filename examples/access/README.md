# Access Examples

Terraform examples for managing SSH key pairs and access resources on
Private Cloud Director.

## Examples

| Directory | Description |
|---|---|
| [keypair-management](keypair-management/) | Create and manage multiple named SSH key pairs as Terraform-tracked resources |

## Notes

- Managing key pairs in Terraform state gives you an auditable record of
  which keys exist in your environment and makes rotation straightforward:
  update the public key string in `terraform.tfvars` and run `terraform apply`.
- Public key strings are not sensitive, but keep `terraform.tfvars` out of
  version control regardless -- it may contain other values you don't want
  to commit.
