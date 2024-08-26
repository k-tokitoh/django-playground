terraform {
  required_version = ">=1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  profile = "private"
  region  = "us-east-1"
}


# ==========================================================================================================================
# variables
# ==========================================================================================================================

variable "project" {
  type = string
}

variable "environment" {
  type = string
}


# ==========================================================================================================================
# modules
# ==========================================================================================================================

# 循環参照にならないように注意

module "network" {
  source = "../../modules/network"

  project     = var.project
  environment = var.environment
}

module "alb" {
  source = "../../modules/alb"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "ecs" {
  source = "../../modules/ecs"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  ecs_security_group_id = module.network.ecs_security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
}
