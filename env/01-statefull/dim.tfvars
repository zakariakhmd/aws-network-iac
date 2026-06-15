project     = "dim"
environment = "bts"
region      = "ap-southeast-3"

# Must match the S3 bucket configured in backend.tf (holds 00-network state).
state_bucket = "bts-iac-tfstate"

instance_type    = "t3.micro"
root_volume_size = 8

tags = {
  Owner = "devsecops-team"
}
