variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "database_host_ssm_parameter_arn" {
  type = string
}

variable "database_port_ssm_parameter_arn" {
  type = string
}

variable "database_name_ssm_parameter_arn" {
  type = string
}

variable "database_username_ssm_parameter_arn" {
  type = string
}

variable "database_password_ssm_parameter_arn" {
  type = string
}
