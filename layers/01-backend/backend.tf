###############################################################################
# Remote state backend for the 01-backend layer.
#
# NOTE: Backend blocks cannot use variables. Replace `bucket` and `region`
# with values matching your environment (the state bucket must already exist).
###############################################################################

terraform {
  backend "s3" {
    bucket  = "aws-network-iac-tfstate-changeme"
    key     = "01-backend/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
