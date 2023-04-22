# Get ssh keys from github
data "external" "github_usernames_keys" {
  for_each = toset(var.github_usernames)

  program = ["python3", "githubkey.py", "${each.key}"]
}

# create ssh key to be used by all linodes root ssh
resource "linode_sshkey" "ssh_access_keys" {
  for_each = data.external.github_usernames_keys

  label   = "${each.key}_ssh_access_key"
  ssh_key = chomp(each.value.result.key)
}

resource "linode_stackscript" "non_root_login_script" {
  label = "non_root_login_script"
  description = "Setup non root login"
  script = "${file("startscript.sh")}"
  images = ["linode/ubuntu22.04"]
  rev_note = "initial version"
}

resource "linode_instance" "globalfederation_servers" {
  count = var.globalfederation.count

  label           = "globalfederation${count.index + 1}"
  image           = var.globalfederation.image
  region          = element(var.dc_regions_global, count.index)
  type            = var.globalfederation.type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]

  stackscript_id = linode_stackscript.non_root_login_script.id
  stackscript_data = {
    "instance_ubuntu_password" = var.instance_ubuntu_password
  }
  
  group = "globalfederation"
  tags = [var.instance_group]
  private_ip       = true
  watchdog_enabled = true
  swap_size        = 512
}

resource "linode_instance" "geth_servers" {
  count = var.geth.count

  label           = "geth${count.index + 1}"
  image           = var.geth.image
  region          = "us-east"
  type            = var.geth.type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]

  stackscript_id = linode_stackscript.non_root_login_script.id
  stackscript_data = {
    "instance_ubuntu_password" = var.instance_ubuntu_password
  }
  
  group = "rw_globalfederation${(count.index % var.globalfederation.count) + 1}"
  tags = [var.instance_group, "rw_globalfederation${(count.index % var.globalfederation.count) + 1}"]
  private_ip       = true
  watchdog_enabled = true
  swap_size        = 512
}

locals {
  geth_servers_data = {
    for server in linode_instance.geth_servers :
      "${server.label}" => {
        region  = server.region,
        id      = server.id,
        ip      = server.ip_address,
        pip     = server.private_ip_address,
        ipv6    = server.ipv6,
        grp     = "grp",
        geth    = "geth",
        rw      = "rw",
        client  = "geth",
        tags    = server.tags,
        test    = "all",
        testnet = "all",
      }
  }

  config_testnet_servers = distinct(flatten([ 
    for testname in keys(var.parallel_tests) : [
      for clientname, clientdata in var.testnet_instance_types : {
        test = testname
        client = clientname
        testnet = var.parallel_tests[testname].testnet
        data = merge({ count = clientname == "dclocal" ? var.parallel_tests[testname].dclocal : var.parallel_tests[testname].per_client, type = clientdata.type, image = clientdata.image }, {test = testname, client = clientname, testnet = var.parallel_tests[testname].testnet})
      }
    ]
  ]))

  testnet_create_servers = {
    for entry in local.config_testnet_servers :
      "${entry.testnet}${entry.test}${entry.client}" => entry.data
  }

  config_created_all_servers = distinct(flatten([ 
    for key in keys(local.testnet_create_servers) : [
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
          test    = local.testnet_create_servers[key].test,
          testnet = local.testnet_create_servers[key].testnet,
        }
      }
    ]
  ]))

  created_all_servers = {
    for entry in local.config_created_all_servers :
      "${entry.serverlabel}" => entry.data
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
    for test in keys(var.parallel_tests) :
      test => {
        for serverlabel, data in local.created_all_servers :
        serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
        if data.client == "dclocal" && length(regexall("^${var.parallel_tests[test].testnet}${test}.*", serverlabel)) == 1
      }
  }

  testnet_created_servers = {
    for test in keys(var.parallel_tests) :
      test => {
        for serverlabel, data in local.created_all_servers :
        serverlabel => { id = data.id, region : data.region, ip_address : data.ip }
        if data.client != "dclocal" && length(regexall("^${var.parallel_tests[test].testnet}${test}.*", serverlabel)) == 1
      }
  }
}

# create multiple linodes needed for each type
module "multiple_linodes_instances" {
  source = "./modules/multiple_linodes"
  for_each = local.testnet_create_servers

  class_groups           = var.class_groups
  total_geth             = var.geth.count
  total_dclocal          = var.parallel_tests[each.value.test].dclocal
  total_globalfederation = var.globalfederation.count

  stackscript_id           = linode_stackscript.non_root_login_script.id
  instance_group           = var.instance_group
  instance_label           = each.key
  number_instances         = each.value.count
  clientname               = each.value.client
  testname                 = each.value.test
  testnet                  = each.value.testnet
  instance_image           = each.value.image
  instance_regions_global  = var.dc_regions_global
  instance_regions_group1  = var.dc_regions_group1
  instance_regions_group2  = var.dc_regions_group2
  instance_type            = each.value.type
  access_ssh_keys_array    = [for key in linode_sshkey.ssh_access_keys : key.ssh_key]
  instance_ubuntu_password = var.instance_ubuntu_password
  booted_status            = var.parallel_tests[each.value.test].booted
}

# # generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "./ansible/inventory.ini"
  content = templatefile("./templates/inventory.tftpl", {
    globalfederation_servers        = linode_instance.globalfederation_servers
    geth_servers                    = linode_instance.geth_servers
    all_servers                     = local.created_all_servers
    dclocal_created_servers         = local.dclocal_created_servers
    dclocal_pertest_created_servers = local.dclocal_pertest_created_servers
    testnet_created_servers         = local.testnet_created_servers
    client_created_servers          = local.client_created_servers
  })
}
