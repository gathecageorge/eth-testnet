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

locals {
  geth_count              = lookup(var.global_instance_types, "geth", { count = 0, type = "", image = "", client = "", test = "" }).count
  globalfederation_count  = lookup(var.global_instance_types, "globalfederation", { count = 0, type = "", image = "", client = "", test = "" }).count
  dclocal_count           = lookup(var.testnet_instance_types, "dclocal", { count = 0, type = "", image = "" }).count

  config_testnet_servers = distinct(flatten([ 
    for testname in var.parallel_tests : [
      for clientname, clientdata in var.testnet_instance_types : {
        test = testname
        client = clientname
        data = merge(clientdata, {test = testname, client = clientname})
      }
    ]
  ]))

  testnet_create_servers = {
    for entry in local.config_testnet_servers :
      "${entry.test}${entry.client}" => entry.data
  }

  all_create_servers = merge(var.global_instance_types, local.testnet_create_servers)

  config_created_all_servers = distinct(flatten([ 
    for key in keys(local.all_create_servers) : [
      for serverlabel, data in module.multiple_linodes_instances[key].servers_information : {
        serverlabel = serverlabel
        data = {
          region  = data.region,
          id      = data.id,
          ip      = data.ip_address,
          pip     = data.private_ip_address,
          ipv6    = data.ipv6,
          grp     = length(data.grp) == 0 ? "" : data.grp[0],
          geth    = length(data.geth) == 0 ? "" : replace(data.geth[0], "geth_", ""),
          rw      = length(data.rw) == 0 ? "" : replace(data.rw[0], "rw_", ""),
          client  = data.client,
          tags    = data.tags,
          test    = local.all_create_servers[key].test
        }
      }
    ]
  ]))

  created_all_servers = {
    for entry in local.config_created_all_servers :
      "${entry.serverlabel}" => entry.data
  }

  logging_servers = {
    for key in keys(var.global_instance_types) :
      key => {
        for serverlabel, data in module.multiple_linodes_instances[key].servers_information :
        serverlabel => serverlabel
      }
  }

  client_created_servers = {
    for client in keys(var.testnet_instance_types) :
      client => {
        for serverlabel, data in local.created_all_servers :
        serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
        if length(regexall(".*${client}.*", serverlabel)) == 1
      }
    if client != "dclocal"
  }

  dclocal_created_servers = {
    for serverlabel, data in local.created_all_servers :
      serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
    if data.client == "dclocal"
  }

  dclocal_pertest_created_servers = {
    for test in var.parallel_tests :
      test => {
        for serverlabel, data in local.created_all_servers :
        serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
        if data.client == "dclocal" && length(regexall("^${test}.*", serverlabel)) == 1
      }
  }

  testnet_created_servers = {
    for test in var.parallel_tests :
      test => {
        for serverlabel, data in local.created_all_servers :
        serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
        if data.client != "dclocal" && length(regexall("^${test}.*", serverlabel)) == 1
      }
  }
}

# create multiple linodes needed for each type
module "multiple_linodes_instances" {
  source = "./modules/multiple_linodes"

  for_each = local.all_create_servers

  class_groups           = var.class_groups
  total_geth             = local.geth_count
  total_dclocal          = local.dclocal_count
  total_globalfederation = local.globalfederation_count

  stackscript_id           = linode_stackscript.non_root_login_script.id
  instance_group           = var.instance_group
  instance_label           = each.key
  number_instances         = each.value.count
  clientname               = each.value.client
  testname                 = each.value.test
  instance_image           = each.value.image
  instance_regions         = var.dc_regions
  instance_type            = each.value.type
  access_ssh_keys_array    = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]
  instance_ubuntu_password = var.instance_ubuntu_password
  booted_status            = var.booted_status
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "./ansible/inventory.ini"
  content = templatefile("./templates/inventory.tftpl", {
    all_servers                     = local.created_all_servers,
    logging_servers                 = local.logging_servers,
    client_created_servers          = local.client_created_servers,
    dclocal_created_servers         = local.dclocal_created_servers,
    dclocal_pertest_created_servers = local.dclocal_pertest_created_servers
    testnet_created_servers         = local.testnet_created_servers,
  })
}
