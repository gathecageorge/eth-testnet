resource "linode_instance" "instances" {
  count = var.number_instances

  label           = "${var.instance_label}${count.index}"
  image           = var.instance_image
  region          = element(var.instance_regions, count.index)
  type            = var.instance_type
  root_pass       = var.instance_ubuntu_password
  authorized_keys = var.access_ssh_keys_array
  booted          = (var.instance_label == "globalfederation" || var.instance_label == "geth" || var.instance_label == "dclocal") ? "true" : var.booted_status

  stackscript_id = var.stackscript_id
  stackscript_data = {
    "instance_ubuntu_password" = var.instance_ubuntu_password
  }
  
  group = var.instance_group
  tags = (var.instance_label == "globalfederation") ? [var.instance_label] : (
    (var.instance_label == "geth") ? [var.instance_label, "rw_dclocal${count.index % var.total_dclocal}"] : (
      (var.instance_label == "dclocal") ? [var.instance_label, "rw_globalfederation${count.index % var.total_globalfederation}"] : (
        [
          var.instance_label,
          "geth_geth${count.index % var.total_geth}",
          "rw_dclocal${count.index % var.total_dclocal}",
          "testnet",
          element(var.class_groups, count.index)
        ]
      )
    )
  )

  private_ip       = true
  watchdog_enabled = true
  swap_size        = 512
}