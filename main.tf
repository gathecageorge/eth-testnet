# create ssh key to be used by all linodes root ssh
resource "linode_sshkey" "ssh_access_keys" {
  for_each = var.access_ssh_keys

  label   = "${each.key}_ssh_access_key"
  ssh_key = chomp(each.value)
}

resource "linode_stackscript" "non_root_login_script" {
  label = "non_root_login_script"
  description = "Setup non root login"
  script = "${file("startscript.sh")}"
  images = ["linode/ubuntu20.04"]
  rev_note = "initial version"
}

# create all linodes needed for each type
module "multiple_linodes_instances" {
  source = "./modules/multiple_linodes"

  for_each = var.instance_types

  class_groups           = var.class_groups
  total_geth             = lookup(var.instance_types, "geth", { count = 0, type = "", image = "" }).count
  total_dclocal          = lookup(var.instance_types, "dclocal", { count = 0, type = "", image = "" }).count
  total_globalfederation = lookup(var.instance_types, "globalfederation", { count = 0, type = "", image = "" }).count

  stackscript_id           = linode_stackscript.non_root_login_script.id
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
  value = length({
    for key in keys(var.instance_types) :
    key => module.multiple_linodes_instances[key].*
  })
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
          ip    = data.ip_address,
          pip   = data.private_ip_address,
          geth  = length(data.geth) == 0 ? "" : replace(data.geth[0], "geth_", ""),
          rw    = length(data.rw) == 0 ? "" : replace(data.rw[0], "rw_", "")
        }
      }
    }
  })
}

# resource "linode_instance" "stack_script_test" {
#   image             = "linode/ubuntu20.04"
#   label             = "stack_script_test"
#   region            = "us-east"
#   type              = "g6-nanode-1"
#   authorized_keys   = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]
#   root_pass         = var.instance_ubuntu_password

#   stackscript_id    = linode_stackscript.non_root_login_script.id
#   stackscript_data  = {
#     "instance_ubuntu_password" = var.instance_ubuntu_password
#   }
# }