# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# ssh key to be authorized on all linodes for user ubuntu
access_ssh_key = ""

# instances/machines to create, different configurations
instance_types = {
  teku   = { count = 3, type = "g6-nanode-1", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] },
  numbus = { count = 2, type = "g6-nanode-1", image = "linode/ubuntu20.04", regions = ["us-west", "us-east"] }
}