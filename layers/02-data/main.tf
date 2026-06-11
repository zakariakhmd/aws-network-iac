###############################################################################
# 02-data layer
# Provisions the data tier:
#   - Private S3 bucket (public access blocked, encrypted, versioned)
#   - A least-privilege IAM policy granting the backend EC2 role access to the
#     bucket, attached to the role created in the 01-backend layer.
#
# The backend layer's IAM role name is read from its remote state.
###############################################################################

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "01-backend/terraform.tfstate"
    region = var.region
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  # Globally unique bucket name unless explicitly overridden.
  bucket_name = var.bucket_name != null ? var.bucket_name : "${local.name_prefix}-data-${data.aws_caller_identity.current.account_id}"

  ec2_role_name = data.terraform_remote_state.backend.outputs.iam_role_name

  tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      Layer       = "02-data"
      ManagedBy   = "terraform"
    }
  )
}

# ---------------------------------------------------------------------------
# S3 data bucket.
# ---------------------------------------------------------------------------
module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name   = local.bucket_name
  force_destroy = var.force_destroy
  tags          = local.tags
}

# ---------------------------------------------------------------------------
# Least-privilege IAM policy for the backend EC2 role to access the bucket.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [module.s3_bucket.bucket_arn]
  }

  statement {
    sid       = "ObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ec2_s3_access" {
  name        = "${local.name_prefix}-ec2-s3-access"
  description = "Least-privilege access for the backend EC2 role to the data bucket."
  policy      = data.aws_iam_policy_document.ec2_s3_access.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = local.ec2_role_name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}
