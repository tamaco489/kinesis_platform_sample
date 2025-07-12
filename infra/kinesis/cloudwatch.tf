# cloudwatch logs - kinesis data firehose unified
resource "aws_cloudwatch_log_group" "kinesis_firehose_unified_logs" {
  name              = "/aws/kinesis-firehose/${local.fqn}-unified-logs"
  retention_in_days = 7

  tags = { Name = "${local.fqn}-kinesis-firehose-unified-logs" }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_unified_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_unified_logs.name
}
