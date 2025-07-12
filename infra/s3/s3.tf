# s3 bucket for various logs (event, audit, error) via kinesis data firehose
# directory structure: {application}/{log_type}/{year}/{month}/{day}/
# example: shop_event_projector/event/2025/01/01/
resource "aws_s3_bucket" "logs" {
  bucket = "${local.fqn}-logs"

  tags = { Name = "${local.fqn}-logs" }
}

# enable versioning for s3 bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# enable server side encryption for s3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# enable public access block for s3 bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# allow write access from kinesis data firehose
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowKinesisFirehoseServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
