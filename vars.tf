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

# Group for all linodes deployed using this terraform for differentiation
variable "instance_group" {
  description = "Group for all linodes deployed using this terraform for differentiation"
  type        = string
}

# ssh keys to be authorized for user ubuntu access on all linodes
variable "access_ssh_keys" {
  description = "ssh keys to be authorized for user ubuntu access on all linodes"
  type        = map(string)
}

# Regions to distribute linodes to
variable "dc_regions" {
  description = "Regions to distribute linodes to"
  type        = list(string)
  default     = ["us-west", "eu-west", "ap-west", "ca-central", "ap-southeast", "us-central", "us-southeast", "us-east", "ap-south", "eu-central", "ap-northeast"]
}

# Groups classifications of different sides
variable "class_groups" {
  description = "Groups classifications of different sides"
  type        = list(string)
  default     = ["group1", "group2"]
}

# Allow groups peering
variable "groups_peering" {
  description = "Allow groups peering"
  type        = string
}

# instances/machines to create, different configurations
variable "instance_types" {
  description = "instances/machines to create, different configurations"
  type        = map(any)
}