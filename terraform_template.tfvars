# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# Group for all linodes deployed using this terraform for differentiation
instance_group = "ef-foundation"
groups_peering = "true"

# ssh key to be authorized on all linodes for user ubuntu
access_ssh_keys = {
  key1_label : "public key here",
  key2_label : "public key here",
}

# instances/machines to create, different configurations
instance_types = {
  geth              = { count = 2, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  globalfederation = { count = 2, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  dclocal          = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },

  lighthouse = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  teku       = { count = 8, type = "g6-standard-6", image = "linode/ubuntu20.04" },
  prysm      = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" },
  nimbus     = { count = 8, type = "g6-standard-4", image = "linode/ubuntu20.04" }
}