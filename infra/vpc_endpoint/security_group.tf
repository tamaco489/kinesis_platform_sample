resource "aws_security_group" "vpce_secrets_manager" {
  name        = "${local.fqn}-secrets-manager-vpce"
  description = "Security group for Secrets Manager VPC Endpoint"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id

  tags = { Name = local.fqn }
}

resource "aws_security_group" "vpce_kinesis_data_stream" {
  name        = "${local.fqn}-kinesis-data-stream-vpce"
  description = "Security group for Kinesis Data Stream VPC Endpoint"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id

  tags = { Name = local.fqn }
}
