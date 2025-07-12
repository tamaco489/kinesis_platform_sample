output "vpce_secrets_manager_sg" {
  description = "security group for secrets manager vpc endpoint"
  value       = aws_security_group.vpce_secrets_manager.id
}
