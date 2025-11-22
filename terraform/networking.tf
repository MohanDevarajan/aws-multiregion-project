locals {
  cidr_primary   = "10.10.0.0/16"
  cidr_secondary = "10.20.0.0/16"
}

module "vpc_primary" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = "${var.project_name}-${var.env}-primary"
  cidr                 = local.cidr_primary
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.10.1.0/24", "10.10.2.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc_secondary" {
  providers            = { aws = aws.secondary }
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = "${var.project_name}-${var.env}-secondary"
  cidr                 = local.cidr_secondary
  azs                  = ["us-east-2a", "us-east-2b"]
  public_subnets       = ["10.20.1.0/24", "10.20.2.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}
