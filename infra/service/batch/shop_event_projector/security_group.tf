resource "aws_security_group" "shop_event_projector" {
  name        = local.fqn
  description = "security group for shop event projector service running in the vpc"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "shop_event_projector_egress" {
  security_group_id = aws_security_group.shop_event_projector.id
  description       = "allow Lambda to access external resources (e.g. rds, dynamodb, api)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
