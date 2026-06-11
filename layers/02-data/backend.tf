###############################################################################
# Remote state backend for the 02-data layer.
#
# NOTE: Backend blocks cannot use variables. Replace `bucket` and `region`
# with values matching your environment (the state bucket must already exist).
###############################################################################

terraform {
  backend "s3" {
    bucket  = "aws-network-iac-tfstate-changeme"
    key     = "02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
