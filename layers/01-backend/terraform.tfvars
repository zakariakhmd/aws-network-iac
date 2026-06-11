project     = "aws-network-iac"
environment = "dev"
region      = "us-east-1"

# Must match the S3 bucket configured in backend.tf (holds 00-network state).
state_bucket = "aws-network-iac-tfstate"

instance_type    = "t2.micro"
root_volume_size = 8

tags = {
  Owner = "platform-team"
}
