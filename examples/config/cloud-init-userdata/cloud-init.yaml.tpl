#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

%{ if ssh_authorized_key != "" }
ssh_authorized_keys:
  - ${ssh_authorized_key}
%{ endif }

packages:
%{ for pkg in packages }
  - ${pkg}
%{ endfor }

package_update: true
package_upgrade: false

runcmd:
  - systemctl enable nginx
  - systemctl start nginx
