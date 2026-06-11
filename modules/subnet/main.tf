###############################################################################
# Subnet Module
# Creates one subnet "tier" (a set of subnets spread across AZs) together with
# a dedicated route table and route table associations.
#
# Default-route behaviour:
#   - internet_gateway_id set -> 0.0.0.0/0 routes to the IGW   (public tier)
#   - nat_gateway_id set      -> 0.0.0.0/0 routes to the NAT GW (private tier)
#   - neither set             -> no internet route at all      (data tier)
###############################################################################

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.tier}-${each.key}"
      Tier = var.tier
    }
  )
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.tier}-rt"
      Tier = var.tier
    }
  )
}

# Public tier: default route to the Internet Gateway.
resource "aws_route" "internet_gateway" {
  count = var.create_internet_route ? 1 : 0

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Private tier: default route to the NAT Gateway.
resource "aws_route" "nat_gateway" {
  count = var.create_nat_route ? 1 : 0

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}
