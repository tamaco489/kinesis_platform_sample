# Kinesis Data Stream for shop events
resource "aws_kinesis_stream" "shop_events" {
  name             = local.fqn
  retention_period = 24

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = { Name = local.fqn }
}
