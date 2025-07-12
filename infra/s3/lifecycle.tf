# s3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  # event logs lifecycle rule
  rule {
    id     = "event_logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = "*/event/"
    }

    # 30 days after transition to IA (Infrequent Access)
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # 90 days after transition to Glacier
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # 5 years after deletion
    expiration {
      days = 1825
    }

    # delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # audit logs lifecycle rule (longer retention)
  rule {
    id     = "audit_logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = "*/audit/"
    }

    # 90 days after transition to IA
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    # 1 year after transition to Glacier
    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    # 10 years after deletion (audit logs are kept longer)
    expiration {
      days = 3650
    }

    # delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # error logs lifecycle rule
  rule {
    id     = "error_logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = "*/error/"
    }

    # 30 days after transition to IA
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # 90 days after transition to Glacier
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # 5 years after deletion
    expiration {
      days = 1825
    }

    # delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
