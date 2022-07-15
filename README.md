# eth-testnet

Automated testnet deploy on Linode

## Project Setup

1. Clone the project
2. Copy terraform_template.tfvars to terraform.tfvars and fill in the variables to be used
3. Copy backend_template.conf to backend.conf and fill in details for s3. This is used to save terraform.tfstate file so it can be shared.

`NB: You need AWS cli setup and configured for the profile that will be used to access s3 state. Also any s3 compatible platform like digital ocean spaces or linode can be used`

## Initialize project

`terraform init -backend-config=backend.conf`

## Run Project

Run this to create nodes first

`terraform apply`

## Delete all Project resources

`terraform destroy`
