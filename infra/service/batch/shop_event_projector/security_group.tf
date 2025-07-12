resource "aws_security_group" "shop_event_projector" {
  name        = local.fqn
  description = "security group for shop event projector service running in the vpc"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id
}

# Security group for connecting to Secrets Manager VPC endpoint
resource "aws_security_group" "secrets_manager_endpoint" {
  name        = "${local.fqn}-secrets-manager-endpoint"
  description = "Security group for Secrets Manager endpoint"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id

  tags = { Name = local.fqn }
}

# Shop Event Projector SG -> Secrets Manager endpoint SG (egress)
resource "aws_vpc_security_group_egress_rule" "shop_event_projector_to_secrets_manager_endpoint" {
  security_group_id            = aws_security_group.shop_event_projector.id
  description                  = "Allow HTTPS to Secrets Manager endpoint SG"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.secrets_manager_endpoint.id
}

# Lambda Shop Event Projector <- secrets_manager_endpoint (ingress)
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_endpoint_from_shop_event_projector" {
  security_group_id            = aws_security_group.secrets_manager_endpoint.id
  description                  = "Allow HTTPS from Shop Event Projector SG"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.shop_event_projector.id
}
