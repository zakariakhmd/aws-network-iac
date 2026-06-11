###############################################################################
# 00-network layer
# Provisions the network foundation: VPC, subnets (public/private/data across
# 2 AZs), Internet Gateway, a NAT Gateway, and the route tables wiring it all
# together.
###############################################################################

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      Layer       = "00-network"
      ManagedBy   = "terraform"
    }
  )

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Build per-tier subnet maps: { az1 = { cidr_block, availability_zone }, ... }
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    "az${idx + 1}" => {
      cidr_block        = cidr
      availability_zone = local.azs[idx]
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    "az${idx + 1}" => {
      cidr_block        = cidr
      availability_zone = local.azs[idx]
    }
  }

  data_subnets = {
    for idx, cidr in var.data_subnet_cidrs :
    "az${idx + 1}" => {
      cidr_block        = cidr
      availability_zone = local.azs[idx]
    }
  }
}

# ---------------------------------------------------------------------------
# VPC + Internet Gateway
# ---------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = local.name_prefix
  cidr_block  = var.vpc_cidr
  tags        = local.tags
}

# ---------------------------------------------------------------------------
# Public subnet tier (routes to the Internet Gateway)
# ---------------------------------------------------------------------------
module "public_subnets" {
  source = "../../modules/subnet"

  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  tier                    = "public"
  subnets                 = local.public_subnets
  map_public_ip_on_launch = true
  internet_gateway_id     = module.vpc.internet_gateway_id
  tags                    = local.tags
}

# ---------------------------------------------------------------------------
# NAT Gateway (placed in the first public subnet)
# ---------------------------------------------------------------------------
module "nat_gateway" {
  source = "../../modules/nat-gateway"

  name_prefix      = local.name_prefix
  public_subnet_id = module.public_subnets.subnet_ids["az1"]
  tags             = local.tags

  # The IGW (created by the vpc module) must be attached before the NAT works.
  depends_on = [module.vpc]
}

# ---------------------------------------------------------------------------
# Private subnet tier (routes to the NAT Gateway)
# ---------------------------------------------------------------------------
module "private_subnets" {
  source = "../../modules/subnet"

  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  tier           = "private"
  subnets        = local.private_subnets
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  tags           = local.tags
}

# ---------------------------------------------------------------------------
# Data subnet tier (isolated: no internet route, local routing only)
# ---------------------------------------------------------------------------
module "data_subnets" {
  source = "../../modules/subnet"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  tier        = "data"
  subnets     = local.data_subnets
  tags        = local.tags
}
