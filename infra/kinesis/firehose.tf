# kinesis data firehose - event logs
resource "aws_kinesis_firehose_delivery_stream" "event_logs" {
  name        = "${local.fqn}-event-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn = data.terraform_remote_state.s3.outputs.logs.arn

    # static prefix (simplified for now)
    # format: event/{year}/{month}/{day}/
    prefix = "event/!{timestamp:yyyy/MM/dd}/"

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
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_event_logs.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_event_logs.name
    }
  }

  tags = { Name = "${local.fqn}-event-logs" }
}

# kinesis data firehose - audit logs
resource "aws_kinesis_firehose_delivery_stream" "audit_logs" {
  name        = "${local.fqn}-audit-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn = data.terraform_remote_state.s3.outputs.logs.arn

    # static prefix (simplified for now)
    # format: audit/{year}/{month}/{day}/
    prefix = "audit/!{timestamp:yyyy/MM/dd}/"

    # error output prefix
    error_output_prefix = "errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

    buffering_size     = 128
    buffering_interval = 300

    compression_format = "GZIP"

    s3_backup_mode = "Disabled"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_audit_logs.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_audit_logs.name
    }
  }

  tags = { Name = "${local.fqn}-audit-logs" }
}

# kinesis data firehose - error logs
resource "aws_kinesis_firehose_delivery_stream" "error_logs" {
  name        = "${local.fqn}-error-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn = data.terraform_remote_state.s3.outputs.logs.arn

    # static prefix (simplified for now)
    # format: error/{year}/{month}/{day}/
    prefix = "error/!{timestamp:yyyy/MM/dd}/"

    # error output prefix
    error_output_prefix = "errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

    buffering_size     = 128
    buffering_interval = 300

    compression_format = "GZIP"

    s3_backup_mode = "Disabled"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_error_logs.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_error_logs.name
    }
  }

  tags = { Name = "${local.fqn}-error-logs" }
}
