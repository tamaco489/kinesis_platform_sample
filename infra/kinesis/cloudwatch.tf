# cloudwatch logs - kinesis data firehose unified logs
resource "aws_cloudwatch_log_group" "kinesis_firehose_shop_event_projector" {
  name              = "/aws/kinesis-firehose/${var.event_types.shop.name}-logs"
  retention_in_days = 7

  tags = {
    Name        = "${var.env}-${var.event_types.shop.name}"
    Description = var.event_types.shop.description
  }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_shop_event_projector" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_shop_event_projector.name
}
