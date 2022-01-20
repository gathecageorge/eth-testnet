resource "linode_firewall" "others_firewalls" {
  label = "others_firewall"
  tags  = ["others"]

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
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-beacon-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "9000"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [
    for node in data.linode_instances.all_nodes.instances :
    node.id
    if contains(node.tags, "others")
  ]

  depends_on = [
    data.linode_instances.all_nodes,
  ]
}