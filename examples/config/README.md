# Configuration Examples

Terraform examples for guest OS configuration on Private Cloud Director.

## Examples

| Directory | Description |
|---|---|
| [cloud-init-userdata](cloud-init-userdata/) | Pass cloud-init user data to a VM at boot to set hostname, install packages, and inject SSH keys |

## Notes

- cloud-init runs at first boot before any user logs in. It replaces vSphere guest
  customization specs and VMware Tools-based post-deploy configuration.
- The `cloud-init.yaml.tpl` template file in each example is rendered by Terraform's
  `templatefile()` function at plan time and passed to the instance as `user_data`.
- For more complex guest configuration after boot, see the Ansible examples in the
  [Platform9-Community/ansible](https://github.com/Platform9-Community/ansible) repo.
