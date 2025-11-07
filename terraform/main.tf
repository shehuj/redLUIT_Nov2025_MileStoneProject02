// NOTE: Use enable_cloudfront = true if you want a CloudFront distribution with HTTPS. Ensure acm_certificate_arn is provided for your domain/HTTPS.

// NOTE: Use enable_cloudfront = true if you want a CloudFront distribution with HTTPS.
// Ensure acm_certificate_arn is provided for your domain/HTTPS.
/*
# Call the external script using data source
data "external" "acm_cert" {
  program = ["bash", "${path.module}/scripts/certs_creation.sh"]
  query = {
    domain         = var.domain_name
    alt_names      = join(",", var.alt_names)    # e.g., ["www.example.com","api.example.com"]
    region         = var.acm_region
    hosted_zone_id = var.hosted_zone_id
  }
}

# Use the results in your CloudFront distribution (or other resources)
provider "aws" {
  region = var.aws_region
}
*/


module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  env         = var.env
}

module "dynamodb" {
  source                    = "./modules/dynamodb"
  table_deployment_tracking = var.table_deployment_tracking
  table_resume_analytics    = var.table_resume_analytics
}

module "iam" {
  source          = "./modules/iam"
  bucket_arn       = module.s3.bucket_arn
  tracking_table   = var.table_deployment_tracking
  analytics_table  = var.table_resume_analytics
}

/*
resource "aws_cloudfront_distribution" "cdn" {
  count = var.enable_cloudfront ? 1 : 0

  origin {
    domain_name = "${module.s3.bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${module.s3.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.env == "prod" ? "prod/index.html" : "beta/index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${module.s3.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
*/


/*
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Environment = var.env
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

*/



/*
variable "enable_cloudfront" {
  description = "Set to true to deploy CloudFront distribution with HTTPS."
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate to use for CloudFront HTTPS if enable_cloudfront = true."
  type        = string
  default     = ""
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  env         = var.env
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  env         = var.env
}

module "dynamodb" {
  source = "./modules/dynamodb"
  table_deployment_tracking = var.table_deployment_tracking
  table_resume_analytics    = var.table_resume_analytics
}

module "iam" {
  source          = "./modules/iam"
  bucket_arn      = module.s3.bucket_arn
  tracking_table  = var.table_deployment_tracking
  analytics_table = var.table_resume_analytics
}

resource "aws_cloudfront_distribution" "cdn" {
  count = var.enable_cloudfront ? 1 : 0

  origin {
    domain_name = "${module.s3.bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${module.s3.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.env == "prod" ? "prod/index.html" : "beta/index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${module.s3.bucket_name}"

    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

output "website_url" {
  value = var.enable_cloudfront ?
    "https://${aws_cloudfront_distribution.cdn[0].domain_name}/" :
    "http://${module.s3.bucket_name}.s3-website-${var.aws_region}.amazonaws.com/${var.env}/index.html"
}
*/