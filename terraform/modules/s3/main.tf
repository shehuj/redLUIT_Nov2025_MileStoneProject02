resource "aws_s3_bucket" "resume_site" {
  bucket = var.bucket_name
  # Removed deprecated acl argument. Use bucket policies for access control.
  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  lifecycle_rule {
    id      = "expire-old-objects"
    enabled = true
    prefix  = ""
    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.resume_site.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}