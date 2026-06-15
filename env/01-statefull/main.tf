###############################################################################
# 01-statefull layer
# Provisions the private compute tier:
#   - IAM role + instance profile (SSM Session Manager access)
#   - Egress-only security group (no inbound, no SSH)
#   - Private EC2 instance (no public IP) in a private subnet
#
# Network inputs are read from the 00-network layer's remote state.
###############################################################################

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "bootstrap/00-network/terraform.tfstate"
    region = var.region
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      Layer       = "01-statefull"
      ManagedBy   = "terraform"
    }
  )

  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
}

# ---------------------------------------------------------------------------
# IAM role + instance profile (SSM access). The least-privilege S3 policy is
# attached separately by the 02-data layer.
# ---------------------------------------------------------------------------
module "iam_role" {
  source = "../../modules/iam-role"

  name_prefix = "${local.name_prefix}"
  tags        = local.tags
}

# ---------------------------------------------------------------------------
# Security group (egress only; access is via SSM Session Manager).
# ---------------------------------------------------------------------------
module "security_group" {
  source = "../../modules/security-group"

  name_prefix = "${local.name_prefix}"
  vpc_id      = local.vpc_id
  description = "Bootstrap EC2 SG - egress only, access via SSM."
  tags        = local.tags
}

# ---------------------------------------------------------------------------
# Private EC2 instance.
# ---------------------------------------------------------------------------
module "ec2" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}"
  instance_type         = var.instance_type
  subnet_id             = local.private_subnet_ids[0]
  security_group_ids    = [module.security_group.security_group_id]
  instance_profile_name = module.iam_role.instance_profile_name
  root_volume_size      = var.root_volume_size
  tags                  = local.tags
}
