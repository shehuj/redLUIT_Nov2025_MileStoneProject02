output "bucket_name" {
  value = aws_s3_bucket.resume_site.id
}

output "bucket_arn" {
  value = aws_s3_bucket.resume_site.arn
}

output "website_url" {
  value = aws_s3_bucket.resume_site.website_endpoint
}