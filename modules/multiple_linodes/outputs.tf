output "servers_information" {
  description = "Servers information"
  value = {
    for instance in linode_instance.instances :
    instance.label => {
      ip = instance.ip_address,
      geth = [
        for tag in instance.tags :
        tag
        if length(regexall("geth.*", tag)) == 1
      ],
      rw = [
        for tag in instance.tags :
        tag
        if length(regexall("rw.*", tag)) == 1
      ]
      region = instance.region
    }
  }
}