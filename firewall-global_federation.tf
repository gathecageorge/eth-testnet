resource "linode_firewall" "global_federation_firewalls" {
  for_each = {
    for node in module.multiple_linodes_instances["global_federation"].servers_information :
    node.label => { id : node.id, region : node.region, ip_address : node.ip_address }
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
    label    = "allow-grafana"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3000"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-thanos-query"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10902"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-thanos-receive"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10903"
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
}