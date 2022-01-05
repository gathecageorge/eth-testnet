# access token to linode account
variable "token" {
  description = "access token to linode account"
  type        = string
}

# ubuntu password to be set on linodes
variable "instance_ubuntu_password" {
  description = "ubuntu password to be set on linodes"
  type        = string
}

# ssh key to be authorized for user ubuntu access on all linodes
variable "access_ssh_key" {
  description = "ssh key to be authorized for user ubuntu access on all linodes"
  type        = string
}

# instances/machines to create, different configurations
variable "instance_types" {
  description = "instances/machines to create, different configurations"
  type        = map(any)
}