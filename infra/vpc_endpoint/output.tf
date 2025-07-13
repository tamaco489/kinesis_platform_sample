output "vpce_secrets_manager_sg" {
  description = "security group for secrets manager vpc endpoint"
  value       = aws_security_group.vpce_secrets_manager.id
}

output "vpce_kinesis_data_stream_sg" {
  description = "security group for kinesis data stream vpc endpoint"
  value       = aws_security_group.vpce_kinesis_data_stream.id
}
