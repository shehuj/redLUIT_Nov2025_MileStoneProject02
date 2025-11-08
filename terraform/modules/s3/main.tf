resource "aws_s3_bucket" "resume_site" {
  bucket = var.bucket_name
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

resource "aws_s3_bucket_ownership_controls" "resume_site_ownership" {
  bucket = aws_s3_bucket.resume_site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
    # Other options: "BucketOwnerPreferred", "ObjectWriter" depending on your needs
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.resume_site.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.block]
  bucket = aws_s3_bucket.resume_site.bucket
  policy = file("${path.module}/bucket_policy.json")
}