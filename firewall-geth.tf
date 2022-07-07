resource "linode_firewall" "geth_firewalls" {
  for_each = try({
    for node in module.multiple_linodes_instances["geth"].servers_information :
    node.label => { id : node.id, region : node.region, ip_address : node.ip_address }
  }, {})

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
    label    = "allow-go-ethereum-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "30303"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = []
  }

  inbound {
    label    = "allow-go-ethereum-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "30303"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = []
  }

  inbound {
    label    = "allow-8545"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8545"
    ipv4 = concat(["${each.value.ip_address}/32"], [
      for node in local.created_all_servers :
      "${node.ip}/32"
      if contains(node.tags, "geth_${each.key}")
    ])
    ipv6 = []
  }

  inbound {
    label    = "allow-8546"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8546"
    ipv4 = concat(["${each.value.ip_address}/32"], [
      for node in local.created_all_servers :
      "${node.ip}/32"
      if contains(node.tags, "geth_${each.key}")
    ])
    ipv6 = []
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [each.value.id]
}