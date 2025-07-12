output "logs" {
  description = "s3 bucket for various logs (event, audit, error) via kinesis data firehose"
  value = {
    arn  = aws_s3_bucket.logs.arn
    id   = aws_s3_bucket.logs.id
    name = aws_s3_bucket.logs.bucket
  }
}
