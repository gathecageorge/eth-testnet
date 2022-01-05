variable "number_instances" {
  description = "How many instances of this type"
  type        = number
}

variable "instance_image" {
  description = "What OS image to use for the instances"
  type        = string
}

variable "instance_regions" {
  description = "What regions to launch the instances, NB will be distributed across the regions"
  type        = list(string)
}

variable "instance_type" {
  description = "What type of instances to launch, determines resources like RAM"
  type        = string
}

variable "instance_ubuntu_password" {
  description = "What password that will be set for ubuntu user on this instances"
  type        = string
}

variable "access_ssh_key" {
  description = "What ssh key to be authorized for user ubuntu access on all linodes"
  type        = string
}

variable "instance_group" {
  description = "What is the group name for this instances"
  type        = string
}