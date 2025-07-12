resource "aws_route53_zone" "main" {
  name    = var.domain
  comment = "kinesis platform sample"

  tags = { Name = local.fqn }
}
