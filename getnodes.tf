data "linode_instances" "all_nodes" {
  filter {
    name   = "tags"
    values = [var.instance_group]
  }


  depends_on = [
    module.multiple_linodes_instances,
  ]
}
