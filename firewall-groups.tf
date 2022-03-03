resource "linode_firewall" "groups_firewalls" {
  for_each = {
    for group in var.class_groups :
    group => group
  }

  label = "${each.key}_firewall"
  tags  = ["${each.key}"]

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-beacon-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "9000"
    ipv4     = (var.groups_peering == "true") ? ["0.0.0.0/0"] : ([
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if contains(node.tags, "${each.key}")
    ])
    ipv6     = []
  }

  inbound {
    label    = "allow-beacon-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "9000"
    ipv4     = (var.groups_peering == "true") ? ["0.0.0.0/0"] : ([
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if contains(node.tags, "${each.key}")
    ])
    ipv6     = []
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [
    for node in data.linode_instances.all_nodes.instances :
    node.id
    if contains(node.tags, "${each.key}")
  ]
}