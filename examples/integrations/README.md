# Integration Examples

Terraform examples demonstrating how PCD infrastructure output integrates
with other tools in the automation stack.

## Examples

| Directory | Description |
|---|---|
| [output-to-ansible-inventory](output-to-ansible-inventory/) | Generate a static Ansible inventory file from Terraform outputs to enable the Terraform-then-Ansible handoff pattern |

## Notes

- The `output-to-ansible-inventory` example requires the `hashicorp/local`
  provider (`~> 2.0`) in addition to the OpenStack provider. Terraform will
  download it automatically on `terraform init`.
- The generated `inventory.ini` file is written to the path specified in
  `inventory_output_path` (default: `./inventory.ini`). This file is excluded
  from version control via `.gitignore`.
- Pass the generated inventory directly to Ansible:
  `ansible-playbook -i inventory.ini your-playbook.yml`
