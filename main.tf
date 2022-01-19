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

  total_eth1              = lookup(var.instance_types, "eth1", { count = 0, type = "", image = "" }).count
  total_dc_local          = lookup(var.instance_types, "dc_local", { count = 0, type = "", image = "" }).count
  total_global_federation = lookup(var.instance_types, "global_federation", { count = 0, type = "", image = "" }).count

  instance_group           = var.instance_group
  instance_label           = each.key
  number_instances         = each.value.count
  instance_image           = each.value.image
  instance_regions         = var.dc_regions
  instance_type            = each.value.type
  access_ssh_keys_array    = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]
  instance_ubuntu_password = var.instance_ubuntu_password
}

output "total_ssh_keys" {
  value = length(linode_sshkey.ssh_access_keys)
}

output "all_instances_information" {
  description = "All servers information"
  value = {
    for key in keys(var.instance_types) :
    key => module.multiple_linodes_instances[key].*
  }
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "./ansible/inventory.ini"
  content = templatefile("./templates/inventory.tftpl", {
    servers = {
      for key in keys(var.instance_types) :
      key => {
        for servername, data in module.multiple_linodes_instances[key].servers_information :
        servername => {
          ip                = data.ip,
          eth1              = length(data.eth1) == 0 ? "" : replace(data.eth1[0], "use_", ""),
          dc_local          = length(data.dc_local) == 0 ? "" : replace(data.dc_local[0], "use_", ""),
          global_federation = length(data.global_federation) == 0 ? "" : replace(data.global_federation[0], "use_", "")
        }
      }
    }
  })
}