# cloudwatch logs - kinesis data firehose
resource "aws_cloudwatch_log_group" "kinesis_firehose_event_logs" {
  name              = "/aws/kinesis-firehose/${local.fqn}-event-logs"
  retention_in_days = 7

  tags = { Name = "${local.fqn}-kinesis-firehose-event-logs" }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_event_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_event_logs.name
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_audit_logs" {
  name              = "/aws/kinesis-firehose/${local.fqn}-audit-logs"
  retention_in_days = 7

  tags = { Name = "${local.fqn}-kinesis-firehose-audit-logs" }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_audit_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_audit_logs.name
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_error_logs" {
  name              = "/aws/kinesis-firehose/${local.fqn}-error-logs"
  retention_in_days = 7

  tags = { Name = "${local.fqn}-kinesis-firehose-error-logs" }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_error_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_error_logs.name
}
