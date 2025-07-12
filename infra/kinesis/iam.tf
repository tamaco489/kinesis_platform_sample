# =================================================================
# basic iam policy for kinesis data firehose
# =================================================================
data "aws_iam_policy_document" "kinesis_firehose_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "kinesis_firehose_role" {
  name               = "${local.fqn}-kinesis-firehose"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_assume_role.json

  tags = { Name = "${local.fqn}-kinesis-firehose" }
}

# =================================================================
# s3 access policy for kinesis data firehose
# =================================================================
data "aws_iam_policy_document" "kinesis_firehose_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      data.terraform_remote_state.s3.outputs.logs.arn,
      "${data.terraform_remote_state.s3.outputs.logs.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "kinesis_firehose_s3_policy" {
  name   = "${local.fqn}-kinesis-firehose-s3-policy"
  role   = aws_iam_role.kinesis_firehose_role.id
  policy = data.aws_iam_policy_document.kinesis_firehose_s3_policy.json
}

# =================================================================
# kms access policy for kinesis data firehose
# =================================================================
data "aws_iam_policy_document" "kinesis_firehose_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [data.aws_kms_key.kinesis.arn]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "kinesis_firehose_kms_policy" {
  name   = "${local.fqn}-kinesis-firehose-kms-policy"
  role   = aws_iam_role.kinesis_firehose_role.id
  policy = data.aws_iam_policy_document.kinesis_firehose_kms_policy.json
}

# =================================================================
# cloudwatch logs access policy for kinesis data firehose
# =================================================================
data "aws_iam_policy_document" "kinesis_firehose_logs_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.kinesis_firehose_shop_event_projector.arn]
  }
}

resource "aws_iam_role_policy" "kinesis_firehose_logs_policy" {
  name   = "${local.fqn}-kinesis-firehose-logs-policy"
  role   = aws_iam_role.kinesis_firehose_role.id
  policy = data.aws_iam_policy_document.kinesis_firehose_logs_policy.json
}

# =================================================================
# kinesis data stream access policy for kinesis data firehose
# =================================================================
data "aws_iam_policy_document" "kinesis_firehose_stream_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords"
    ]
    resources = [
      aws_kinesis_stream.shop_events.arn
    ]
  }
}

resource "aws_iam_role_policy" "kinesis_firehose_stream_policy" {
  name   = "${local.fqn}-kinesis-firehose-stream-policy"
  role   = aws_iam_role.kinesis_firehose_role.id
  policy = data.aws_iam_policy_document.kinesis_firehose_stream_policy.json
}
