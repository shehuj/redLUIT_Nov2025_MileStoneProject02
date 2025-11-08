/*
variable "table_deployment_tracking" {
  description = "value for deployment tracking table"
  type = string
#  default = "tabledeploymenttracking"
}

variable "table_resume_analytics" {
  description = "value for resume analytics table"
  type = string
#  default = "talberesumeanalytics"
}
*/
variable "table_deployment_tracking" {
  type = string
  validation {
    condition     = length(var.table_deployment_tracking) >= 3
    error_message = "table_deployment_tracking must be at least 3 characters."
  }
}

variable "table_resume_analytics" {
  type = string
  validation {
    condition     = length(var.table_resume_analytics) >= 3
    error_message = "table_resume_analytics must be at least 3 characters."
  }
}