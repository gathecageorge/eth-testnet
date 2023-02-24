#!/bin/bash

# <UDF name="instance_ubuntu_password" Label="Secure User Password" />

useradd ubuntu -m -d /home/ubuntu
echo 'ubuntu:$instance_ubuntu_password' | chpasswd
usermod -s /bin/bash -aG sudo ubuntu
mkdir -p /home/ubuntu/.ssh
mv /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/ubuntu
passwd -d root
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
service ssh reload
apt update && apt upgrade
