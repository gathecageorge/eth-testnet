output "server_ips" {
  description = "Servers ip addresses"
  value = {
    for instance in linode_instance.instances :
    instance.label => instance.ip_address
  }
}