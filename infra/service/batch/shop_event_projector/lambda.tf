resource "aws_lambda_function" "shop_event_projector" {
  function_name = local.fqn
  description   = "Shop Event Projector Service"
  role          = aws_iam_role.shop_event_projector.arn
  package_type  = "Image"
  image_uri     = "${data.terraform_remote_state.ecr.outputs.shop_event_projector.url}:shop_event_projector_v0.0.0"
  timeout       = 30
  memory_size   = 128

  vpc_config {
    ipv6_allowed_for_dual_stack = false
    security_group_ids          = [aws_security_group.shop_event_projector.id]
    subnet_ids                  = data.terraform_remote_state.network.outputs.vpc.public_subnet_ids
    # subnet_ids                = data.terraform_remote_state.network.outputs.vpc.private_subnet_ids # NOTE: Don't use private subnets to avoid NAT
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  environment {
    variables = {
      SERVICE_NAME = "shop-event-projector"
      ENV          = "stg"
    }
  }

  tags = { Name = local.fqn }
}

# Lambda event source mapping configuration
# Configuration required to trigger Lambda execution from Kinesis Data Stream
resource "aws_lambda_event_source_mapping" "shop_event_projector" {
  event_source_arn  = data.terraform_remote_state.kinesis.outputs.shop_events_stream.arn
  function_name     = aws_lambda_function.shop_event_projector.arn
  enabled           = true
  batch_size        = 100
  starting_position = "LATEST"
}
