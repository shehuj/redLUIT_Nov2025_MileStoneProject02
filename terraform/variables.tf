variable "enable_cloudfront" {
  description = "Set to true to deploy CloudFront distribution with HTTPS."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate in us-east-1 for CloudFront HTTPS."
  type        = string
  default     = "arn:aws:acm:us-east-1:615299732970:certificate/4f3c4d97-4f31-4320-8dd2-79f4ddaaac5a"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
  default     = "milestone-project-02-website-bucket"
}

variable "backend_bucket" {
  description = "The name of the S3 bucket for backend storage."
  type        = string
  default     = "ec2-shutdown-lambda-bucket"
  
}

variable "backend_lock_table" {
  description = "The name of the DynamoDB table for Terraform backend state locking."
  type        = string
  default     = "dyning_table"
  
}

variable "env" {
  type    = string
  default = "beta"
}

/*
# Conditional CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  count = var.enable_cloudfront ? 1 : 0

  origin {
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    origin_id   = "s3-origin-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for ${var.bucket_name}"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Environment = var.env
  }
}
*/

variable "table_deployment_tracking" {
  description = "value for deployment tracking DynamoDB table"
  type = string
  default = "deployment-tracking"
}

variable "table_resume_analytics" {
  description = "value for resume analytics DynamoDB table"
  type = string
  default = "resumeanalytics"
}

variable "acm_region" {
  description = "The AWS region where the ACM certificate is located."
  type        = string
  default     = "us-east-1"
  
}

variable "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the domain."
  type        = string
  default     = "E3FVFND735MQ6Q"
}

variable "domain_name" {
  description = "The domain name for the website."
  type        = string
  default     = "www.jenom.com"
}

variable "alt_names" {
  description = "Alternative domain names for the CloudFront distribution."
  type        = list(string)
  default     = ["jenom.com", "www.jenom.com"]
  
}