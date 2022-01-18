resource "linode_firewall" "eth1_firewalls" {
  for_each = {
    for node in data.linode_instances.all_nodes.instances :
    node.label => { id : node.id, region : node.region, ip_address : node.ip_address }
    if contains(node.tags, "eth1")
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
    label    = "allow-go-ethereum"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "30303"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-go-ethereum-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "30303"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-8545"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8545"
    ipv4 = [
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if contains(node.tags, "use_${each.key}")
    ]
    ipv6 = []
  }

  inbound {
    label    = "allow-8546"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8546"
    ipv4 = [
      for node in data.linode_instances.all_nodes.instances :
      "${node.ip_address}/32"
      if contains(node.tags, "use_${each.key}")
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