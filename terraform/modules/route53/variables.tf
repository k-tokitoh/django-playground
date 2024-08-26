variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb" {
  type = object({
    dns_name = string
    zone_id  = string
  })
}
