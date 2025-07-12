# s3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  # shop event projector events lifecycle rule
  rule {
    id     = "shop_event_projector_events_lifecycle"
    status = "Enabled"

    filter {
      prefix = "shop_event_projector/events/"
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

  # shop event projector errors lifecycle rule
  rule {
    id     = "shop_event_projector_errors_lifecycle"
    status = "Enabled"

    filter {
      prefix = "shop_event_projector/errors/"
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
}
