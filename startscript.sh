#!/bin/bash

#<UDF name="instance_ubuntu_password" label="Secure User Password" />
# INSTANCE_UBUNTU_PASSWORD=
#
#<UDF name="hostname" label="Hostname to set" />
# HOSTNAME=
#
#<UDF name="docker_compose_version" label="Docker compose version" />
# DOCKER_COMPOSE_VERSION=
#
#<UDF name="docker_network_name" label="Docker network name" />
# DOCKER_NETWORK_NAME=

# Setup non root access, user ubuntu
echo "setting ubuntu user" >> /steps.log
useradd ubuntu -m -d /home/ubuntu
echo 'ubuntu:$INSTANCE_UBUNTU_PASSWORD' | chpasswd
usermod -s /bin/bash ubuntu
mkdir -p /home/ubuntu/.ssh
mv /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/ubuntu
passwd -d root
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
service ssh reload
echo "done setting user" >> /steps.log

# Upgrade
echo "updating apt & upgrading" >> /steps.log
apt update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
echo "done updating apt & upgrading" >> /steps.log

# Install docker and net-tools
echo "setting docker sources" >> /steps.log
DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https ca-certificates curl software-properties-common net-tools
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "done setting docker sources" >> /steps.log

echo "setting docker install and network = $DOCKER_NETWORK_NAME" >> /steps.log
apt update && DEBIAN_FRONTEND=noninteractive apt install -y docker-ce
usermod -aG docker ubuntu
docker network create $DOCKER_NETWORK_NAME
echo "done setting docker install" >> /steps.log

# Install docker-compose
echo "setting docker compose version = $DOCKER_COMPOSE_VERSION" >> /steps.log
curl -SL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "done setting docker compose" >> /steps.log

# Set hostname
echo "setting hostname = $HOSTNAME" >> /steps.log
IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname
echo $IPADDR $HOSTNAME >> /etc/hosts
echo "done setting hostname" >> /steps.log

# Set node exporter
echo "setting node exporter" >> /steps.log
docker container run -d --name node-exporter --log-driver json-file --log-opt tag="{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}|default" --restart unless-stopped --network $DOCKER_NETWORK_NAME --volume /etc/machine-id:/etc/machine-id:ro --volume /proc:/host/proc:ro --volume /sys:/host/sys:ro --volume /:/rootfs:ro --user "0:0" prom/node-exporter:latest --path.procfs="/host/proc" --path.rootfs="/rootfs" --path.sysfs="/host/sys" --collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"
echo "done setting node exporter" >> /steps.log

# Set cadvisor
echo "setting cadvisor" >> /steps.log
docker container run -d --name cadvisor --log-driver json-file --log-opt tag="{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}|default" --restart unless-stopped --network $DOCKER_NETWORK_NAME --volume /etc/machine-id:/etc/machine-id:ro --volume /:/rootfs:ro --volume /var/run:/var/run:rw --volume /sys:/sys:ro --volume /var/lib/docker/:/var/lib/docker:ro --user "0:0" gcr.io/cadvisor/cadvisor:v0.47.1
echo "done setting cadvisor" >> /steps.log

echo "finished" > /finished.log

reboot
