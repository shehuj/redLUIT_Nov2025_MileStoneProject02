variable "bucket_arn" {
  type = string
}

variable "tracking_table" {
  type = string
}

variable "analytics_table" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "log_group_name" {
  type = string
}

variable "log_stream_name" {
  type = string
}

variable "retention_in_days" {
  type = number
}

variable "enable_cloudfront" {
  type = bool
}