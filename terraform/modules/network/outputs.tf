output "vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}
