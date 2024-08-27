output "target_group_arn" {
  value = aws_lb_target_group.default.arn
}

output "alb" {
  value = {
    name     = aws_lb.default.name
    dns_name = aws_lb.default.dns_name
    zone_id  = aws_lb.default.zone_id
  }
}

output "route53_record_name" {
  value = aws_route53_record.alb.name
}
