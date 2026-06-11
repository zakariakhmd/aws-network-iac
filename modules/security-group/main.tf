###############################################################################
# Security Group Module
# Creates a security group. By design there are NO inbound rules: access to
# the instance is via AWS SSM Session Manager only (no SSH / port 22 / bastion).
# Egress is allowed so the instance can reach AWS APIs (SSM, S3) via the NAT
# Gateway and pull updates.
###############################################################################

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow all outbound IPv4 traffic (required for SSM/S3 over NAT).
resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound IPv4 traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
