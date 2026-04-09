# Terraform Community Resources for Platform9

Community-contributed Terraform configurations, modules, and examples for
[Private Cloud Director](https://platform9.com/private-cloud-director/).

## Contents

- [examples/](examples/) — Standalone Terraform examples from Platform9 blog
  posts and community contributions

## Prerequisites

Most examples in this repo require:

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.0+
- The [HashiCorp OpenStack Terraform provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
  (installed automatically by `terraform init`)
- A running Private Cloud Director environment
- Your PCD credentials sourced from the RC file at **Settings > API Access**

## Authentication

Terraform authenticates to PCD using standard OpenStack environment variables.
Source your RC file before running any example:

```shell
source ~/pcdctlrc
```

## Contributing

Contributions are welcome. Please include a README in your example directory
that explains what the example does, what prerequisites it requires, and how
to run it.

Never commit credentials, RC files, `clouds.yaml`, or `.tfstate` files.
The `.gitignore` in this repo covers the most common cases, but always
double-check before opening a pull request.

## License

[Apache 2.0](LICENSE)
