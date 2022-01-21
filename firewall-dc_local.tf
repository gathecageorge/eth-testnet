resource "linode_firewall" "dc_local_firewalls" {
  for_each = {
    for node in data.linode_instances.all_nodes.instances :
    node.label => { id : node.id, region : node.region, ip_address : node.ip_address }
    if contains(node.tags, "dc_local")
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
    label    = "allow-prometheus-remote-write"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "9090"
    ipv4 = [
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if contains(node.tags, "rw_${each.key}")
    ]
    ipv6 = []
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [each.value.id]

  depends_on = [
    data.linode_instances.all_nodes,
  ]
}