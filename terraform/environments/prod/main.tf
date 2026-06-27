terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "../../modules/vpc"
  name                 = "rsds-prod"
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags                 = local.common_tags
}

module "eks" {
  source = "../../modules/eks"
  name   = "rsds-prod"
  tags   = local.common_tags
}

locals {
  common_tags = {
    Environment = "prod"
    Project     = "rsds"
    ManagedBy   = "terraform"
  }
}
