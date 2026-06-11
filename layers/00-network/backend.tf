###############################################################################
# Remote state backend for the 00-network layer.
#
# NOTE: Backend blocks cannot use variables. Replace `bucket` and `region`
# with values matching your environment (the state bucket must already exist).
# Each layer keeps its own state file via a distinct `key`.
###############################################################################

terraform {
  backend "s3" {
    bucket  = "aws-network-iac-tfstate"
    key     = "00-network/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
