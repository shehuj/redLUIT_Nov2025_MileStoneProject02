variable "bucket_name" {
  description = "The name of the S3 bucket for the website."
  type = string
  default = "milestonebucket"
}
variable "env" {
  description = "value for environment"
  type = string
}