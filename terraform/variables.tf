enable_cloudfront = true
acm_certificate_arn = "arn:aws:acm:us‑east‑1:123456789012:certificate/abcdefg‑1234‑5678‑abcd‑efghijklmnop"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    geo_restriction {
      restriction_type = "none"
    }

  tags = {
    Environment = var.env
  }

resource "aws_cloudfront_distribution" "cdn" {

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.env
  }
}

variable "aws_region" {
  type    = string
  default = "us‑east‑1"
}

variable "backend_bucket" {
  type = string
}

variable "backend_lock_table" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "env" {
  type    = string
  default = "beta"
}

variable "table_deployment_tracking" {
  type = string
}

variable "table_resume_analytics" {
  type = string
}

variable "enable_cloudfront" {
  type    = bool
  default = false
}

variable "cloudfront_domain_name" {
  type    = string
  default = ""
}