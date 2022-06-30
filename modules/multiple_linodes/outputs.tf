output "servers_information" {
  description = "Servers information"
  value = {
    for instance in linode_instance.instances :
    instance.label => {
      id = instance.id,
      label = instance.label,
      ip_address = instance.ip_address,
      private_ip_address = instance.private_ip_address,
      ipv6 = instance.ipv6,
      region = instance.region,
      tags = instance.tags
      client = instance.group
      grp = [
        for tag in instance.tags :
        tag
        if length(regexall("^group.*", tag)) == 1
      ],
      geth = [
        for tag in instance.tags :
        tag
        if length(regexall("^geth.*", tag)) == 1
      ],
      rw = [
        for tag in instance.tags :
        tag
        if length(regexall("^rw_.*", tag)) == 1
      ]
    }
  }
}