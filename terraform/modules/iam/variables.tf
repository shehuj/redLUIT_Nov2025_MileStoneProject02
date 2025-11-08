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
variable "env" {
  type = string
}