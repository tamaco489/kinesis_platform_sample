resource "aws_cloudwatch_log_group" "shop_event_projector" {
  name              = "/aws/lambda/${aws_lambda_function.shop_event_projector.function_name}"
  retention_in_days = 3

  tags = { Name = local.fqn }
}
