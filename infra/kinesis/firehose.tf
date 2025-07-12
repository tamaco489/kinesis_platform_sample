# kinesis data firehose
resource "aws_kinesis_firehose_delivery_stream" "unified_logs" {
  name        = "${local.fqn}-unified-logs"
  destination = "extended_s3"

  # kinesis stream as source
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.shop_events.arn
    role_arn           = aws_iam_role.kinesis_firehose_role.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn = data.terraform_remote_state.s3.outputs.logs.arn

    # static prefix (simplified for now)
    # format: logs/{year}/{month}/{day}/
    prefix = "logs/!{timestamp:yyyy/MM/dd}/"

    # error output prefix
    error_output_prefix = "errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

    # buffering settings
    buffering_size     = 128
    buffering_interval = 300

    # compression format
    compression_format = "GZIP"

    # s3 backup mode
    s3_backup_mode = "Disabled"

    # cloudwatch logging options
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_unified_logs.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_unified_logs.name
    }
  }

  tags = { Name = "${local.fqn}-unified-logs" }
}
