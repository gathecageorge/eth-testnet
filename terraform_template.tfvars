# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# Group for all linodes deployed using this terraform for differentiation
instance_group = "ef-foundation"

# Can be true/false NB: Initially must be true when creating instance
booted_status = "true"

# ssh key to be authorized on all linodes for user ubuntu
access_ssh_keys = {
  key1_label : "public key here",
  key2_label : "public key here",
}

# global instances/machines to create, different configurations
global_instance_types = {
  globalfederation = { count = 1, type = "g6-standard-4", image = "linode/ubuntu20.04", client = "globalfederation", test = "all" }
  geth             = { count = 1, type = "g6-standard-4", image = "linode/ubuntu20.04", client = "geth", test = "all" },
}

# testnet instances/machines to create, different configurations
testnet_instance_types = {
  dclocal    = { count = 2, type = "g6-standard-4", image = "linode/ubuntu20.04" },

  lighthouse = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  teku       = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  prysm      = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  nimbus     = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" }
}

# parallel tests
parallel_tests = ["test1", "test2", "test3"]
