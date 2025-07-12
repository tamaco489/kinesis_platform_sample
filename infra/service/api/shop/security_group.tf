resource "aws_security_group" "shop_api" {
  name        = local.fqn
  description = "Security group for API service running in the VPC"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id

  tags = { Name = local.fqn }
}

# Shop API SG -> Secrets Manager endpoint SG (egress)
resource "aws_vpc_security_group_egress_rule" "shop_api_to_secrets_manager_endpoint" {
  security_group_id            = aws_security_group.shop_api.id
  description                  = "Allow HTTPS to Secrets Manager endpoint SG"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.terraform_remote_state.vpc_endpoint.outputs.vpce_secrets_manager_sg
}

# Lambda Shop API <- secrets_manager_endpoint (ingress)
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_endpoint_from_shop_api" {
  security_group_id            = data.terraform_remote_state.vpc_endpoint.outputs.vpce_secrets_manager_sg
  description                  = "Allow HTTPS from Shop API SG"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.shop_api.id
}
