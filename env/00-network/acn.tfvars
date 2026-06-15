project     = "acn"
environment = "bts"
region      = "ap-southeast-3"

vpc_cidr = "10.10.0.0/26"
az_count = 2

public_subnet_cidrs  = ["10.10.0.0/27"]
private_subnet_cidrs = ["10.10.0.32/27"]

tags = {
  Owner = "devsecops-team"
}
