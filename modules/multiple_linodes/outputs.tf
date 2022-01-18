output "servers_information" {
  description = "Servers information"
  value = {
    for instance in linode_instance.instances :
    instance.label => {
      ip = instance.ip_address,
      eth1 = [
        for tag in instance.tags :
        tag
        if length(regexall(".*eth1.*", tag)) == 1
      ],
      global_federation = [
        for tag in instance.tags :
        tag
        if length(regexall(".*federation.*", tag)) == 1
      ],
      region = instance.region
    }
  }
}