variable "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  type        = string
  default     = "resume-log-group"
}

variable "retention_in_days" {
  description = "The number of days to retain log events in the specified log group."
  type        = number
  default     = 14
}

variable "log_stream_name" {
  description = "The name of the CloudWatch Log Stream"
  type        = string
  default     = "resume-log-stream"
}

variable "log_events" {
  description = "The log events to be sent to the CloudWatch Log Stream"
  type        = list(object({
    timestamp = number
    message   = string
  }))
  default     = []
}