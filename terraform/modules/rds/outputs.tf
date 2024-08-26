output "database_host_ssm_parameter_arn" {
  value = aws_ssm_parameter.database_host.arn
}

output "database_port_ssm_parameter_arn" {
  value = aws_ssm_parameter.database_port.arn
}

output "database_name_ssm_parameter_arn" {
  value = aws_ssm_parameter.database_name.arn
}

output "database_username_ssm_parameter_arn" {
  value = aws_ssm_parameter.database_username.arn
}

output "database_password_ssm_parameter_arn" {
  value = aws_ssm_parameter.database_password.arn
}
