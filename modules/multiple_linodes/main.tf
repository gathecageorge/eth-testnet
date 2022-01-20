resource "linode_instance" "instances" {
  count = var.number_instances

  label           = "${var.instance_label}-${count.index}"
  image           = var.instance_image
  region          = element(var.instance_regions, count.index)
  type            = var.instance_type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = var.access_ssh_keys_array

  provisioner "remote-exec" {
    inline = [
      "useradd ubuntu -m -d /home/ubuntu",
      "echo ubuntu:${var.instance_ubuntu_password} | chpasswd",
      "usermod -s /bin/bash -aG sudo ubuntu",
      "mkdir -p /home/ubuntu/.ssh",
      "mv /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh/",
      "echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/ubuntu",
      "passwd -d root",
      "sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config",
      "sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "service ssh reload"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = var.instance_ubuntu_password
      host     = self.ip_address
    }
  }

  group = var.instance_group
  tags = (var.instance_label == "global_federation") ? [var.instance_label] : (
    (var.instance_label == "eth1") ? [var.instance_label, "rw_dc_local-${count.index % var.total_dc_local}"] : (
      (var.instance_label == "dc_local") ? [var.instance_label, "rw_global_federation-${count.index % var.total_global_federation}"] : (
        [
          var.instance_label,
          "others",
          "geth_eth1-${count.index % var.total_eth1}",
          "rw_dc_local-${count.index % var.total_dc_local}",
        ]
      )
    )
  )

  private_ip = true
}