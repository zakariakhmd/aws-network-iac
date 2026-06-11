project     = "aws-network-iac"
environment = "dev"
region      = "us-east-1"

# Must match the S3 bucket configured in backend.tf (holds 01-backend state).
state_bucket = "aws-network-iac-tfstate-changeme"

# Leave bucket_name null to auto-generate a globally unique name from
# project/environment/account-id, or set an explicit name here.
# bucket_name = "my-app-data-bucket"

force_destroy = false

tags = {
  Owner = "platform-team"
}
