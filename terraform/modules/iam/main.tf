resource "aws_iam_role" "ci_cd_role" {
  name = "resume-pipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ci_cd_policy" {
  name        = "resume-pipeline-policy"
  description = "Permissions for CI/CD to deploy and write to S3 & DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteObject"
        ],
        Resource = "${var.bucket_arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.tracking_table}",
          "arn:aws:dynamodb:*:*:table/${var.analytics_table}"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "cloudformation:Deploy",
          "cloudformation:DescribeStacks"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ci_cd_role.name
  policy_arn = aws_iam_policy.ci_cd_policy.arn
}
/*
resource "aws_lambda_function" "resume_pipeline" {
  filename         = "lambda_function_payload.zip"
  function_name    = "resume-deployment-pipeline"
  role             = aws_iam_role.ci_cd_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime          = "nodejs14.x"
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_pipeline.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "resume-deployment-schedule"
  description         = "Triggers the resume deployment pipeline every day at midnight UTC"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "resume_pipeline_target" {
  rule         = aws_cloudwatch_event_rule.schedule_rule.name
  target_id  = "resume-pipeline-target"
  arn          = aws_lambda_function.resume_pipeline.arn
}
*/

