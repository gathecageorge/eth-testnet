# create ssh key to be used by all linodes root ssh
resource "linode_sshkey" "root_access" {
  label = "root_access"
  ssh_key = chomp(var.instance_root_ssh_key)
}

# create all linodes needed for each type
module "multiple_linodes_instances" {
  source = "./modules/multiple_linodes"

  for_each = var.instance_types

  instance_group         = each.key
  number_instances       = each.value.count
  instance_image         = each.value.image
  instance_regions        = each.value.regions
  instance_type          = each.value.type
  instance_root_ssh_key  = linode_sshkey.root_access.ssh_key
  instance_root_password = var.instance_root_password
}

# output ips of all created instances
output "all_instances_server_ips" {
  description = "All servers ip addresses"
  value = { 
    for key in keys(var.instance_types):
      key => module.multiple_linodes_instances[key].server_ips
  }
}