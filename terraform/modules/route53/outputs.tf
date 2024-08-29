output "domain" {
  value = local.domain
}

output "zone_id" {
  value = data.aws_route53_zone.existing.zone_id
}
