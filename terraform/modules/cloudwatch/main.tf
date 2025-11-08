resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}
resource "aws_cloudwatch_log_stream" "this" {
  name           = var.log_stream_name
  log_group_name = aws_cloudwatch_log_group.this.name
}
