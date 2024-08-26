output "domain" {
  value = local.domain
}

output "zone_id" {
  value = aws_route53_zone.existing.zone_id
}
