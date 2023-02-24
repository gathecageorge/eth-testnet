resource "linode_firewall" "globalfederation_firewalls" {
  for_each = try({
    for node in resource.linode_instance.globalfederation_servers :
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
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = []
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = []
  }

  inbound {
    label    = "allow-thanos-receive"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10903"
    ipv4 = concat(["${each.value.ip_address}/32"], [
      for node in merge(local.created_all_servers, local.geth_servers_data) :
      "${node.ip}/32"
      if contains(node.tags, "rw_${each.key}")
    ])
    ipv6 = []
  }

  inbound {
    label    = "allow-loki-receive"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3100"
    ipv4 = concat(["${each.value.ip_address}/32"], [
      for node in merge(local.created_all_servers, local.geth_servers_data) :
      "${node.ip}/32"
      if contains(node.tags, "rw_${each.key}")
    ])
    ipv6 = []
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [each.value.id]
}