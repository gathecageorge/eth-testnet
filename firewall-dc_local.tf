resource "linode_firewall" "dc_local_firewalls" {
  for_each = {
    for node in data.linode_instances.all_nodes.instances :
    node.label => { id : node.id, region : node.region, ip_address : node.ip_address, global : [
      for tag in node.tags :
      tag
      if length(regexall(".*global.*", tag)) == 1
    ] }
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
    label    = "allow-prometheus"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "9090"
    ipv4     = ["0.0.0.0/0"]
    #ipv4 = [
    #  for node in data.linode_instances.all_nodes.instances :
    #  "${node.ip_address}/32"
    #  if node.label == replace(each.value.global[0], "use_", "")
    #]
    ipv6 = []
  }

  inbound {
    label    = "allow-grafana"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3000"
    ipv4     = ["0.0.0.0/0"]
    #ipv4 = [
    #  for node in data.linode_instances.all_nodes.instances :
    #  "${node.ip_address}/32"
    #  if node.label == replace(each.value.global[0], "use_", "")
    #]
    ipv6 = []
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [each.value.id]

  depends_on = [
    data.linode_instances.all_nodes,
  ]
}