# access token to linode account
token = ""

# ubuntu password to be set on linodes
instance_ubuntu_password = ""

# Group for all linodes deployed using this terraform for differentiation
instance_group = "ef-foundation"

# Github usernames to get ssh keys to be allowed ssh access to servers
github_usernames = ["your_github_username to get keys ie https://github.com/myusername.keys", "another_username"]

# global instances/machines to create, different configurations
globalfederation = { count = 1, type = "g6-standard-4", image = "linode/ubuntu22.04", client = "globalfederation" }
geth             = { count = 1, type = "g6-standard-6", image = "linode/ubuntu22.04", client = "geth" }

# testnet instances/machines to create, different configurations
testnet_instance_types = {
  dclocal    = { type = "g6-standard-2", image = "linode/ubuntu22.04" },

  lighthouse = { type = "g6-standard-2", image = "linode/ubuntu22.04" },
  teku       = { type = "g6-standard-2", image = "linode/ubuntu22.04" },
  prysm      = { type = "g6-standard-2", image = "linode/ubuntu22.04" },
  nimbus     = { type = "g6-standard-2", image = "linode/ubuntu22.04" }
}

# parallel tests
parallel_tests = {
  test1 = {booted = "true", testnet = "premerge", per_client = 8, dclocal = 1}
  test2 = {booted = "true", testnet = "postmerge", per_client = 16, dclocal = 1}
}
