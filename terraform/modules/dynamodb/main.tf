resource "aws_dynamodb_table" "deployment_tracking" {
  name         = var.table_deployment_tracking
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "commitSha"

  attribute {
    name = "commitSha"
    type = "S"
  }
}

resource "aws_dynamodb_table" "resume_analytics" {
  name         = var.table_resume_analytics
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "analysisId"

  attribute {
    name = "analysisId"
    type = "S"
  }
}

output "deployment_tracking_table_name" {
  value = aws_dynamodb_table.deployment_tracking.name
}

output "resume_analytics_table_name" {
  value = aws_dynamodb_table.resume_analytics.name
}