[pcd_vms]
%{ for vm in vms }
${vm.name} ansible_host=${vm.access_ip_v4} ansible_user=${ansible_user} ansible_ssh_private_key_file=${ansible_ssh_private_key_file} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor }

[pcd_vms:vars]
ansible_python_interpreter=/usr/bin/python3
