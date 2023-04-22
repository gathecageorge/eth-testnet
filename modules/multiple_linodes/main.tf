resource "linode_instance" "instances" {
  count = var.number_instances

  label           = "${var.instance_label}${format("%03d", count.index + 1)}"
  image           = var.instance_image

  # If dclocal then use global regions
  # Check the group the node belongs to, either group1 or group2 using "(element(var.class_groups, count.index) == "group1")"
  # If belongs to group 1 use regions from group 1 NB: Since 2 regions, the index needs to be divided by 2 to get correct one
  # If belongs to group 2 use regions from group 2  NB: Since 2 regions and odd number, needs to minus 1 and divide by 2
  region          = (var.clientname == "dclocal") ? element(var.instance_regions_global, count.index) : (
    (element(var.class_groups, count.index) == "group1") ? element(var.instance_regions_group1, count.index / 2) : element(var.instance_regions_group2, (count.index - 1) / 2)
  )
  type            = var.instance_type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = var.access_ssh_keys_array
  booted          = var.booted_status

  stackscript_id = var.stackscript_id
  stackscript_data = {
    "instance_ubuntu_password" = var.instance_ubuntu_password
  }
  
  group = var.clientname
  tags = (var.clientname == "dclocal") ? [var.instance_group, "rw_globalfederation${(count.index % var.total_globalfederation) + 1}", "${var.testname}"] : (
    [
      var.instance_group,
      "geth_geth${(count.index % var.total_geth) + 1}",
      "rw_${var.testnet}${var.testname}dclocal${format("%03d", (count.index % var.total_dclocal) + 1)}",
      "${var.testname}",
      element(var.class_groups, count.index)
    ]
  )

  private_ip       = true
  watchdog_enabled = true
  swap_size        = 512
}