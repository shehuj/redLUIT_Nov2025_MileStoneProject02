# Use the results in your CloudFront distribution (or other resources)
provider "aws" {
  region = var.aws_region
}


module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  env         = var.env
}

module "dynamodb" {
  source                    = "./modules/dynamodb"
  table_deployment_tracking = "table_deployment_tracking"
  table_resume_analytics    = "table_resume_analytics"
}

module "iam" {
  source          = "./modules/iam"
  bucket_arn       = module.s3.bucket_arn
  tracking_table   = var.table_deployment_tracking
  analytics_table  = var.table_resume_analytics
}

module "cloudwatch" {
  source            = "./modules/cloudwatch"
  log_group_name    = var.log_group_name
  log_stream_name   = var.log_stream_name
  retention_in_days = var.retention_in_days
#  enable_cloudfront = var.enable_cloudfront

}