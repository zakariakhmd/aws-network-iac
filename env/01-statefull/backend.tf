###############################################################################
# Remote state backend for the 01-backend layer.
#
# NOTE: Backend blocks cannot use variables. Replace `bucket` and `region`
# with values matching your environment (the state bucket must already exist).
###############################################################################

terraform {
  backend "s3" {
    bucket  = "bts-iac-tfstate"
    key     = "01-statefull/terraform.tfstate"
    region  = "ap-southeast-3"
    encrypt = true
  }
}