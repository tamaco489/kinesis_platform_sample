resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.vpc.public_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce_secrets_manager.id]

  tags = { Name = local.fqn }
}

resource "aws_vpc_endpoint" "kinesis_data_stream_endpoint" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.kinesis-streams"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.vpc.public_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce_kinesis_data_stream.id]

  tags = { Name = local.fqn }
}
