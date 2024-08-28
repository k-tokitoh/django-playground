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

module "route53" {
  source = "../../modules/route53"

  project     = var.project
  environment = var.environment
}

module "acm" {
  source = "../../modules/acm"

  project     = var.project
  environment = var.environment
  domain      = module.route53.domain
}

module "alb" {
  source = "../../modules/alb"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  domain                = module.route53.domain
  route53_zone_id       = module.route53.zone_id
  certificate_arn       = module.acm.certificate_arn
}

module "rds" {
  source = "../../modules/rds"

  project              = var.project
  environment          = var.environment
  private_subnet_ids   = module.network.private_subnet_ids
  db_security_group_id = module.network.db_security_group_id
}

module "ecs" {
  source = "../../modules/ecs"

  project                             = var.project
  environment                         = var.environment
  vpc_id                              = module.network.vpc_id
  public_subnet_ids                   = module.network.public_subnet_ids
  ecs_security_group_id               = module.network.ecs_security_group_id
  alb_target_group_arn                = module.alb.target_group_arn
  database_host_ssm_parameter_arn     = module.rds.database_host_ssm_parameter_arn
  database_port_ssm_parameter_arn     = module.rds.database_port_ssm_parameter_arn
  database_name_ssm_parameter_arn     = module.rds.database_name_ssm_parameter_arn
  database_username_ssm_parameter_arn = module.rds.database_username_ssm_parameter_arn
  database_password_ssm_parameter_arn = module.rds.database_password_ssm_parameter_arn
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  project                 = var.project
  environment             = var.environment
  domain                  = module.route53.domain
  route53_zone_id         = module.route53.zone_id
  certificate_arn         = module.acm.certificate_arn
  alb_name                = module.alb.alb.name
  alb_route53_record_name = module.alb.route53_record_name
}

module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
}
