module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  //count                = var.aws_is_main_region ? 1 : 0
  name            = local.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.vpc_az
  private_subnets = var.vpc_private_subnets
  private_subnet_tags = {
    "Tier" = "Private"
  }
  public_subnets = var.vpc_public_subnets
  public_subnet_tags = {
    "Tier" = "Public"
  }
  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  enable_dns_hostnames   = var.vpc_enable_dns_hostnames

  tags = local.aws_tags
}




module "vpc_secondary" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  count   = var.aws_is_main_region && var.aws_create_second_region_resources ? 1 : 0
  providers = {
    aws = aws.second
  }
  name            = local.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.vpc_az
  private_subnets = var.vpc_private_subnets
  private_subnet_tags = {
    "Tier" = "Private"
  }
  public_subnets = var.vpc_public_subnets
  public_subnet_tags = {
    "Tier" = "Public"
  }
  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  enable_dns_hostnames   = var.vpc_enable_dns_hostnames

  tags = local.aws_tags
}



// Secondary region data sources
data "aws_vpc" "vpc_secondary" {
  count = !var.aws_is_main_region && var.vpc_secondary_id != null ? 1 : 0
  id    = var.vpc_secondary_id

}

data "aws_subnets" "vpc_secondary_public" {
  count = !var.aws_is_main_region && var.vpc_secondary_id != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_secondary_id]
  }

  tags = {
    Tier = "Public"
  }
}

data "aws_subnets" "vpc_secondary_private" {
  count = !var.aws_is_main_region && var.vpc_secondary_id != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_secondary_id]
  }

  tags = {
    Tier = "Private"
  }
}
