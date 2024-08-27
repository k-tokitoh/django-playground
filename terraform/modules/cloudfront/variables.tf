variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "alb_route53_record_name" {
  type = string
}
