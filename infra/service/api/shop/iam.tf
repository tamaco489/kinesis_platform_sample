# =================================================================
# basic iam policy
# =================================================================
data "aws_iam_policy_document" "lambda_execution_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "shop_api" {
  name               = local.fqn
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_assume_role.json

  tags = { Name = local.fqn }
}

# https://docs.aws.amazon.com/ja_jp/aws-managed-policy/latest/reference/AWSLambdaVPCAccessExecutionRole.html
resource "aws_iam_role_policy_attachment" "shop_api_execution_role" {
  role       = aws_iam_role.shop_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# =================================================================
# secrets manager iam policy
# =================================================================
data "aws_iam_policy_document" "shop_api_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [data.terraform_remote_state.shop_core_db.outputs.shop_core_db.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:BatchGetSecretValue",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [data.aws_kms_key.secretsmanager.arn]
  }
}

resource "aws_iam_policy" "shop_api_secrets_manager" {
  name        = local.fqn
  description = "Allows Lambda to access Secrets Manager secrets"
  policy      = data.aws_iam_policy_document.shop_api_secrets_manager.json
}

resource "aws_iam_role_policy_attachment" "shop_api_secrets_manager" {
  role       = aws_iam_role.shop_api.name
  policy_arn = aws_iam_policy.shop_api_secrets_manager.arn
}

# =================================================================
# kinesis data stream iam policy
# =================================================================
data "aws_iam_policy_document" "shop_api_kinesis" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
    ]
    resources = [data.terraform_remote_state.kinesis.outputs.shop_events_stream.arn]
  }
}

resource "aws_iam_policy" "shop_api_kinesis" {
  name        = "${local.fqn}-kinesis"
  description = "Allows Lambda to send events to Kinesis Data Stream"
  policy      = data.aws_iam_policy_document.shop_api_kinesis.json
}

resource "aws_iam_role_policy_attachment" "shop_api_kinesis" {
  role       = aws_iam_role.shop_api.name
  policy_arn = aws_iam_policy.shop_api_kinesis.arn
}
