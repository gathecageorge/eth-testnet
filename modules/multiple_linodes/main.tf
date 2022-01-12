resource "linode_instance" "instances" {
  count = var.number_instances

  label           = "${var.instance_group}-${count.index}"
  image           = var.instance_image
  region          = element(var.instance_regions, count.index)
  type            = var.instance_type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = [var.access_ssh_key]

  provisioner "remote-exec" {
    inline = [
      "useradd ubuntu -m -d /home/ubuntu",
      "echo ubuntu:${var.instance_ubuntu_password} | chpasswd",
      "usermod -s /bin/bash -aG sudo ubuntu",
      "mkdir -p /home/ubuntu/.ssh",
      "mv /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh/",
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

  group      = var.instance_group
  tags       = [var.instance_group]
  private_ip = true
}