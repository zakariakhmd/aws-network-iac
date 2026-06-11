###############################################################################
# EC2 Module
# Launches a private EC2 instance (no public IP) intended to be reached only
# through AWS SSM Session Manager. Security best practices enforced:
#   - IMDSv2 required (http_tokens = "required")
#   - Encrypted root EBS volume
#   - No public IP association
###############################################################################

# Resolve the latest Amazon Linux 2023 AMI unless an explicit AMI is provided.
data "aws_ssm_parameter" "al2023" {
  count = var.ami_id == null ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.al2023[0].value
}

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = false

  # Enforce IMDSv2.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-root"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2"
    }
  )
}
