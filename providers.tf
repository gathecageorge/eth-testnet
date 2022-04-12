terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.26.3"
    }
  }

  backend "s3" {}
}

provider "linode" {
  # Configuration options
  token = var.token
}
