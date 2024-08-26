output "target_group_arn" {
  value = aws_lb_target_group.default.arn
}

output "alb" {
  value = {
    dns_name = aws_lb.default.dns_name
    zone_id  = aws_lb.default.zone_id
  }
}
