resource "openstack_compute_instance_v2" "boot-from-volume" {
  count           = var.instance_count
  name            = format("${var.instance_prefix}-%02d", count.index + 1)
  flavor_name     = var.flavor
  security_groups = ["default"]

  block_device {
    uuid                  = var.image_uuid
    source_type           = "image"
    volume_size           = 40
    boot_index            = 0
    destination_type      = "volume"
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }
  user_data = <<EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - nginx
    password: winterwonderland
    chpasswd: { expire: False }
    ssh_pwauth: True
    manage_etc_hosts: true
    runcmd:
      - ["sh", "-c", "echo '<h1>Welcome to Cox</h1>' > /var/www/html/index.html"]
      - ["systemctl", "enable", "nginx"]
      - ["systemctl", "start", "nginx"]
  EOF
}
