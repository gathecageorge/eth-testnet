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
    ipv6     = []
  }

  inbound {
    label    = (var.groups_peering == "true") ? "allow-beacon-tcp" : "drop-beacon-other-group-tcp"
    action   = (var.groups_peering == "true") ? "ACCEPT" : "DROP"
    protocol = "TCP"
    ports    = "9000"
    ipv4     = (var.groups_peering == "true") ? ["0.0.0.0/0"] : ([
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if !contains(node.tags, "${each.key}")
    ])
    ipv6 = (var.groups_peering == "true") ? [] : ["::/0"]
  }

  inbound {
    label    = (var.groups_peering == "true") ? "allow-beacon-udp" : "drop-beacon-other-group-udp"
    action   = (var.groups_peering == "true") ? "ACCEPT" : "DROP"
    protocol = "UDP"
    ports    = "9000"
    ipv4     = (var.groups_peering == "true") ? ["0.0.0.0/0"] : ([
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if !contains(node.tags, "${each.key}")
    ])
    ipv6 = (var.groups_peering == "true") ? [] : ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [
    for node in data.linode_instances.all_nodes.instances :
    node.id
    if contains(node.tags, "${each.key}")
  ]
}