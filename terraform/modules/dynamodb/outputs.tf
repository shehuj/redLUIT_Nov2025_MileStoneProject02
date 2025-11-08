output "deployment_tracking_table_name" {
  value = aws_dynamodb_table.deployment_tracking.name
}

output "resume_analytics_table_name" {
  value = aws_dynamodb_table.resume_analytics.name
}