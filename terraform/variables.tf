variable "log_group_name" {
  description = "Name of the CloudWatch log group."
  type        = string
  default     = "resume-log-group"
}

variable "log_stream_name" {
  description = "Name of the CloudWatch log stream."
  type        = string
  default     = "resume-log-stream"
}

variable "retention_in_days" {
  description = "Retention period for the CloudWatch logs in days."
  type        = number
  default     = 14
}
variable "enable_cloudfront" {
  description = "Set to true to deploy CloudFront distribution with HTTPS."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate in us-east-1 for CloudFront HTTPS."
  type        = string
  default     = "arn:aws:acm:us-east-1:615299732970:certificate/88139633-368f-49e1-a140-cc5dd0f0a6e8"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
  default     = "milestone-bucket"
}
/*
variable "backend_bucket" {
  description = "The name of the S3 bucket for backend storage."
  type        = string
  default     = "milestone-bucket"
}
*/

variable "backend_lock_table" {
  description = "The name of the DynamoDB table for Terraform backend state locking."
  type        = string
  default     = "dyning_table"
  
}

variable "env" {
  type    = string
}

variable "table_deployment_tracking" {
  description = "value for deployment tracking DynamoDB table"
  type = string
  default = "deploymenttracking"
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
  default     = "Z04492601HFUDC7HTYJ6B"
}

variable "domain_name" {
  description = "The domain name for the website."
  type        = string
  default     = "www.claudiq.com"
}

variable "alt_names" {
  description = "Alternative domain names for the CloudFront distribution."
  type        = list(string)
  default     = ["claudiq.com", "www.claudiq.com"]
  
}