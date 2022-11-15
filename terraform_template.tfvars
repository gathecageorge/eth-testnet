# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# Group for all linodes deployed using this terraform for differentiation
instance_group = "ef-foundation"

# ssh key to be authorized on all linodes for user ubuntu
access_ssh_keys = {
  key1_label : "public key here"
}

# global instances/machines to create, different configurations
globalfederation = { count = 1, type = "g6-standard-4", image = "linode/ubuntu22.04", client = "globalfederation" }
geth             = { count = 1, type = "g6-standard-6", image = "linode/ubuntu22.04", client = "geth" }

# testnet instances/machines to create, different configurations
testnet_instance_types = {
  dclocal    = { count = 2, type = "g6-standard-2", image = "linode/ubuntu22.04" },

  lighthouse = { count = 8, type = "g6-standard-2", image = "linode/ubuntu22.04" },
  teku       = { count = 8, type = "g6-standard-2", image = "linode/ubuntu22.04" },
  prysm      = { count = 8, type = "g6-standard-2", image = "linode/ubuntu22.04" },
  nimbus     = { count = 8, type = "g6-standard-2", image = "linode/ubuntu22.04" }
}

# parallel tests
parallel_tests = {
  test1 = {booted = "true", testnet = "premerge"}
  test2 = {booted = "true", testnet = "postmerge"}
}
