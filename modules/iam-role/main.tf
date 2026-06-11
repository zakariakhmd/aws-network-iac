###############################################################################
# IAM Role Module
# Creates an IAM role assumable by EC2, attaches the managed policies required
# for SSM Session Manager, and exposes an instance profile. Additional managed
# policy ARNs (e.g. a least-privilege S3 policy created in another layer) can be
# attached via managed_policy_arns.
###############################################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "${var.name_prefix}-role"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-role"
    }
  )
}

# Core permissions for AWS Systems Manager (Session Manager) access.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Any additional managed policies supplied by the caller.
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.this.name

  tags = var.tags
}
