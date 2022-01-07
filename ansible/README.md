# Ansible testnet setup

Automated testnet deploy on Linode

## Setup

Once terraform has run successfully, it will generate ansible inventory.cfg with all servers.

Ansible will then go ahead to setup docker on the machines and setup testnet

## Running ansible

Ansible will connect using ubuntu user already setup on the nodes and use ssh key that was setup also

### Command to run 

``ansible-playbook --ask-become-pass -i inventory.cfg main.yml``

### Sudo password

Provide password for ubuntu user to get sudo access when prompted. Same password in setup in terraform.tfvars

