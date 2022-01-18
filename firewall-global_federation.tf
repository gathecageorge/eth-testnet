resource "linode_firewall" "global_federation_firewalls" {
  label = "global_federation_firewall"
  tags  = ["global_federation"]

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
    label    = "allow-prometheus"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "9090"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [
    for node in data.linode_instances.all_nodes.instances :
    node.id
    if contains(node.tags, "global_federation")
  ]

  depends_on = [
    data.linode_instances.all_nodes,
  ]
}