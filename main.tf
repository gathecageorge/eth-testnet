# create ssh key to be used by all linodes root ssh
resource "linode_sshkey" "ssh_access_keys" {
  for_each = var.access_ssh_keys

  label   = "${each.key}_ssh_access_key"
  ssh_key = chomp(each.value)
}

# create all linodes needed for each type
module "multiple_linodes_instances" {
  source = "./modules/multiple_linodes"

  for_each = var.instance_types

  instance_group           = each.key
  number_instances         = each.value.count
  instance_image           = each.value.image
  instance_regions         = var.dc_regions
  instance_type            = each.value.type
  access_ssh_keys_array    = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]
  instance_ubuntu_password = var.instance_ubuntu_password
}

# output ips of all created instances
output "all_instances_server_ips" {
  description = "All servers ip addresses"
  value = {
    for key in keys(var.instance_types) :
    key => module.multiple_linodes_instances[key].server_ips
  }
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "./ansible/inventory.ini"
  content = templatefile("./templates/inventory.tftpl", {
    servers = {
      for key in keys(var.instance_types) :
      key => module.multiple_linodes_instances[key].server_ips
    }
  })
}