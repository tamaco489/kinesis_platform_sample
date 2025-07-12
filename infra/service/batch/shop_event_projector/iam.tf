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

resource "aws_iam_role" "shop_event_projector" {
  name               = local.fqn
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_assume_role.json

  tags = { Name = local.fqn }
}

# https://docs.aws.amazon.com/ja_jp/aws-managed-policy/latest/reference/AWSLambdaVPCAccessExecutionRole.html
resource "aws_iam_role_policy_attachment" "shop_event_projector_execution_role" {
  role       = aws_iam_role.shop_event_projector.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# https://docs.aws.amazon.com/ja_jp/aws-managed-policy/latest/reference/AWSLambdaKinesisExecutionRole.html
resource "aws_iam_role_policy_attachment" "shop_event_projector_kinesis_execution_role" {
  role       = aws_iam_role.shop_event_projector.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

# =================================================================
# secrets manager iam policy
# =================================================================
data "aws_iam_policy_document" "shop_event_projector_secrets_manager" {
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

resource "aws_iam_policy" "shop_event_projector_secrets_manager" {
  name        = "${local.fqn}-secrets-manager-policy"
  description = "Allows Lambda to access Secrets Manager secrets"
  policy      = data.aws_iam_policy_document.shop_event_projector_secrets_manager.json
}

resource "aws_iam_role_policy_attachment" "shop_event_projector_secrets_manager" {
  role       = aws_iam_role.shop_event_projector.name
  policy_arn = aws_iam_policy.shop_event_projector_secrets_manager.arn
}
