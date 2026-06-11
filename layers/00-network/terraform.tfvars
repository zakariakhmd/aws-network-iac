project     = "aws-network-iac"
environment = "dev"
region      = "us-east-1"

vpc_cidr = "10.0.0.0/16"
az_count = 2

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
data_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]

tags = {
  Owner = "platform-team"
}
