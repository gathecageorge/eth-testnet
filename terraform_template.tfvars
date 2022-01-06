# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# ssh key to be authorized on all linodes for user ubuntu
access_ssh_key = ""

# instances/machines to create, different configurations
instance_types = {
  lighthouse = { count = 8, type = "g6-linode-8", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] },
  teku       = { count = 8, type = "g6-linode-16", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] },
  prysm      = { count = 8, type = "g6-linode-8", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] },
  nimbus     = { count = 8, type = "g6-linode-8", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] }
}