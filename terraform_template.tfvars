# access token to linode account
token = ""

# root password to be set on linodes
instance_root_password = ""

# root ssh key to be authorized on all linodes
instance_root_ssh_key = ""

# instances/machines to create, different configurations
instance_types = {
  teku = { count = 3, type = "g6-nanode-1", image = "linode/ubuntu21.10", regions = ["us-west", "us-east"] },
  numbus = { count = 2, type = "g6-nanode-1", image = "linode/ubuntu21.10", regions = ["us-west", "us-east"] }
}